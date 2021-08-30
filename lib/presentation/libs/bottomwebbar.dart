import 'package:browserr/domain/model/bookmark.dart';
import 'package:browserr/presentation/bloc/bookmarks_bloc.dart';
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
  final bool? isIncognito;

  const BottomWebBar({
    this.onBack,
    this.onForward,
    this.onHomeTap,
    this.reloadPage,
    this.controller,
    this.isIncognito,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height / 15;
    print("BottomBar build call: $isIncognito");
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
          !isIncognito!
          ?
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
                      image: controller!.img,
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
          )
          :
          IconButton(
            onPressed: () async {
              controller!.isIncognitoMode(false);
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.close,
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
          IconButton(
            onPressed: () async => await reloadPage!(),
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
          ),
        ],
      ),
    );
  }
}
