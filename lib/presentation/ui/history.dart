import 'package:flutter/material.dart';

class WebHistory extends StatelessWidget {
  final List<String>? history;

  const WebHistory({this.history});

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
                    "History",
                    style: TextStyle(
                      fontSize: 26,
                    ),
                  ),
                  IconButton(
                    onPressed: (){
                      history!.clear();
                    },
                    icon: Icon(
                      Icons.delete_forever_outlined,
                      color: Theme.of(context).textTheme.bodyText1!.color,
                    )
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: history!.length,
                itemBuilder: (context, index){
                  final title = history!.reversed.toList()[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  );
                },
                shrinkWrap: true,
              ),
            )
          ],
        )
      ),
    );
  }
}
