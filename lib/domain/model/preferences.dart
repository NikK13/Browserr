import 'package:flutter/material.dart';

class Preferences {
  String? currentTheme;
  Locale? locale;

  Preferences({
    @required this.currentTheme,
    @required this.locale,
  });
}