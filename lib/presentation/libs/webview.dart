import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef void WebViewCreatedCallback(WebViewController controller);
typedef void WebViewStarted(String url);
typedef void WebViewFinished(String url);
typedef void WebViewProgress(int progress);

class WebView extends StatefulWidget {
  const WebView({
    Key? key,
    this.onWebViewCreated,
    this.onPageStarted,
    this.onPageFinished,
    this.onProgressChanged,
  }) : super(key: key);

  final WebViewCreatedCallback? onWebViewCreated;
  final WebViewStarted? onPageStarted;
  final WebViewFinished? onPageFinished;
  final WebViewProgress? onProgressChanged;

  @override
  State<StatefulWidget> createState() => WebViewState();
}

class WebViewState extends State<WebView> {
  final controller = WebViewController();

  @override
  void initState() {
    controller.channel!.setMethodCallHandler(_handleMessages);
    super.initState();
  }

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
        widget.onPageStarted!(url);
        break;
      case 'onFinished':
        final url = call.arguments;
        widget.onPageFinished!(url);
        break;
      case 'onProgress':
        final progress = call.arguments;
        widget.onProgressChanged!(progress);
        break;
     /* case 'canGoBack':
        final canGoBack = call.arguments;
        //controller.canBack = canGoBack;
        print(canGoBack);
        break;*/
    }
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onWebViewCreated == null) {
      return;
    }
    widget.onWebViewCreated!(controller);
  }
}

class WebViewController {
  MethodChannel? channel;
  bool canBack = false;

  WebViewController() {
    this.channel = MethodChannel('my_webview');
  }

  Future<void> loadUrl(String url) async {
    return channel!.invokeMethod('loadUrl', url);
  }

  Future<bool> canGoBack() async {
    return await channel!.invokeMethod('canGoBack');
  }

  Future<void> goBack() async {
    return channel!.invokeMethod('goBack');
  }

  Future<void> reload() async {
    return channel!.invokeMethod('reloadPage');
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
