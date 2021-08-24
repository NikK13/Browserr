
import 'package:browserr/data/dao/dao.dart';
import 'package:browserr/domain/model/bookmark.dart';
import 'package:browserr/domain/model/history.dart';

class Repository {
  final dao = DaoOfDB();

  Future getAllHistoryItems({String? query}) => dao.getHistoryItems(query: query);

  Future insertHistoryItem(History item) => dao.createHistoryItem(item);

  Future queryHistoryRowCount(int id) => dao.queryHistoryRowCount(id);

  Future deleteHistoryItem(int id) => dao.deleteHistoryItem(id);

  Future deleteAllHistoryItems() => dao.deleteAllHistoryItems();

  Future getAllBookmarksItems({String? query}) => dao.getBookmarksItems(query: query);

  Future insertBookmarksItem(Bookmark item) => dao.createBookmarkItem(item);

  Future queryBookmarksRowCount(String url) => dao.queryBookmarksRowCount(url);

  Future deleteBookmarksItem(String url) => dao.deleteBookmarksItem(url);

  Future deleteAllBookmarksItems() => dao.deleteAllBookmarksItems();
}
