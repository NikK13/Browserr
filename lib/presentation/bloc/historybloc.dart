import 'dart:async';
import 'package:browserr/data/repository/history_repo.dart';
import 'package:browserr/domain/model/history.dart';
import 'package:rxdart/rxdart.dart';

class HistoryBloc {
  //Get instance of the Repository
  final placesRepository = HistoryRepository();
  //Stream controller is the 'Admin' that manages
  //the state of our stream of data like adding
  //new data, change the state of the stream
  //and broadcast it to observers/subscribers

  final _items = BehaviorSubject<List<History>>();

  Stream<List<History>> get listStream => _items.stream;
  Function(List<History>) get reloadList => _items.sink.add;

  HistoryBloc(){
    getAllItems();
  }

  getAllItems({String? query}) async {
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    await reloadList(await (placesRepository.getAllItems(query: query)
    as Future<List<History>>));
  }

  addItem(History item) async {
    await placesRepository.insertItem(item);
    await getAllItems();
  }

  deleteItemByID(int id) async {
    await placesRepository.deleteItemById(id);
    await getAllItems();
  }

  deleteAllItems() async {
    await placesRepository.deleteAllItems();
    await getAllItems();
  }

  dispose() {
    _items.close();
  }
}
