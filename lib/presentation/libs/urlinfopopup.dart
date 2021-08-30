import 'package:flutter/material.dart';

class UrlInfoPopup extends StatelessWidget {

  final String? url;

  final titleNotProtected = "Your connection to this website is not protected";
  final descNotProtected = "You should not enter sensitive data on this site (e.g. passwords or credit cards) because they could be intercepted by malicious users.";

  final titleIsProtected = "Your connection is protected";
  final descIsProtected = "Your sensitive data (e.g. passwords or credit card numbers) remains private when it is sent to this site.";

  UrlInfoPopup({this.url});

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
            Icon(
              Icons.lock,
              color: url!.contains("https") ?
              Colors.green :
              Colors.grey,
              size: 16,
            ),
            Container(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text(
                url!.contains("https") ? titleIsProtected : titleNotProtected,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              child: Text(
                url!.contains("https")
                ? descIsProtected
                : descNotProtected,
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              )
            ),
            const SizedBox(
              height: 16.0,
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text(
                "Close"
              )
            )
          ],
        ),
      )
    );
  }
}