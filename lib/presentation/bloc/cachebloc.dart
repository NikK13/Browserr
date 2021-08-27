import 'package:browserr/domain/utils/bloc.dart';
import 'package:browserr/presentation/libs/webview.dart';
import 'package:rxdart/rxdart.dart';

class CacheBloc implements Bloc{
  final _cacheSize = BehaviorSubject<int>();
  final _clearedCacheSize = 32223;

  Stream<int> get cacheStream => _cacheSize.stream;
  Function(int) get refreshCache => _cacheSize.sink.add;

  Future clearCache(WebViewController controller) async{
    await controller.clearCache();
    refreshCache(_clearedCacheSize);
  }

  @override
  void dispose(){
    _cacheSize.close();
  }
}