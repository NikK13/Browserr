import 'package:browserr/domain/model/bookmark.dart';
import 'package:browserr/domain/utils/localization.dart';
import 'package:browserr/presentation/bloc/bookmarksbloc.dart';
import 'package:browserr/presentation/libs/webview.dart';
import 'package:flutter/material.dart';

class WebBookmarks extends StatelessWidget {
  final BookmarksBloc? bloc;
  final WebViewController? controller;

  WebBookmarks({this.bloc, this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
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
                      MyLocalizations.of(context, 'bookmarks'),
                      style: TextStyle(
                        fontSize: 26,
                      ),
                    ),
                    IconButton(
                      onPressed: () async{
                        await bloc!.deleteAllItems();
                      },
                      icon: Icon(
                        Icons.delete_forever_outlined,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      )
                    ),
                  ],
                ),
              ),
              StreamBuilder(
                stream: bloc!.listStream,
                builder: (context, AsyncSnapshot snapshot){
                  //print(snapshot.connectionState);
                  if(snapshot.connectionState == ConnectionState.active){
                    if(snapshot.data != null){
                      final bookmarks = snapshot.data as List<Bookmark>;
                      final listBookmarks = bookmarks.reversed.toList();
                      return Expanded(
                        child: ListView.builder(
                          itemCount: bookmarks.length,
                          itemBuilder: (context, index){
                            return BookmarksItem(
                              bloc: bloc,
                              bookmark: listBookmarks[index],
                              controller: controller,
                            );
                          },
                          shrinkWrap: true,
                        ),
                      );
                    }
                    else return Container();
                  }
                  else return Container();
                },
              )
            ],
          )
      ),
    );
  }
}

class BookmarksItem extends StatelessWidget{
  final Bookmark? bookmark;
  final BookmarksBloc? bloc;
  final WebViewController? controller;

  BookmarksItem({
    this.bloc,
    this.bookmark,
    this.controller,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: InkWell(
                  onTap: (){
                    Navigator.of(context).pop();
                    controller!.loadUrl(bookmark!.url!);
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: bookmark!.image == null
                        ?
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.red,
                                Colors.blue,
                              ]
                            ),
                            borderRadius: BorderRadius.circular(8)
                          ),
                          width: 28,
                          height: 28,
                          child: Center(
                            child: Text(
                              bookmark!.title![0],
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          )
                        )
                        :
                        Image.memory(
                          bookmark!.image!,
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bookmark!.title!,
                              style: TextStyle(
                                fontSize: 17,
                              ),
                              maxLines: 1,
                            ),
                            Text(
                              bookmark!.url!,
                              style: TextStyle(
                                fontSize: 10,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async{
                          await bloc!.deleteItem(bookmark!.url!);
                        },
                        icon: Icon(
                          Icons.clear,
                          color: Theme.of(context).textTheme.bodyText1!.color,
                        ),
                      )
                    ],
                  ),
                )
              ),
            )
          ),
        ],
      ),
    );
  }
}
