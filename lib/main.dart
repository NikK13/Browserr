import 'package:browserr/domain/model/history.dart';
import 'package:browserr/domain/model/preferences.dart';
import 'package:browserr/domain/utils/app.dart';
import 'package:browserr/domain/utils/appnavigator.dart';
import 'package:browserr/domain/utils/custompage.dart';
import 'package:browserr/presentation/bloc/historybloc.dart';
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
      resizeToAvoidBottomInset: false,
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

  WebViewController? _controller;

  String _url = "";
  int _progress = 0;
  bool isDesktop = false;
  bool isForceDark = false;

  final initialUrl = 'https://www.google.com';
  final desktopAgent = "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.4) Gecko/20100101 Firefox/4.0";
  final List<History> historyEx = [];

  String? prevUrl;
  String? curUrl;

  final historyBloc = HistoryBloc();

  @override
  Widget build(BuildContext context) {
    final isLight = MediaQuery.of(context).platformBrightness == Brightness.light;
    App.setupBar(isLight);
    return WillPopScope(
      onWillPop: () async{
        if(_controller != null){
          if(await _controller!.canGoBack()){
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
                    _controller!.loadUrl(initialUrl);
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
                  onPageFinished: (String url) async {
                    final title = await _controller!.getTitle();
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                    setState(() {
                      _url = url;
                      prevUrl = curUrl;
                      curUrl = url;
                    });
                    if(prevUrl != curUrl){
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
          DraggableScrollableSheet(
            minChildSize: (MediaQuery.of(context).size.height / 1000) * ((MediaQuery.of(context).size.height / 1000) * 0.07),
            initialChildSize: (MediaQuery.of(context).size.height / 1000) * ((MediaQuery.of(context).size.height / 1000) * 0.195),
            maxChildSize: 0.675,
            builder: (context, controller){
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade900
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ListView(
                  controller: controller,
                  children: [
                    SizedBox(height: 16),
                    Align(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness ==
                              Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 28,
                        height: 4,
                      ),
                      alignment: Alignment.center,
                    ),
                    SizedBox(height: 12),
                    BottomWebBar(
                      goToHistory: () async{
                        await AppNavigator.of(context).push(
                            CustomPage(child: WebHistory(bloc: historyBloc))
                        );
                      },
                      onBack: () async{
                        if(await _controller!.canGoBack()){
                          _controller!.goBack();
                        }
                      },
                      onForward: () async{
                        await _controller!.goForward();
                      },
                      onHomeTap: () async{
                        await _controller!.loadUrl(initialUrl);
                      },
                      changeMode: () async{
                        setState(() {
                          isDesktop = !isDesktop;
                        });
                        await _controller!.setDesktopMode(isDesktop);
                      },
                      reloadPage: () async => await _controller!.reload(),
                      forceDark: () async {
                        setState(() {
                          isForceDark = !isForceDark;
                        });
                        await _controller!.forceDarkEnabled(isForceDark);
                      },
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Force Dark enabled",
                                    style: TextStyle(
                                      fontSize: 18
                                    ),
                                  ),
                                  Text(
                                    "Works with Android 10+",
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                              Switch(
                                activeColor: App.appColor,
                                value: isForceDark,
                                onChanged: (bool value){
                                  setState(() {
                                    isForceDark = value;
                                  });
                                  _controller!.forceDarkEnabled(value);
                                }
                              )
                            ],
                          ),
                        )
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Desktop mode enabled",
                                    style: TextStyle(
                                      fontSize: 18
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                activeColor: App.appColor,
                                value: isDesktop,
                                onChanged: (bool value){
                                  setState(() {
                                    isDesktop = value;
                                  });
                                  _controller!.setDesktopMode(value);
                                }
                              )
                            ],
                          ),
                        )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1.25,
                              child: Card(
                                child: InkWell(
                                  onTap: (){
                                    AppNavigator.of(context).push(
                                      CustomPage(
                                        child: WebHistory(
                                          bloc: historyBloc,
                                          controller: _controller,
                                        )
                                      )
                                    );
                                  },
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.history,
                                          size: MediaQuery.of(context).size.width / 10,
                                          color: Theme.of(context).textTheme.bodyText1!.color,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "History",
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    )
                                  ),
                                )
                              ),
                            )
                          ),
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1.25,
                              child: Card(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.bookmark_outline_rounded,
                                        size: MediaQuery.of(context).size.width / 10,
                                        color: Theme.of(context).textTheme.bodyText1!.color,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Bookmarks",
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  )
                                ),
                              ),
                            )
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          )
        ],
      )
    );
  }
}
