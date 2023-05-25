import 'package:coffee_journal/dao/brew_dao.dart';
import 'package:coffee_journal/model/brew.dart';
class BrewRepository {
  final brewDao = BrewDao();

  Future getBrewById(String id) => brewDao.getBrewById(id);

  Future getBrewByRoasterAndBlend(String? roaster, String? blend) => brewDao.getBrewByRoasterAndBlend(roaster, blend);

  Future getAllBrews() => brewDao.getBrews();

  // TODO: remove this in the next version
  Future getBrewsSqlite() => brewDao.getBrewsSqlite();
  Future deleteBrewSqlite(String id) => brewDao.deleteBrewSqlite(id);

  Future searchBrews({required String query}) => brewDao.searchBrews(query: query);

  Future<void> insertBrew(Brew brew) => brewDao.createBrew(brew);

  Future updateBrew(Brew brew) => brewDao.updateBrew(brew);

  Future deleteBrewById(String id) => brewDao.deleteBrew(id);
}