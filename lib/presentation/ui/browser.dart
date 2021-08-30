import 'package:browserr/domain/model/history.dart';
import 'package:browserr/domain/model/preferences.dart';
import 'package:browserr/domain/utils/app.dart';
import 'package:browserr/presentation/bloc/bloc_provider.dart';
import 'package:browserr/presentation/bloc/bookmarks_bloc.dart';
import 'package:browserr/presentation/bloc/history_bloc.dart';
import 'package:browserr/presentation/bloc/web_bloc.dart';
import 'package:browserr/presentation/libs/slidemenu.dart';
import 'package:browserr/presentation/libs/toast.dart';
import 'package:browserr/presentation/libs/url_dialog.dart';
import 'package:browserr/presentation/libs/urlinfopopup.dart';
import 'package:browserr/presentation/libs/webimgdialog.dart';
import 'package:browserr/presentation/libs/webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
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
  SlideMenu? _slideMenu;
  WebViewController? _controller;

  final _webBloc = WebBloc();
  final _historyBloc = HistoryBloc();
  final _bookmarksBloc = BookmarksBloc();

  late double _initSize;
  late SharedPreferences? _prefs;

  @override
  Widget build(BuildContext context) {
    final isLight = MediaQuery.of(context).platformBrightness == Brightness.light;
    _initSize = (MediaQuery.of(context).size.height / (12 * MediaQuery.of(context).size.height));
    App.setupBar(isLight);
    return BlocProvider<HistoryBloc>(
      bloc: _historyBloc,
      child: BlocProvider<BookmarksBloc>(
        bloc: _bookmarksBloc,
        child: Scaffold(
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
                      else return Future.value(true);
                    }
                    else return Future.value(true);
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
                              onTap: (){
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
                                        child: UrlPopup(
                                          controller: _controller,
                                          url: url,
                                        ),
                                      ),
                                    );
                                  }
                                );
                              },
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
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: _initSize * 444
                              ),
                              child: WebView(
                                isWebIncognito: false,
                                onWebViewCreated: (controller) async {
                                  _controller = controller;
                                  _prefs = await SharedPreferences.getInstance();
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
                                  _webBloc.setUrl(url);
                                },
                                onProgressChanged: (int progress) {
                                  _webBloc.setProgress(progress);
                                },
                                onTitleReceived: (String title){},
                                onIconReceived: (Uint8List image, String url) async {
                                  final title = await _controller!.getTitle();
                                  _controller!.setImage(image);
                                  await _historyBloc.addItem(
                                    History(
                                      title: title,
                                      url: url,
                                      timestamp: DateTime.now().millisecondsSinceEpoch,
                                      image: image,
                                    )
                                  );
                                },
                                onPageFinished: (String url) async {
                                  _webBloc.setUrl(url);
                                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                                  await _bookmarksBloc.initialize(url);
                                  await _prefs!.setString("lastURL", url);
                                },
                              ),
                            )
                          ),
                        ],
                      ),
                      if(_controller != null)
                      DraggableScrollableSheet(
                        minChildSize: _initSize,
                        initialChildSize: _initSize,
                        maxChildSize: 0.675,
                        builder: (ctx, controller) {
                          if(_slideMenu == null){
                            _slideMenu = SlideMenu(
                              bloc: _historyBloc,
                              bmBloc: _bookmarksBloc,
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
                );
              },
            )
          ),
        ),
      )
    );
  }
}