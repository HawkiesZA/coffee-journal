import 'package:coffee_journal/model/brew.dart';
import 'package:coffee_journal/repository/brew_repository.dart';

import 'dart:async';
import 'dart:developer' as developer;

class BrewBloc {
  //Get instance of the Repository
  final _brewRepository = BrewRepository();
  final _brewController = StreamController<List<Brew>>.broadcast();

  get brews => _brewController.stream;

  BrewBloc() {
    getBrews();
  }

  Future<Brew> getBrewById(int id) async {
    return await _brewRepository.getBrewById(id);
  }

  Future<Brew> getBrewByRoasterAndBlend(String? roaster, String? blend) async {
    return await _brewRepository.getBrewByRoasterAndBlend(roaster, blend);
  }

  getBrews({String? query}) async {
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    developer.log("Getting all brews with query $query");
    _brewController.sink.add(await _brewRepository.getAllBrews(query: query));
  }

  Future<int> addBrew(Brew brew) async {
    developer.log("Adding brew");
    var result = await _brewRepository.insertBrew(brew);
    getBrews();
    developer.log("Brew inserted with result $result");
    return result;
  }

  updateBrew(Brew brew) async {
    await _brewRepository.updateBrew(brew);
    getBrews();
  }

  deleteBrewById(int id) async {
    await _brewRepository.deleteBrewById(id);
    getBrews();
  }

  dispose() {
    developer.log("disposing brewController");
    _brewController.close();
  }
}