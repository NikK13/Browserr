import 'dart:typed_data';
import 'package:browserr/domain/utils/app.dart';
import 'package:browserr/domain/utils/bloc.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

class WebBloc implements Bloc{
  final _urlBehaviour = BehaviorSubject<String?>();
  final _progressBehaviour = BehaviorSubject<int?>();

  Stream<String?> get urlStream => _urlBehaviour.stream;
  Function(String?) get setUrl => _urlBehaviour.sink.add;

  Stream<int?> get progressStream => _progressBehaviour.stream;
  Function(int?) get setProgress => _progressBehaviour.sink.add;

  @override
  void dispose() {
    _urlBehaviour.close();
    _progressBehaviour.close();
  }
}
