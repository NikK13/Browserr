import 'dart:typed_data';
import 'dart:ui';
import 'package:browserr/domain/utils/app.dart';
import 'package:browserr/presentation/libs/bottomwebbar.dart';
import 'package:browserr/presentation/libs/toast.dart';
import 'package:browserr/presentation/libs/urlinfopopup.dart';
import 'package:browserr/presentation/libs/webimgdialog.dart';
import 'package:browserr/presentation/libs/webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncognitoPage extends StatefulWidget {
  const IncognitoPage();

  @override
  _IncognitoPageState createState() => _IncognitoPageState();
}

class _IncognitoPageState extends State<IncognitoPage> {
  WebViewController? _controller;
  SharedPreferences? prefs;

  @override
  Widget build(BuildContext context) {
    App.setupBar(false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: WillPopScope(
            onWillPop: () async {
              if (_controller != null) {
                if (await _controller!.canGoBack()) {
                  _controller!.goBack();
                  return Future.value(false);
                }
                else{
                  _controller!.isIncognitoMode(false);
                  return Future.value(true);
                }
              }
              else{
                _controller!.isIncognitoMode(false);
                return Future.value(false);
              }
            },
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        if(_controller != null){
                          showDialog(
                            context: context,
                            builder: (context){
                              return BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                  child: UrlInfoPopup(
                                    controller: _controller,
                                  ),
                                ),
                              );
                            }
                          );
                        }
                      },
                      child: Icon(
                        Icons.lock,
                        color: _controller != null ?
                        (_controller!.url.contains("https") ?
                        Colors.green :
                        Colors.grey) :
                        Colors.grey,
                        size: 18,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16
                      ),
                      child: InkWell(
                        onLongPress: () {
                          if(_controller != null){
                            final url = _controller!.url;
                            Clipboard.setData(ClipboardData(text: url));
                            Toast("URL copied to clipboard");
                          }
                        },
                        child: Text(
                          _controller == null ? "" : _controller!.url,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if((_controller != null) && (_controller!.progress > 0 && _controller!.progress < 100))
                    LinearProgressIndicator(
                      value: _controller!.progress.toDouble() / 100,
                      //backgroundColor: Colors.red,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        App.appColor,
                      ),
                    ),
                    Expanded(
                      child: WebView(
                        isWebIncognito: true,
                        onWebViewCreated: (controller) async {
                          prefs = await SharedPreferences.getInstance();
                          setState(() => _controller = controller);
                          await _controller!.loadUrl(prefs!.getString('initialURL')!);
                        },
                        onShowContextMenu: (){
                          showDialog(
                            context: context,
                            builder: (ctx){
                              return ImagesDialog(
                                controller: _controller,
                              );
                            }
                          );
                        },
                        onPageStarted: (String url) {
                          setState(() => _controller!.url = url);
                          _controller!.image = null;
                        },
                        onProgressChanged: (int progress) {
                          setState(() => _controller!.progress = progress);
                          //print(progress);
                        },
                        onTitleReceived: (String title){
                          print("Incognito: onTitleReceived");
                        },
                        onIconReceived: (Uint8List image, String url) async {
                          _controller!.image = image;
                        },
                        onPageFinished: (String url) async {
                          print("Incognito: onFinished");
                          SystemChannels.textInput.invokeMethod('TextInput.hide');
                          try{
                            setState(() => _controller!.url = url);
                          }
                          catch(e){
                            print("error is $e");
                          }
                        },
                      ),
                  ),
                  if(_controller != null)
                  BottomWebBar(
                    controller: _controller,
                    isIncognito: true,
                    onBack: () async {
                      if (await _controller!.canGoBack()) {
                        _controller!.goBack();
                      }
                    },
                    onForward: () async {
                      await _controller!.goForward();
                    },
                    onHomeTap: () async {
                      prefs = await SharedPreferences.getInstance();
                      await _controller!.loadUrl(prefs!.getString('initialURL')!);
                    },
                    reloadPage: () async => await _controller!.reload(),
                  ),
                ],
              ),
            ],
          )
        ),
      ),
    );
  }
}