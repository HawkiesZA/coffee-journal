import 'package:coffee_journal/dao/brew_dao.dart';
import 'package:coffee_journal/model/brew.dart';
class BrewRepository {
  final brewDao = BrewDao();

  Future getBrewById(int id) => brewDao.getBrewById(id);

  Future getBrewByRoasterAndBlend(String? roaster, String? blend) => brewDao.getBrewByRoasterAndBlend(roaster, blend);

  Future getAllBrews({ List<String>? columns, String? query }) => brewDao.getBrews(columns: columns, query: query);

  Future<int> insertBrew(Brew brew) => brewDao.createBrew(brew);

  Future updateBrew(Brew brew) => brewDao.updateBrew(brew);

  Future deleteBrewById(int id) => brewDao.deleteBrew(id);
}