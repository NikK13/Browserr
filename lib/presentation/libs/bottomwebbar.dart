import 'package:browserr/domain/model/bookmark.dart';
import 'package:browserr/presentation/bloc/bookmarksbloc.dart';
import 'package:browserr/presentation/libs/webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomWebBar extends StatelessWidget {
  final Function? onBack;
  final Function? onForward;
  final Function? onHomeTap;
  final Function? reloadPage;
  final BookmarksBloc? bloc;
  final WebViewController? controller;

  const BottomWebBar({
    this.onBack,
    this.onForward,
    this.onHomeTap,
    this.reloadPage,
    this.controller,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height / 15;
    print("BottomBar build call");
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
          StreamBuilder(
            stream: bloc!.isLikedStream,
            builder: (context, AsyncSnapshot<bool> snapshot){
              final notNull = snapshot.data != null;
              bool isLiked = notNull ? snapshot.data! : false;
              //print(isLiked);
              return IconButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await bloc!.changeLikedTo(
                    isLiked ? false : true,
                  );
                  isLiked
                  ?
                  await bloc!.deleteItem(prefs.getString("lastURL")!)
                  :
                  await bloc!.addItem(
                    Bookmark(
                      title: await controller!.getTitle(),
                      url: prefs.getString("lastURL")!,
                      timestamp: DateTime.now().millisecondsSinceEpoch,
                      image: controller!.image,
                    )
                  );
                  //await bloc.getPlaces();
                },
                icon: Icon(
                  notNull
                  ?
                  (isLiked ? Icons.favorite : Icons.favorite_outline)
                  :
                  Icons.favorite_outline,
                  color: Theme.of(context).textTheme.bodyText1!.color,
                ),
              );
            },
          ),
          IconButton(
            onPressed: () async => await onForward!(),
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
          ),
          IconButton(
            onPressed: () async => await reloadPage!(),
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
          ),
          /*PopupMenuButton(
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
          ),*/
        ],
      ),
    );
  }
}
