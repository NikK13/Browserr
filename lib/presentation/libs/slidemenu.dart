import 'package:browserr/domain/utils/app.dart';
import 'package:browserr/domain/utils/appnavigator.dart';
import 'package:browserr/domain/utils/custompage.dart';
import 'package:browserr/presentation/bloc/historybloc.dart';
import 'package:browserr/presentation/libs/webview.dart';
import 'package:browserr/presentation/ui/history.dart';
import 'package:flutter/material.dart';
import 'bottomwebbar.dart';

class SlideMenu extends StatefulWidget {
  final String? initialUrl;
  final HistoryBloc? bloc;
  final WebViewController? controller;
  final ScrollController? scrollController;

  const SlideMenu({
    @required this.scrollController,
    @required this.controller,
    @required this.initialUrl,
    @required this.bloc,
  });

  @override
  _SlideMenuState createState() => _SlideMenuState();
}

class _SlideMenuState extends State<SlideMenu> {
  late WebViewController? _controller;

  bool isDesktop = false;
  bool isForceDark = false;

  @override
  void initState() {
    _controller = widget.controller;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        children: [
          SizedBox(height: 16),
          Align(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              width: 28,
              height: 4,
            ),
            alignment: Alignment.center,
          ),
          SizedBox(height: 8),
          BottomWebBar(
            goToHistory: () async {
              await AppNavigator.of(context).push(
                CustomPage(
                    child: WebHistory(bloc: widget.bloc)
                )
              );
            },
            onBack: () async {
              if (await _controller!.canGoBack()) {
                _controller!.goBack();
              }
            },
            onForward: () async {
              await _controller!.goForward();
            },
            onHomeTap: () async {
              await _controller!.loadUrl(widget.initialUrl!);
            },
            changeMode: () async {
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
                  horizontal: 8,
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
                      onChanged: (bool value) {
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
                  horizontal: 8,
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
                      onChanged: (bool value) {
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
                        onTap: () {
                          AppNavigator.of(context).push(
                            CustomPage(
                              child: WebHistory(
                                bloc: widget.bloc,
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
  }
}
