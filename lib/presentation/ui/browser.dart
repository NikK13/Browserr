import 'package:browserr/domain/model/history.dart';
import 'package:browserr/domain/model/preferences.dart';
import 'package:browserr/domain/utils/app.dart';
import 'package:browserr/presentation/bloc/bloc_provider.dart';
import 'package:browserr/presentation/bloc/bookmarksbloc.dart';
import 'package:browserr/presentation/bloc/historybloc.dart';
import 'package:browserr/presentation/libs/slidemenu.dart';
import 'package:browserr/presentation/libs/toast.dart';
import 'package:browserr/presentation/libs/urlinfopopup.dart';
import 'package:browserr/presentation/libs/webimgdialog.dart';
import 'package:browserr/presentation/libs/webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'dart:ui';

class BrowserPage extends StatefulWidget {
  final Preferences? prefs;

  const BrowserPage({this.prefs});

  @override
  _BrowserPageState createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  WebViewController? _controller;
  SharedPreferences? _prefs;
  SlideMenu? _slideMenu;

  final historyBloc = HistoryBloc();
  final bookmarksBloc = BookmarksBloc();

  late double _initSize;
  late int? _androidV;

  @override
  Widget build(BuildContext context) {
    final isLight = MediaQuery.of(context).platformBrightness == Brightness.light;
    _initSize = (MediaQuery.of(context).size.height / 1000) * ((MediaQuery.of(context).size.height / 1000) * 0.14);
    App.setupBar(isLight);
    return BlocProvider<HistoryBloc>(
      bloc: historyBloc,
      child: BlocProvider<BookmarksBloc>(
        bloc: bookmarksBloc,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: WillPopScope(
              onWillPop: () async {
                if (_controller != null) {
                  if (await _controller!.canGoBack()) {
                    _controller!.goBack();
                    return Future.value(false);
                  }
                  else return Future.value(true);
                }
                else return Future.value(false);
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
                            //overflow: TextOverflow.ellipsis,
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
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: _initSize * 444
                          ),
                          child: WebView(
                            isWebIncognito: false,
                            onWebViewCreated: (controller) async {
                              _prefs = await SharedPreferences.getInstance();
                              setState(() => _controller = controller);
                              _androidV = await _controller!.getAndroidVersion();
                              final extraData = await _controller!.intentExtra();
                              if(extraData == null){
                                if (_prefs!.getString("lastURL") == null) {
                                  _controller!.loadUrl(widget.prefs!.initialURL!);
                                  await _prefs!.setString("lastURL", widget.prefs!.initialURL!);
                                }
                                else {
                                  final lastURL = _prefs!.getString("lastURL");
                                  _controller!.loadUrl(lastURL!);
                                }
                              }
                              else{
                                _controller!.loadUrl(extraData);
                                await _prefs!.setString("lastURL", extraData);
                              }
                            },
                            onShowContextMenu: () async{
                              final isImage = await _controller!.isWebHitOfImage();
                              if(isImage){
                                showDialog(
                                  context: context,
                                  builder: (ctx){
                                    return ImagesDialog(
                                      controller: _controller,
                                    );
                                  }
                                );
                              }
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
                              print("onTitleReceived");
                            },
                            onIconReceived: (Uint8List image, String url) async {
                              final title = await _controller!.getTitle();
                              _controller!.image = image;
                              print("onIconReceived: $url");
                              await historyBloc.addItem(
                                History(
                                  title: title,
                                  url: url,
                                  timestamp: DateTime.now().millisecondsSinceEpoch,
                                  image: image,
                                )
                              );
                            },
                            onPageFinished: (String url) async {
                              SystemChannels.textInput.invokeMethod('TextInput.hide');
                              setState(() => _controller!.url = url);
                              await _prefs!.setString("lastURL", url);
                              await bookmarksBloc.initialize(url);
                            },
                          ),
                        )
                      ),
                    ],
                  ),
                  if(_controller != null && _androidV != null)
                  DraggableScrollableSheet(
                    minChildSize: _initSize,
                    initialChildSize: _initSize,
                    maxChildSize: 0.675,
                    builder: (ctx, controller) {
                      if(_slideMenu == null){
                        _slideMenu = SlideMenu(
                          bloc: historyBloc,
                          bmBloc: bookmarksBloc,
                          androidV: _androidV,
                          controller: _controller,
                          scrollController: controller,
                          initialUrl: widget.prefs!.initialURL!,
                        );
                      }
                      return _slideMenu!;
                    },
                  ),
                ],
              )
            ),
          ),
        ),
      )
    );
  }
}