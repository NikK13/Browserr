
import 'package:browserr/data/dao/history_dao.dart';
import 'package:browserr/domain/model/history.dart';

class HistoryRepository {
  final historyDao = HistoryDao();

  Future getAllItems({String? query}) => historyDao.getItems(query: query);

  Future insertItem(History item) => historyDao.createItem(item);

  Future queryRowCount(int id) => historyDao.queryRowCount(id);

  Future deleteItemById(int id) => historyDao.deleteItem(id);

  Future deleteAllItems() => historyDao.deleteAllItems();
}
