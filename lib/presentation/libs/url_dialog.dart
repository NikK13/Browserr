import 'package:browserr/domain/utils/localization.dart';
import 'package:browserr/presentation/libs/webview.dart';
import 'package:flutter/material.dart';

class UrlPopup extends StatefulWidget {
  final WebViewController? controller;
  final String? url;

  UrlPopup({this.controller, this.url});

  @override
  _UrlPopupState createState() => _UrlPopupState();
}

class _UrlPopupState extends State<UrlPopup>{
  static final _key = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller.text = widget.url!;
    super.initState();
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
              onSubmitted: (text) async {
                final url = _controller.text.trim();
                if(url.isNotEmpty){
                  Navigator.pop(context);
                  await widget.controller!.loadUrl(url);
                }
                else Navigator.pop(context);
              },
              decoration: InputDecoration(
                hintText: MyLocalizations.of(context, 'search'),
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final url = _controller.text.trim();
                  if(url.isNotEmpty){
                    Navigator.pop(context);
                    await widget.controller!.loadUrl(url);
                  }
                  else Navigator.pop(context);
                },
                child: Text(
                    "Search all"
                )
              ),
            )
          ],
        ),
      )
    );
  }
}
