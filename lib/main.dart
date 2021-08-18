import 'package:browserr/domain/model/preferences.dart';
import 'package:browserr/domain/utils/app.dart';
import 'package:browserr/domain/utils/appnavigator.dart';
import 'package:browserr/domain/utils/custompage.dart';
import 'package:browserr/presentation/libs/bottomwebbar.dart';
import 'package:browserr/presentation/libs/toast.dart';
import 'package:browserr/presentation/libs/webview.dart';
import 'package:browserr/presentation/provider/preferenceprovider.dart';
import 'package:browserr/presentation/ui/history.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
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
          switch(App.platform){
            case "ios":
              return CupertinoApp(
                debugShowCheckedModeBanner: false,
                navigatorKey: _navigatorKey,
                onGenerateRoute: (_) => null,
                locale: provider.preferences.locale,
                localizationsDelegates: App.delegates,
                supportedLocales: App.supportedLocales,
                theme: App.cupertinoTheme,
                builder: (context, child){
                  return AppNavigator(
                    navigatorKey: _navigatorKey,
                    initialPages: [
                      startingPage(
                          App.platform,
                          provider.preferences
                      ),
                    ],
                    observers: [_heroController],
                  );
                },
              );
            default:
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
                      startingPage(
                          App.platform,
                          provider.preferences
                      ),
                    ],
                    observers: [_heroController],
                  );
                },
              );
          }
        }
        else return Container();
      },
    );
  }

  Page<Object> startingPage(platform, prefs) {
    switch(platform){
      case "ios":
        return CupertinoPage(
            child: WebViewIOS(prefs: prefs)
        );
      default:
        return MaterialPage(
            child: WebViewAndroid(prefs: prefs)
        );
    }
  }
}

class WebViewAndroid extends StatelessWidget {
  final Preferences? prefs;

  WebViewAndroid({this.prefs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewPage(prefs: prefs),
      ),
    );
  }
}

class WebViewIOS extends StatelessWidget {
  final Preferences? prefs;

  WebViewIOS({this.prefs});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: WebViewPage(prefs: prefs),
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

  WebViewController _controller = WebViewController();

  String _url = "";
  int _progress = 0;
  bool isDesktop = false;
  bool isForceDark = false;

  final initialUrl = 'https://www.google.com';
  final desktopAgent = "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.4) Gecko/20100101 Firefox/4.0";
  final List<String> historyEx = [];

  String? prevUrl;
  String? curUrl;

  @override
  Widget build(BuildContext context) {
    final isLight = MediaQuery.of(context).platformBrightness == Brightness.light;
    App.setupBar(isLight);
    return WillPopScope(
      onWillPop: () async{
        if(await _controller.canGoBack()){
          _controller.goBack();
          return Future.value(false);
        }
        else return Future.value(true);
      },
      child: Column(
        children: [
          const SizedBox(height: 8),
          InkWell(
            onTap: (){
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
              onLongPress: (){
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
              onWebViewCreated: (controller){
                setState(() {
                  _controller = controller;
                });
                _controller.loadUrl(initialUrl);
              },
              onPageStarted: (String url) {
                //print("Current url is: $url");
                setState(() {
                  _url = url;
                });
              },
              onProgressChanged: (int progress){
                setState(() {
                  _progress = progress;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  _url = url;
                  prevUrl = curUrl;
                  curUrl = url;
                });
                if(prevUrl != curUrl){
                  historyEx.add(url);
                }
              },
            ),
          ),
          BottomWebBar(
            goToHistory: () async{
              await AppNavigator.of(context).push(
                CustomPage(child: WebHistory(history: historyEx))
              );
            },
            onBack: () async{
              if(await _controller.canGoBack()){
                _controller.goBack();
              }
            },
            onForward: () async{
              await _controller.goForward();
            },
            onHomeTap: () async{
              await _controller.loadUrl(initialUrl);
            },
            changeMode: () async{
              setState(() {
                isDesktop = !isDesktop;
              });
              await _controller.setDesktopMode(isDesktop);
            },
            reloadPage: () async => await _controller.reload(),
            forceDark: () async {
              setState(() {
                isForceDark = !isForceDark;
              });
              await _controller.forceDarkEnabled(isForceDark);
            },
          ),
        ],
      ),
    );
  }
}

/*

 */
