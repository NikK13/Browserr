import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyLocalizations {
  final Locale locale;

  MyLocalizations(this.locale);

  static LocalizationsDelegate<MyLocalizations> delegate =
  MyLocalizationsDelegate();

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'history': "History",
      'bookmarks': "Bookmarks",
      'desktopmode': "Desktop mode",
      'findpage': "Find on page",
      'incognito': "Incognito",
      'sourcecode': "Source code",
      'settings': "Settings",
      'shareurl': "Share URL",
      'darkweb': "Website dark mode",
      'androidten': "Only Android 10 and higher",
      'appearance': "Appearance",
      'common': "Common",
      'changelang': "Current language",
      'currenttheme': "Current theme",
      'darktheme': "Dark",
      'lighttheme': "Light",
      'systemtheme': "System",
      'themes': "Available themes",
      'langs': "Available languages",
      'today': "Today",
      'getstarted': "Launch now",
      'title': "BrowseR",
      'desc': "Scrollable bottom menu with a lot of features",
      'webprefs': "Web settings",
      'cache': "Browser cache",
      'clear': "Clear",
      'about': "About application"
    },
    'ru': {
      'history': "История",
      'bookmarks': "Закладки",
      'desktopmode': "Версия для ПК",
      'findpage': "Найти на странице",
      'incognito': "Режим инкогнито",
      'sourcecode': "Код страницы",
      'settings': "Настройки",
      'shareurl': "Поделиться ссылкой",
      'darkweb': "Темный режим веб-страницы",
      'androidten': "Только Андроид версии 10 и выше",
      'appearance': "Дизайн",
      'common': "Общие",
      'changelang': "Текущий язык",
      'currenttheme': "Текущая тема",
      'darktheme': "Темная",
      'lighttheme': "Светлая",
      'systemtheme': "Тема устройства",
      'themes': "Доступные темы",
      'langs': "Доступные языки",
      'today': "Сегодня",
      'getstarted': "Начать",
      'title': "BrowseR",
      'desc': "Выдвижное нижнее меню с многими функциями",
      'webprefs': "Веб настройки",
      'cache': "Кэш браузера",
      'clear': "Очистить",
      'about': "О приложении"
    },
    'be': {
      'history': "Гісторыя",
      'bookmarks': "Закладкі",
      'desktopmode': "Версія для ПК",
      'findpage': "Знайсці на старонцы",
      'incognito': "Рэжым інкогніта",
      'sourcecode': "Код старонкі",
      'settings': "Налады",
      'shareurl': "Падзяліцца спасылкай",
      'darkweb': "Цёмны рэжым вэб-старонкі",
      'androidten': "Толькі Андроід версіі 10 і вышэй",
      'appearance': "Дызайн",
      'common': "Агульнае",
      'changelang': "Мова прыкладання",
      'currenttheme': "Тэма прыкладання",
      'darktheme': "Цёмная тэма",
      'lighttheme': "Светлая тэма",
      'systemtheme': "Тэма прылады",
      'blacktheme': "Чорная тэма",
      'themes': "Даступныя тэмы",
      'langs': "Даступныя мовы",
      'today': "Сёння",
      'getstarted': "Пачаць",
      'title': "BrowseR",
      'desc': "Высоўнае ніжняе меню з многімі функцыямі",
      'webprefs': "Веб налады",
      'cache': "Кэш браўзэра",
      'clear': "Ачысціць",
      'about': "Аб прыладзе"
    }
  };

  String langCode() => locale.languageCode.toString();

  String translate(key) => _localizedValues[locale.languageCode]![key]!;

  static String of(BuildContext context, String key) =>
      Localizations.of<MyLocalizations>(context, MyLocalizations)!
          .translate(key);
}

class MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalizations> {
  @override
  bool isSupported(Locale locale) =>
      ['en', 'ru', 'be'].contains(locale.languageCode);

  @override
  Future<MyLocalizations> load(Locale locale) =>
      SynchronousFuture<MyLocalizations>(MyLocalizations(locale));

  @override
  bool shouldReload(MyLocalizationsDelegate old) => false;
}
