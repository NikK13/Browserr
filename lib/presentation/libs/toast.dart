import 'package:flutter/services.dart';

class Toast{
  static const platform = const MethodChannel('flutter.toast');

  Toast(String message) {
    _showToast(message);
  }

  Future _showToast(String message) async {
    // invoke method, provide method name and arguments.
    await platform.invokeMethod('toast', {'message': message});
  }

}