import 'dart:typed_data';
import 'dart:ui';
import 'package:browserr/domain/model/history.dart';
import 'package:browserr/domain/model/preferences.dart';
import 'package:browserr/domain/utils/app.dart';
import 'package:browserr/domain/utils/appnavigator.dart';
import 'package:browserr/domain/utils/custompage.dart';
import 'package:browserr/domain/utils/localization.dart';
import 'package:browserr/presentation/bloc/bookmarksbloc.dart';
import 'package:browserr/presentation/bloc/historybloc.dart';
import 'package:browserr/presentation/libs/slidemenu.dart';
import 'package:browserr/presentation/libs/toast.dart';
import 'package:browserr/presentation/libs/webimgdialog.dart';
import 'package:browserr/presentation/libs/webview.dart';
import 'package:browserr/presentation/provider/preferenceprovider.dart';
import 'package:browserr/presentation/ui/browser.dart';
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
                  provider.isFirst!
                  ?
                  MaterialPage(child: WelcomePage(prefs: provider.preferences))
                  :
                  MaterialPage(child: BrowserPage(prefs: provider.preferences))
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


class WelcomePage extends StatelessWidget {
  final Preferences? prefs;

  WelcomePage({this.prefs});

  proceedToApp(context, provider) async {
    await provider.savePreference('language', prefs!.locale!.languageCode);
    await provider.savePreference('first', false);
    Navigator.pop(context);
    AppNavigator.of(context).push(
      CustomPage(child: BrowserPage(prefs: prefs))
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PreferenceProvider>(context);
    final isLight = MediaQuery.of(context).platformBrightness == Brightness.light;
    App.setupBar(isLight);
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 24,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                ),
                child: Center(
                  child: Image(
                    width: MediaQuery.of(context).size.width / 0.88,
                    height : MediaQuery.of(context).size.width / 0.88,
                    image: AssetImage('assets/illustration.jpg')
                  ),
                ),
              )
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 32,
                horizontal: 32
              ),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.cover,
                    child: Text(
                      MyLocalizations.of(context, 'title'),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  FittedBox(
                    fit: BoxFit.cover,
                    child: Text(
                      MyLocalizations.of(context, 'desc'),
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              )
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 48,
                top: 8
              ),
              child: ElevatedButton(
                onPressed: () async {
                  await proceedToApp(context, provider);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Container(
                    child: Text(
                      MyLocalizations.of(context, 'getstarted'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.normal,
                        //color: Theme.of(context).accentColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}
