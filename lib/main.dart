import 'dart:typed_data';
import 'dart:ui';
import 'package:browserr/domain/model/history.dart';
import 'package:browserr/domain/model/preferences.dart';
import 'package:browserr/domain/utils/app.dart';
import 'package:browserr/domain/utils/appnavigator.dart';
import 'package:browserr/presentation/bloc/bookmarksbloc.dart';
import 'package:browserr/presentation/bloc/historybloc.dart';
import 'package:browserr/presentation/libs/slidemenu.dart';
import 'package:browserr/presentation/libs/toast.dart';
import 'package:browserr/presentation/libs/webimgdialog.dart';
import 'package:browserr/presentation/libs/webview.dart';
import 'package:browserr/presentation/provider/preferenceprovider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PreferenceProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final HeroController _heroController = HeroController();

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(
      builder: (ctx, provider, child) {
        if(provider.currentTheme != null){
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: _navigatorKey,
            onGenerateRoute: (_) => null,
            locale: provider.preferences.locale,
            localizationsDelegates: App.delegates,
            supportedLocales: App.supportedLocales,
            themeMode: App.getThemeMode(provider.currentTheme!),
            theme: App.themeLight,
            darkTheme: App.themeDark,
            builder: (context, child){
              return AppNavigator(
                navigatorKey: _navigatorKey,
                initialPages: [
                  MaterialPage(child: WebViewPage(prefs: provider.preferences))
                ],
                observers: [_heroController],
              );
            },
          );
        }
        else return Container();
      },
    );
  }
}

class WebViewPage extends StatefulWidget {
  final Preferences? prefs;

  const WebViewPage({this.prefs});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  WebViewController? _controller;
  SharedPreferences? prefs;
  SlideMenu? slideMenu;

  final initialUrl = 'https://www.google.com';
  final historyBloc = HistoryBloc();
  final bookmarksBloc = BookmarksBloc();

  late double initSize;

  @override
  Widget build(BuildContext context) {
    final isLight = MediaQuery.of(context).platformBrightness == Brightness.light;
    initSize = (MediaQuery.of(context).size.height / 1000) * ((MediaQuery.of(context).size.height / 1000) * 0.185);
    App.setupBar(isLight);
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
              else
                return Future.value(true);
            }
            else
              return Future.value(false);
          },
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      if(_controller != null){
                        Toast(
                          _controller!.url.contains("https")
                              ?
                          "Connection is secured"
                              :
                          "Connection is not secured"
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
                      size: 16,
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
                          fontSize: 15,
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
                        bottom: initSize * 188
                      ),
                      child: WebView(
                        onWebViewCreated: (controller) async {
                          prefs = await SharedPreferences.getInstance();
                          setState(() => _controller = controller);
                          if (prefs!.getString("lastURL") == null) {
                            _controller!.loadUrl(initialUrl);
                            await prefs!.setString("lastURL", initialUrl);
                          }
                          else {
                            final lastURL = prefs!.getString("lastURL");
                            _controller!.loadUrl(lastURL!);
                          }
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
                        },
                        onProgressChanged: (int progress) {
                          setState(() => _controller!.progress = progress);
                        },
                        onIconReceived: (Uint8List image, String url) async {
                          final title = await _controller!.getTitle();
                          _controller!.image = image;
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
                          await prefs!.setString("lastURL", url);
                          await bookmarksBloc.initialize(url);
                        },
                      ),
                    )
                  ),
                ],
              ),
              if(_controller != null)
              DraggableScrollableSheet(
                minChildSize: initSize,
                initialChildSize: initSize,
                maxChildSize: 0.675,
                builder: (ctx, controller) {
                  if(slideMenu == null){
                    slideMenu = SlideMenu(
                      bloc: historyBloc,
                      bmBloc: bookmarksBloc,
                      controller: _controller,
                      scrollController: controller,
                      initialUrl: initialUrl,
                    );
                  }
                  return slideMenu!;
                },
              ),
            ],
          )
        ),
      ),
    );
  }
}
