import 'package:browserr/domain/utils/bloc.dart';
import 'package:flutter/material.dart';

class BlocProvider<T extends Bloc> extends StatefulWidget{
  final T? bloc;
  final Widget? child;
  BlocProvider({@required this.bloc, @required this.child});

  static T of<T extends Bloc>(BuildContext context){
    final BlocProvider<T>? provider = context.findAncestorWidgetOfExactType<BlocProvider<T>>();
    return provider!.bloc!;
  }

  State createState() => _BlocProviderState();
}

class _BlocProviderState extends State<BlocProvider>{
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }

  @override
  void dispose() {
    widget.bloc!.dispose();
    super.dispose();
  }
}