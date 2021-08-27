import 'package:browserr/domain/utils/localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class App {
  static const appColor = Color(0xFFFDC222);
  //static const appColor = Color(0xFF673AB7);
  static const Color colorDark = const Color(0xFF212121);
  static const Color colorLight = const Color(0xFFFFFF);
  static Color test = Colors.deepPurple;
  static const String font = "SourceSans";

  static final Iterable<LocalizationsDelegate<dynamic>> delegates = [
    MyLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    DefaultMaterialLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate,
    DefaultCupertinoLocalizations.delegate,
  ];

  static final supportedLocales = [
    const Locale('en', ''), //English
    const Locale('ru', ''),
    const Locale('be', ''), //Russian
  ];

  static final platform = "ui";
  /*static final fabTheme = FloatingActionButtonThemeData(
    backgroundColor: appColor,
  );*/
  static final textStyleBtnLight = TextStyle(
      fontSize: 16,
      color: Colors.white
  );
  static final textStyleBtnDark = TextStyle(
      fontSize: 16,
      color: Colors.green.shade700
  );

  static final buttonStyle = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      primary: App.appColor,
      textStyle: TextStyle(
        fontFamily: App.font,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      )
    )
  );

  static final cupertinoTheme = CupertinoThemeData(
      primaryColor: App.appColor,
      scaffoldBackgroundColor: CupertinoDynamicColor.withBrightness(
        color: Colors.grey.shade50,
        darkColor: App.colorDark,
      ),
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontFamily: App.font,
          color: CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.black,
            darkColor: CupertinoColors.white,
          ),
        ),
      )
  );

  static final themeLight = ThemeData(
    //scaffoldBackgroundColor: Constants.colorLight,
    accentColor: Colors.white,
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    //floatingActionButtonTheme: fabTheme,
    textTheme: TextTheme(
      button: textStyleBtnLight,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
    ),
    elevatedButtonTheme: buttonStyle,
    brightness: Brightness.light,
    fontFamily: App.font,
  );

  static final themeDark = ThemeData(
    accentColor: Colors.black,
    scaffoldBackgroundColor: App.colorDark,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    //floatingActionButtonTheme: fabTheme,
    elevatedButtonTheme: buttonStyle,
    textTheme: TextTheme(
      button: textStyleBtnDark,
    ),
    /*buttonTheme: ButtonThemeData(
      buttonColor: Colors.pink,
      textTheme: ButtonTextTheme.primary,
    ),*/
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black54,
    ),
    brightness: Brightness.dark,
    fontFamily: App.font,
  );

  static ThemeMode getThemeMode(String mode){
    switch(mode){
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static setupBar(isLight) => SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
      statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      statusBarColor: isLight ? Color(0x000000) : Colors.transparent,
      systemNavigationBarColor: isLight ? Color(0x000000) : Colors.black,
    ),
  );
}
