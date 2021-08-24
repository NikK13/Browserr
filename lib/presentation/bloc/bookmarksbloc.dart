import 'dart:async';
import 'package:browserr/data/repository/repository.dart';
import 'package:browserr/domain/model/bookmark.dart';
import 'package:rxdart/rxdart.dart';

class BookmarksBloc {
  //Get instance of the Repository
  final repository = Repository();
  //Stream controller is the 'Admin' that manages
  //the state of our stream of data like adding
  //new data, change the state of the stream
  //and broadcast it to observers/subscribers

  final _liked = BehaviorSubject<bool>();
  final _items = BehaviorSubject<List<Bookmark>>();

  Stream<List<Bookmark>> get listStream => _items.stream;
  Stream<bool> get isLikedStream => _liked.stream;

  Function(List<Bookmark>) get reloadList => _items.sink.add;
  Function(bool) get changeLikedTo => _liked.sink.add;

  BookmarksBloc(){
    getAllItems();
  }

  initialize(String? item) {
    if (item != null) initItemWithDB(item);
    //getAllItems();
  }

  initItemWithDB(String item) async {
    final res = await queryCount(item);
    final isLiked = res > 0 ? true : false;
    await changeLikedTo(isLiked);
  }

  queryCount(String url) async {
    var res = await repository.queryBookmarksRowCount(url);
    await getAllItems();
    //print("$res");
    return res;
  }

  getAllItems({String? query}) async {
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    await reloadList(await (repository.getAllBookmarksItems(query: query)
    as Future<List<Bookmark>>));
  }

  addItem(Bookmark item) async {
    await repository.insertBookmarksItem(item);
    await getAllItems();
  }

  deleteItem(String url) async {
    await repository.deleteBookmarksItem(url);
    await getAllItems();
  }

  deleteAllItems() async {
    await repository.deleteAllBookmarksItems();
    await getAllItems();
  }

  dispose() {
    _items.close();
    _liked.close();
  }
}
