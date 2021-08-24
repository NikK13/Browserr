import 'dart:ui';

import 'package:browserr/domain/utils/app.dart';
import 'package:browserr/domain/utils/localization.dart';
import 'package:browserr/presentation/libs/settings_row.dart';
import 'package:browserr/presentation/provider/preferenceprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PreferenceProvider>(context);
    App.setupBar(Theme.of(context).brightness == Brightness.light);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      )
                    ),
                    Text(
                      MyLocalizations.of(context, 'settings'),
                      style: TextStyle(
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SettingsTitle(
                title: MyLocalizations.of(context, 'common'),
              ),
              SettingsRow(
                title: MyLocalizations.of(context, 'changelang'),
                onTap: () => showLangDialog(context, provider),
                trailing: getTitle(context),
                icon: Icons.language_rounded,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  SettingsTitle(
                    title: MyLocalizations.of(context, 'appearance'),
                  ),
                  SettingsRow(
                    title: MyLocalizations.of(context, 'currenttheme'),
                    onTap: () => showThemesDialog(context, provider),
                    trailing: provider.getThemeTitle(context),
                    icon: Icons.brightness_auto,
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }

  String getTitle(BuildContext context) {
    var lang = Localizations.localeOf(context).languageCode;
    switch (lang) {
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      case 'be':
        return 'Беларуская';
      default:
        return '';
    }
  }

  showLangDialog(BuildContext context, PreferenceProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
            child: buildLangWidget(context, provider),
          ),
        );
      },
    );
  }

  showThemesDialog(BuildContext context, PreferenceProvider provider) {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
            child: buildWidget(context, provider),
          ),
        );
      },
    );
  }

  buildWidget(BuildContext context, PreferenceProvider provider) {
    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 10),
          Text(
            MyLocalizations.of(context, 'themes'),
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Icon(
              Icons.brightness_high,
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
            title: Text(
              MyLocalizations.of(context, 'lighttheme'),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            onTap: () async {
              Navigator.pop(context);
              provider.savePreference('mode', 'light');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.brightness_4,
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
            title: Text(
              MyLocalizations.of(context, 'darktheme'),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            onTap: () async {
              Navigator.pop(context);
              provider.savePreference('mode', 'dark');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.phone_iphone,
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
            title: Text(
              MyLocalizations.of(context, 'systemtheme'),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            onTap: () async {
              Navigator.pop(context);
              provider.savePreference('mode', 'system');
            },
          )
        ],
      ),
    );
  }

  buildLangWidget(BuildContext context, PreferenceProvider provider) =>
      Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 10),
            Text(
              MyLocalizations.of(context, 'langs'),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Text(
                'EN',
                style: const TextStyle(fontSize: 18),
              ),
              title: const Text(
                'English',
                style: const TextStyle(fontWeight: FontWeight.w400),
              ),
              onTap: () async {
                Navigator.pop(context);
                provider.savePreference('language', 'en');
              },
            ),
            ListTile(
              leading: const Text('RU', style: const TextStyle(fontSize: 18)),
              title: const Text(
                'Русский',
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
              onTap: () async {
                Navigator.pop(context);
                provider.savePreference('language', 'ru');
              },
            ),
            ListTile(
              leading: const Text('BE', style: const TextStyle(fontSize: 18)),
              title: const Text(
                'Беларускi',
                style: const TextStyle(fontWeight: FontWeight.w400),
              ),
              onTap: () async {
                Navigator.pop(context);
                provider.savePreference('language', 'be');
              },
            )
          ],
        ),
      );
}
