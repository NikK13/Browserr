import 'dart:ui';
import 'package:browserr/domain/utils/app.dart';
import 'package:browserr/presentation/bloc/web_bloc.dart';
import 'package:browserr/presentation/libs/bottomwebbar.dart';
import 'package:browserr/presentation/libs/toast.dart';
import 'package:browserr/presentation/libs/urlinfopopup.dart';
import 'package:browserr/presentation/libs/webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncognitoPage extends StatefulWidget {
  @override
  _IncognitoPageState createState() => _IncognitoPageState();
}

class _IncognitoPageState extends State<IncognitoPage> {
  WebBloc _webBloc = WebBloc();

  SharedPreferences? _prefs;
  WebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    App.setupBar(false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: StreamBuilder(
          stream: CombineLatestStream.list([_webBloc.urlStream, _webBloc.progressStream]),
          builder: (context, AsyncSnapshot snapshot){
            final url = snapshot.data != null ? snapshot.data[0] : "";
            final progress = snapshot.data != null ? snapshot.data[1] : 0;
            return WillPopScope(
              onWillPop: () async {
                if(_controller != null){
                  if (await _controller!.canGoBack()) {
                    _controller!.goBack();
                    return Future.value(false);
                  }
                  else {
                    _controller!.isIncognitoMode(false);
                    return Future.value(true);
                  }
                }
                else {
                  _controller!.isIncognitoMode(false);
                  return Future.value(true);
                }
              },
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
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
                                    url: url,
                                  ),
                                ),
                              );
                            }
                          );
                        },
                        child: Icon(
                          Icons.lock,
                          color: url.contains("https") ?
                          Colors.green :
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
                            Clipboard.setData(ClipboardData(text: url));
                            Toast("URL copied to clipboard");
                          },
                          child: Text(
                            url,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                            ),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            //overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if(progress > 0 && progress < 100)
                      LinearProgressIndicator(
                        value: progress.toDouble() / 100,
                        //backgroundColor: Colors.red,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          App.appColor,
                        ),
                      ),
                      Expanded(
                        child: WebView(
                          isWebIncognito: true,
                          onWebViewCreated: (controller) async {
                            _controller = controller;
                            _prefs = await SharedPreferences.getInstance();
                            _controller!.loadUrl(_prefs!.getString('initialURL')!);
                          },
                          onPageStarted: (String url) {
                            _webBloc.setUrl(url);
                          },
                          onProgressChanged: (int progress) {
                            _webBloc.setProgress(progress);
                          },
                          onPageFinished: (String url) async {
                            _webBloc.setUrl(url);
                            SystemChannels.textInput.invokeMethod('TextInput.hide');
                          },
                        ),
                      ),
                      if(_controller != null)
                      BottomWebBar(
                        isIncognito: true,
                        controller: _controller,
                        onBack: () async {
                          if (await _controller!.canGoBack()) {
                            _controller!.goBack();
                          }
                        },
                        onForward: () async {
                          await _controller!.goForward();
                        },
                        onHomeTap: () async {
                          _prefs = await SharedPreferences.getInstance();
                          await _controller!.loadUrl(_prefs!.getString('initialURL')!);
                        },
                        reloadPage: () async => await _controller!.reload(),
                      ),
                    ],
                  ),
                ],
              )
            );
          },
        )
      ),
    );
  }
}