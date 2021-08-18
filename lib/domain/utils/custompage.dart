import 'package:browserr/domain/utils/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CustomPage<T> extends Page<T> {
  const CustomPage({
    LocalKey? key,
    String? name,
    @required this.child,
  }) : super(key: key, name: name);

  final Widget? child;

  @override
  Route<T> createRoute(BuildContext context) {
    switch(App.platform){
      case "android":
        return MaterialPageRoute(
          settings: this,
          builder: (context) => child!,
        );
      case "ios":
        return CupertinoPageRoute(
          settings: this,
          builder: (context) => child!,
        );
      default:
        return MaterialPageRoute(
          settings: this,
          builder: (context) => child!,
        );
    }
  }

  @override
  String toString() => '$name';
}
