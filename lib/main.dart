import 'dart:ui';

import 'package:browserr/domain/model/history.dart';
import 'package:browserr/domain/model/preferences.dart';
import 'package:browserr/domain/utils/app.dart';
import 'package:browserr/domain/utils/appnavigator.dart';
import 'package:browserr/presentation/bloc/historybloc.dart';
import 'package:browserr/presentation/libs/slidemenu.dart';
import 'package:browserr/presentation/libs/toast.dart';
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

  String _url = "";
  int _progress = 0;

  final initialUrl = 'https://www.google.com';
  final historyBloc = HistoryBloc();

  String? prevUrl;
  String? curUrl;
  bool isExpanded = false;

  late double minSize;
  late double initSize;

  @override
  Widget build(BuildContext context) {
    final isLight = MediaQuery.of(context).platformBrightness == Brightness.light;
    minSize = (MediaQuery.of(context).size.height / 1000) * ((MediaQuery.of(context).size.height / 1000) * 0.09);
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
                      Toast(
                        _url.contains("https")
                            ?
                        "Connection is secured"
                            :
                        "Connection is not secured"
                      );
                    },
                    child: Icon(
                      Icons.lock,
                      color: _url.contains("https") ? Colors.green : Colors.grey,
                      size: 16,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16
                    ),
                    child: InkWell(
                      onLongPress: () {
                        Clipboard.setData(ClipboardData(text: _url));
                        Toast("URL copied to clipboard");
                      },
                      child: Text(
                        _url,
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
                  if(_progress > 0 && _progress < 100)
                    LinearProgressIndicator(
                      value: _progress.toDouble() / 100,
                      //backgroundColor: Colors.red,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        App.appColor,
                      ),
                    ),
                  Expanded(
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
                            return BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const SizedBox(height: 16),
                                      Text(
                                        "Menu preferences",
                                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                      ),
                                      const SizedBox(height: 20),
                                      ListTile(
                                        leading: Icon(
                                          Icons.image,
                                          color: Theme.of(context).textTheme.bodyText1!.color,
                                        ),
                                        title: Text(
                                          "Download image",
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        onTap: () async {
                                          await _controller!.downloadImage();
                                          Navigator.pop(ctx);
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(
                                          Icons.share,
                                          color: Theme.of(context).textTheme.bodyText1!.color,
                                        ),
                                        title: Text(
                                          "Share image",
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        onTap: () async {
                                          await _controller!.shareImage();
                                          Navigator.pop(ctx);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        );
                      },
                      onPageStarted: (String url) {
                        setState(() => _url = url);
                      },
                      onProgressChanged: (int progress) {
                        setState(() => _progress = progress);
                      },
                      onPageFinished: (String url) async {
                        final title = await _controller!.getTitle();
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        setState(() {
                          _url = url;
                          prevUrl = curUrl;
                          curUrl = url;
                        });
                        await prefs!.setString("lastURL", url);
                        if (prevUrl != curUrl) {
                          //FocusManager.instance.primaryFocus!.unfocus();
                          //SystemChannels.textInput.invokeMethod('TextInput.hide');
                          //FocusScope.of(context).unfocus();
                          await historyBloc.addItem(
                            History(
                              title: title,
                              url: url,
                              timestamp: DateTime.now().millisecondsSinceEpoch
                            )
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              if(_controller != null)
              DraggableScrollableSheet(
                minChildSize: minSize,
                initialChildSize: initSize,
                maxChildSize: 0.675,
                builder: (ctx, controller) {
                  return SlideMenu(
                    bloc: historyBloc,
                    controller: _controller,
                    scrollController: controller,
                    initialUrl: initialUrl,
                  );
                },
              ),
            ],
          )
        ),
      ),
    );
  }
}
