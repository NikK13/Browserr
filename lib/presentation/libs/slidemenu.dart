import 'dart:ui';
import 'package:browserr/domain/utils/app.dart';
import 'package:browserr/domain/utils/appnavigator.dart';
import 'package:browserr/domain/utils/custompage.dart';
import 'package:browserr/domain/utils/localization.dart';
import 'package:browserr/presentation/bloc/bookmarks_bloc.dart';
import 'package:browserr/presentation/bloc/history_bloc.dart';
import 'package:browserr/presentation/libs/searchdialog.dart';
import 'package:browserr/presentation/libs/webview.dart';
import 'package:browserr/presentation/ui/bookmarks.dart';
import 'package:browserr/presentation/ui/history.dart';
import 'package:browserr/presentation/ui/incognito.dart';
import 'package:browserr/presentation/ui/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottomwebbar.dart';

class SlideMenu extends StatefulWidget {
  final String? initialUrl;
  final HistoryBloc? bloc;
  final BookmarksBloc? bmBloc;
  final WebViewController? controller;
  final ScrollController? scrollController;

  const SlideMenu({
    @required this.scrollController,
    @required this.controller,
    @required this.initialUrl,
    @required this.bmBloc,
    @required this.bloc,
  });

  @override
  _SlideMenuState createState() => _SlideMenuState();
}

class _SlideMenuState extends State<SlideMenu> {
  late WebViewController? _controller;

  bool _isDesktop = false;
  bool _isForceDark = false;

  @override
  void initState() {
    _controller = widget.controller;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("Sheet build call");
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
        controller: widget.scrollController,
        shrinkWrap: true,
        children: [
          SizedBox(height: 8),
          BottomWebBar(
            bloc: widget.bmBloc,
            controller: _controller,
            isIncognito: false,
            onBack: () async {
              if (await _controller!.canGoBack()) {
                _controller!.goBack();
              }
            },
            onForward: () async {
              await _controller!.goForward();
            },
            onHomeTap: () async {
              print("Home tap from slide: ${_controller!.img}");
              await _controller!.loadUrl(widget.initialUrl!);
            },
            reloadPage: () async => await _controller!.reload(),
          ),
          SizedBox(height: 16),
          FutureBuilder(
            future: _controller!.getAndroidVersion(),
            builder: (context, AsyncSnapshot<int> snapshot){
              final version = snapshot.data ?? 0;
              if(version >= 29){
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                MyLocalizations.of(context, 'darkweb'),
                                style: TextStyle(
                                  fontSize: 18
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            activeColor: App.appColor,
                            value: _isForceDark,
                            onChanged: (bool value) {
                              setState(() {
                                _isForceDark = value;
                              });
                              _controller!.forceDarkEnabled(value);
                            }
                          )
                        ],
                      ),
                    )
                  ),
                );
              }
              else return SizedBox();
            },
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
                  horizontal: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MyLocalizations.of(context, 'desktopmode'),
                          style: TextStyle(
                              fontSize: 18
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      activeColor: App.appColor,
                      value: _isDesktop,
                      onChanged: (bool value) {
                        setState(() {
                          _isDesktop = value;
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
            child: Column(
              children: [
                Row(
                  children: [
                    ItemsInRow(
                      icon: Icons.history,
                      title: MyLocalizations.of(context, 'history'),
                      countRow: 2,
                      onTap: (){
                        AppNavigator.of(context).push(
                          CustomPage(
                            child: WebHistory(
                              bloc: widget.bloc,
                              controller: _controller,
                            )
                          )
                        );
                      },
                    ),
                    ItemsInRow(
                      icon: Icons.bookmark_border_rounded,
                      title: MyLocalizations.of(context, 'bookmarks'),
                      countRow: 2,
                      onTap: (){
                        AppNavigator.of(context).push(
                          CustomPage(
                            child: WebBookmarks(
                              bloc: widget.bmBloc,
                              controller: _controller,
                            )
                          )
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ItemsInRow(
                      icon: Icons.search,
                      title: MyLocalizations.of(context, 'findpage'),
                      countRow: 2,
                      onTap: (){
                        showDialog(
                          context: context,
                          builder: (context){
                            return BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                                child: SearchPopup(
                                  controller: _controller,
                                ),
                              ),
                            );
                          }
                        );
                      },
                    ),
                    ItemsInRow(
                      icon: Icons.vpn_lock_rounded,
                      title: MyLocalizations.of(context, 'incognito'),
                      countRow: 2,
                      onTap: (){
                        AppNavigator.of(context).push(
                          CustomPage(child: IncognitoPage())
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ItemsInRow(
                      icon: Icons.code,
                      title: MyLocalizations.of(context, 'sourcecode'),
                      countRow: 3,
                      onTap: () async{
                        final prefs = await SharedPreferences.getInstance();
                        await _controller!.viewSourceCode(prefs.getString("lastURL")!);
                      },
                    ),
                    ItemsInRow(
                      icon: Icons.settings,
                      title: MyLocalizations.of(context, 'settings'),
                      countRow: 3,
                      onTap: () async{
                        AppNavigator.of(context).push(
                          CustomPage(
                            child: SettingsPage(
                              controller: _controller,
                            )
                          )
                        );
                      },
                    ),
                    ItemsInRow(
                      icon: Icons.share,
                      title: MyLocalizations.of(context, 'shareurl'),
                      countRow: 3,
                      onTap: () async{
                        final prefs = await SharedPreferences.getInstance();
                        await _controller!.shareUrl(prefs.getString("lastURL")!);
                      },
                    ),
                  ],
                ),
              ],
            )
          )
        ],
      ),
    );
  }
}

class ItemsInRow extends StatelessWidget {
  final int? countRow;
  final IconData? icon;
  final String? title;
  final Function? onTap;

  const ItemsInRow({
    this.icon,
    this.title,
    this.onTap,
    this.countRow,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.2,
        child: Card(
          child: InkWell(
            onTap: () => onTap!(),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: MediaQuery
                        .of(context)
                        .size
                        .width / 10,
                    color: Theme
                        .of(context)
                        .textTheme
                        .bodyText1!
                        .color,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: countRow == 3 ? 16 : 20,
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            ),
          )
        ),
      )
    );
  }
}

