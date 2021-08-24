import 'package:browserr/domain/model/history.dart';
import 'package:browserr/domain/utils/localization.dart';
import 'package:browserr/presentation/bloc/historybloc.dart';
import 'package:browserr/presentation/libs/webview.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WebHistory extends StatelessWidget {
  final HistoryBloc? bloc;
  final WebViewController? controller;

  WebHistory({this.bloc, this.controller});

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
                    MyLocalizations.of(context, 'history'),
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
                    final history = snapshot.data as List<History>;
                    history.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));
                    final listHistory = history.reversed.toList();
                    return Expanded(
                      child: ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index){
                          final histItem = listHistory[index];
                          final curDate = DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(histItem.timestamp!));
                          bool isShowing = false;
                          if(index > 0){
                            final prevItem = listHistory[index - 1];
                            final prevDate = DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(prevItem.timestamp!));
                            if(prevDate != curDate){
                              isShowing = true;
                            }
                          }
                          return HistoryItem(
                            bloc: bloc,
                            index: index,
                            isShowing: isShowing,
                            history: histItem,
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

class HistoryItem extends StatelessWidget{
  final int? index;
  final bool? isShowing;
  final History? history;
  final HistoryBloc? bloc;
  final WebViewController? controller;

  HistoryItem({
    this.bloc,
    this.index,
    this.history,
    this.isShowing,
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
          if(index == 0)
            Text(
              "  ${MyLocalizations.of(context, 'today')}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
          if(isShowing!)
            Text(
              "  ${DateFormat('MMMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(history!.timestamp!))}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
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
                    controller!.loadUrl(history!.url!);
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: history!.image == null
                          ?
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(30)
                            ),
                            width: 50,
                            height: 50,
                          )
                          :
                          Image.memory(
                            history!.image!,
                            width: 28,
                            height: 28,
                            fit: BoxFit.fitWidth,
                          ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              history!.title!,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                              maxLines: 1,
                            ),
                            Text(
                              history!.url!,
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
                          await bloc!.deleteItemByID(history!.id!);
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
