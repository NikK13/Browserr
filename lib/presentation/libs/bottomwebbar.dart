import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomWebBar extends StatelessWidget {
  final Function? onBack;
  final Function? goToHistory;
  final Function? onForward;
  final Function? onHomeTap;
  final Function? changeMode;
  final Function? reloadPage;
  final Function? forceDark;

  const BottomWebBar({
    this.onBack,
    this.onForward,
    this.onHomeTap,
    this.changeMode,
    this.reloadPage,
    this.forceDark,
    this.goToHistory,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height / 15;
    return Container(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () async => await onHomeTap!(),
            icon: Icon(
              Icons.home_outlined,
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
          ),
          IconButton(
            onPressed: () async => await onBack!(),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
          ),
          IconButton(
            onPressed: (){

            },
            icon: Icon(
              Icons.add_to_photos_outlined,
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
          ),
          IconButton(
            onPressed: () async => await onForward!(),
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
          ),
          PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)
            ),
            onSelected: (int index) async{
              switch(index){
                case 1:
                  await goToHistory!();
                  break;
                case 3:
                  await changeMode!();
                  break;
                case 4:
                  await reloadPage!();
                  break;
                case 5:
                  await forceDark!();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: Theme.of(context).textTheme.bodyText1!.color,
                    ),
                    const SizedBox(width: 8),
                    Text("History"),
                  ],
                ),
                value: 1,
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      Icons.bookmark_outline,
                      color: Theme.of(context).textTheme.bodyText1!.color,
                    ),
                    const SizedBox(width: 8),
                    Text("Bookmarks"),
                  ],
                ),
                value: 2,
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      Icons.desktop_windows_outlined,
                      color: Theme.of(context).textTheme.bodyText1!.color,
                    ),
                    const SizedBox(width: 8),
                    Text("Change web mode"),
                  ],
                ),
                value: 3,
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      Icons.refresh,
                      color: Theme.of(context).textTheme.bodyText1!.color,
                    ),
                    const SizedBox(width: 8),
                    Text("Reload page"),
                  ],
                ),
                value: 4,
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      Icons.dark_mode,
                      color: Theme.of(context).textTheme.bodyText1!.color,
                    ),
                    const SizedBox(width: 8),
                    Text("Force Dark Mode"),
                  ],
                ),
                value: 5,
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: Theme.of(context).textTheme.bodyText1!.color,
                    ),
                    const SizedBox(width: 8),
                    Text("Settings"),
                  ],
                ),
                value: 6,
              )
            ],
            icon: Icon(
              Icons.more_horiz,
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
          ),
        ],
      ),
    );
  }
}
