import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef void WebViewCreatedCallback(WebViewController controller);
typedef void WebViewStarted(String url);
typedef void WebViewFinished(String url);
typedef void WebViewProgress(int progress);
typedef void WebViewFavicon(Uint8List imageBytes, String url);
typedef void WebViewContextMenu();

class WebView extends StatelessWidget{
  WebView({
    Key? key,
    this.onWebViewCreated,
    this.onPageStarted,
    this.onPageFinished,
    this.onProgressChanged,
    this.onShowContextMenu,
    this.onIconReceived,
  }) : super(key: key);

  final WebViewCreatedCallback? onWebViewCreated;
  final WebViewStarted? onPageStarted;
  final WebViewFinished? onPageFinished;
  final WebViewProgress? onProgressChanged;
  final WebViewFavicon? onIconReceived;
  final WebViewContextMenu? onShowContextMenu;

  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: 'webview',
      onPlatformViewCreated: _onPlatformViewCreated,
    );
  }

  Future<Null> _handleMessages(MethodCall call) async {
    switch (call.method) {
      case 'onStarted':
        final url = call.arguments;
        onPageStarted!(url);
        break;
      case 'onFinished':
        final url = call.arguments;
        onPageFinished!(url);
        break;
      case 'onProgress':
        final progress = call.arguments;
        onProgressChanged!(progress);
        break;
      case 'createContextMenu':
        onShowContextMenu!();
        break;
      case 'onIconReceived':
        final args = call.arguments as Map;
        onIconReceived!(args['image'] as Uint8List, args['url'] as String);
        break;
    }
  }

  void _onPlatformViewCreated(int id){
    final controller = WebViewController(id);
    if (onWebViewCreated == null) {
      return;
    }
    onWebViewCreated!(controller);
    controller.channel!.setMethodCallHandler(_handleMessages);
  }
}

class WebViewController {
  MethodChannel? channel;

  String url = "";
  int progress = 0;
  Uint8List? image;

  WebViewController(id) {
    this.channel = MethodChannel('webview$id');
  }

  Future<void> loadUrl(String url) async {
    return channel!.invokeMethod('loadUrl', url);
  }

  Future<void> shareUrl(String url) async {
    return await channel!.invokeMethod('shareUrl', url);
  }

  Future<void> viewSourceCode(String url) async {
    return await channel!.invokeMethod('viewSource', url);
  }

  Future<bool> canGoBack() async {
    return await channel!.invokeMethod('canGoBack');
  }

  Future<String> getTitle() async {
    return await channel!.invokeMethod('getTitle');
  }

  Future<void> goBack() async {
    return channel!.invokeMethod('goBack');
  }

  Future<void> reload() async {
    return channel!.invokeMethod('reloadPage');
  }

  Future<void> downloadImage() async {
    return channel!.invokeMethod('downloadImage');
  }

  Future<void> shareImage() async {
    return channel!.invokeMethod('shareImage');
  }

  Future<void> hideKeyboard() async {
    return channel!.invokeMethod('hideKeyboard');
  }

  Future<void> goForward() async {
    return channel!.invokeMethod('canGoForward');
  }

  Future<void> setDesktopMode(bool isDesk) async {
    return channel!.invokeMethod('isDesktopMode', isDesk);
  }

  Future<void> forceDarkEnabled(bool isEnabled) async {
    return channel!.invokeMethod('forceDarkEnabled', isEnabled);
  }
}
