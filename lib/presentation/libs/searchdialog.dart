import 'package:browserr/domain/utils/localization.dart';
import 'package:browserr/presentation/libs/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchPopup extends StatefulWidget {
  final WebViewController? controller;

  SearchPopup({this.controller});

  @override
  _SearchPopupState createState() => _SearchPopupState();
}

class _SearchPopupState extends State<SearchPopup>{
  static final _key = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 8.0,
            ),
            Text(MyLocalizations.of(context, 'search')),
            const SizedBox(
              height: 8.0,
            ),
            TextField(
              keyboardType: TextInputType.text,
              autocorrect: false,
              textAlign: TextAlign.start,
              autofocus: false,
              style: TextStyle(fontSize: 18.0),
              controller: _controller,
              key: _key,
              decoration: InputDecoration(
                hintText: MyLocalizations.of(context, 'search'),
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await widget.controller!.findOnPage(_controller.text.trim());
                  },
                  child: Text(
                    MyLocalizations.of(context, 'search')
                  )
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await widget.controller!.findOnPage("");
                  },
                  child: Text(
                    MyLocalizations.of(context, 'finish')
                  )
                )
              ],
            )
          ],
        ),
      )
    );
  }
}