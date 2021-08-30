import 'dart:ui';
import 'package:browserr/presentation/libs/webview.dart';
import 'package:flutter/material.dart';

class ImagesDialog extends StatelessWidget {
  final WebViewController? controller;

  const ImagesDialog({this.controller});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 16),
              Text(
                "Menu preferences",
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  Icons.image,
                  color: Theme.of(context).textTheme.bodyText1!.color,
                ),
                title: Text(
                  "Download image",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await controller!.downloadImage();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.share,
                  color: Theme.of(context).textTheme.bodyText1!.color,
                ),
                title: Text(
                  "Share image",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await controller!.shareImage();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
