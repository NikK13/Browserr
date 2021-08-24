import 'package:browserr/domain/utils/app.dart';
import 'package:flutter/material.dart';

class SettingsRow extends StatelessWidget {

  final String? title;
  final String? trailing;
  final Function? onTap;
  final IconData? icon;

  SettingsRow({
    this.title,
    this.onTap,
    this.trailing,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4
      ),
      child: Card(
        child: Container(
          width: double.infinity,
          child: InkWell(
            onTap: () => onTap!(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 12,
              ),
              child:Row(
                children: [
                  Icon(
                    icon!,
                    size: 36,
                    color: Theme.of(context).textTheme.bodyText1!.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          maxLines: 1,
                        ),
                        Text(
                          trailing!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyText1!.color
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    /*return ListTile(
      title: Text(
        title!,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontFamily: App.font,
        ),
      ),
      onTap: () => onTap!(),
      subtitle: Text(
        trailing!,
        style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: App.appColor,
            fontFamily: App.font
        ),
      ),
      leading: Icon(
        icon!,
        size: 36,
        color: Theme.of(context).textTheme.bodyText1!.color,
      ),
    );*/
  }
}

class SettingsTitle extends StatelessWidget {

  final String? title;

  SettingsTitle({this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        child: Text(
          title!,
          style: TextStyle(
            fontFamily: App.font,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyText1!.color,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

