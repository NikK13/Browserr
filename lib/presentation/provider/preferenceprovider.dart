import 'dart:ui';
import 'package:browserr/domain/model/preferences.dart';
import 'package:browserr/domain/utils/localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceProvider extends ChangeNotifier {
  SharedPreferences?_sp;

  String? currentTheme;
  Locale? locale;

  PreferenceProvider() {
    _loadFromPrefs();
  }

  _initPrefs() async {
    if (_sp == null) _sp = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    if (_sp!.getString('mode') == null) await _sp!.setString('mode', 'system');
    if (_sp!.getString('language') == null) {
      switch (window.locale.languageCode) {
        case 'en':
        case 'ru':
        case 'be':
          locale = Locale(window.locale.languageCode, '');
          break;
        default:
          locale = Locale('en', '');
          break;
      }
    } else {
      locale = Locale(_sp!.getString('language')!, '');
    }
    currentTheme = _sp!.getString('mode');
    notifyListeners();
  }

  savePreference(String key, value) async {
    await _initPrefs();
    switch (key) {
      case 'language':
      case 'mode':
        _sp!.setString(key, value);
        break;
    }
    locale = Locale(_sp!.getString('language')!, '');
    currentTheme = _sp!.getString('mode');
    notifyListeners();
  }

  Preferences get preferences => Preferences(
    locale: locale,
    currentTheme: currentTheme,
  );

  String getThemeTitle(BuildContext context) {
    switch (_sp!.getString('mode')) {
      case 'light':
        return MyLocalizations.of(context, 'lighttheme');
      case 'dark':
        return MyLocalizations.of(context, 'darktheme');
      case 'system':
        return MyLocalizations.of(context, 'systemtheme');
      default:
        return "";
    }
  }

/*final colors = [
    ColorMode(
      color: Color.fromRGBO(41, 98, 255, 1.0),
      index: 0,
    ),
    ColorMode(
      color: Color(0xFFFF1744),
      index: 1,
    ),
    ColorMode(
      color: Color(0xFF00E676),
      index: 2,
    ),
    ColorMode(
      color: Color(0xFFFF6D00),
      index: 3,
    ),
    ColorMode(
      color: Color(0xFF651FFF),
      index: 4,
    ),
    ColorMode(
      color: Color(0xFFFFEA00),
      index: 5,
    ),
    ColorMode(
      color: Color(0xFF2979FF),
      index: 6,
    ),
    ColorMode(
      color: Color(0xFF76FF03),
      index: 7,
    ),
    ColorMode(
      color: Color(0xFF2E7D32),
      index: 8,
    ),
  ];*/
}
