import 'dart:ui';
import 'package:browserr/domain/utils/app.dart';
import 'package:browserr/domain/utils/localization.dart';
import 'package:browserr/presentation/bloc/bloc_provider.dart';
import 'package:browserr/presentation/bloc/cache_bloc.dart';
import 'package:browserr/presentation/libs/settings_row.dart';
import 'package:browserr/presentation/libs/webview.dart';
import 'package:browserr/presentation/provider/preferenceprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget{
  final WebViewController? controller;

  SettingsPage({
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final _cacheBloc = CacheBloc(controller!);
    final _provider = Provider.of<PreferenceProvider>(context);
    App.setupBar(Theme.of(context).brightness == Brightness.light);
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          bloc: _cacheBloc,
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
                  onTap: () => showLangDialog(context, _provider),
                  trailing: getTitle(context),
                  icon: Icons.language_rounded,
                ),
                SettingsRow(
                  title: MyLocalizations.of(context, 'about'),
                  onTap: (){
                    showAboutDialog(
                      context: context,
                      applicationName: 'BrowseR',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '©2021 NK',
                    );
                  },
                  trailing: MyLocalizations.of(context, 'about'),
                  icon: Icons.info_outline_rounded,
                ),
                const SizedBox(height: 24),
                SettingsTitle(
                  title: MyLocalizations.of(context, 'appearance'),
                ),
                SettingsRow(
                  title: MyLocalizations.of(context, 'currenttheme'),
                  onTap: () => showThemesDialog(context, _provider),
                  trailing: _provider.getThemeTitle(context),
                  icon: Icons.brightness_auto,
                ),
                const SizedBox(height: 24),
                SettingsTitle(
                  title: MyLocalizations.of(context, 'webprefs'),
                ),
                StreamBuilder(
                  stream: _cacheBloc.cacheStream,
                  builder: (context, AsyncSnapshot<int> snapshot){
                    int bytes = snapshot.data ?? 0;
                    print("Stream re-run $bytes");
                    return SettingsRow(
                      title: MyLocalizations.of(context, 'cache'),
                      onTap: () async {
                        await _cacheBloc.clearCache(controller!);
                      },
                      trailing: bytesIntoFormat(bytes),
                      icon: Icons.analytics_outlined,
                    );
                  },
                ),
              ],
            ),
          ),
        )
      )
    );
  }

  String bytesIntoFormat(int bytes) {
    int kilobyte = 1024;
    int megabyte = kilobyte * 1024;
    int gigabyte = megabyte * 1024;
    int terabyte = gigabyte * 1024;

    if ((bytes >= 0) && (bytes < kilobyte)) {
      return "${bytes.toStringAsFixed(2)} B";

    } else if ((bytes >= kilobyte) && (bytes < megabyte)) {
      return  "${(bytes / kilobyte).toStringAsFixed(2)} KB";

    } else if ((bytes >= megabyte) && (bytes < gigabyte)) {
      return  "${(bytes / megabyte).toStringAsFixed(2)} MB";

    } else if ((bytes >= gigabyte) && (bytes < terabyte)) {
      return  "${(bytes / gigabyte).toStringAsFixed(2)} GB";

    } else if (bytes >= terabyte) {
      return  "${(bytes / terabyte).toStringAsFixed(2)} TB";

    } else {
      return  "${bytes.toStringAsFixed(2)} Bytes";
    }
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