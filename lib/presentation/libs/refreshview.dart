import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef void RefreshProgress();

class RefreshView extends StatefulWidget {
  const RefreshView({
    Key? key,
    this.onRefresh,
    this.child,
  }) : super(key: key);

  final RefreshProgress? onRefresh;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => RefreshViewState();
}

class RefreshViewState extends State<RefreshView> {

  var channel = MethodChannel('my_refresh');

  @override
  void initState() {
    channel.setMethodCallHandler(_handleMessages);
    super.initState();
  }

  Future<void> isRefreshing(isRefresh) async{
    await channel.invokeMethod("isRefreshing", isRefresh);
  }

  Future<void> childView(view) async{
    await channel.invokeMethod("childView", view!);
  }


  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: 'swiperefreshlayout',
      onPlatformViewCreated: _onPlatformViewCreated,
    );
  }

  Future<Null> _handleMessages(MethodCall call) async {
    switch (call.method) {
      case 'onRefresh':
        widget.onRefresh!();
        break;
    }
  }

  void _onPlatformViewCreated(id) {
    if (widget.onRefresh == null) {
      return;
    }
    childView(widget.child as AndroidView);
    widget.onRefresh!();
  }
}
