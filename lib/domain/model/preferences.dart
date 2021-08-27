import 'package:flutter/material.dart';

class Preferences {
  String? currentTheme;
  String? initialURL;
  Locale? locale;
  bool? isFirst;

  Preferences({
    @required this.currentTheme,
    @required this.initialURL,
    @required this.locale,
    @required this.isFirst,
  });
}