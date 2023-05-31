import 'package:coffee_journal/bloc/ibrew_bloc.dart';
import 'package:coffee_journal/model/brew.dart';
import 'package:coffee_journal/repository/brew_repository.dart';

import 'dart:async';
import 'dart:developer' as developer;

class BrewBloc extends IBrewBloc {
  //Get instance of the Repository
  final _brewRepository = BrewRepository();

  BrewBloc();

  Future<Brew> getBrewById(String id) async {
    return await _brewRepository.getBrewById(id);
  }

  Future<Brew> getBrewByRoasterAndBlend(String? roaster, String? blend) async {
    return await _brewRepository.getBrewByRoasterAndBlend(roaster, blend);
  }

  getBrews() async {
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    developer.log("Getting all brews");
    brewController.sink.add(await _brewRepository.getAllBrews());
  }

  searchBrews({required String query}) async {
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    developer.log("Searching brews");
    brewController.sink.add(await _brewRepository.searchBrews(query: query));
  }

  Future<void> addBrew(Brew brew) async {
    developer.log("Adding brew");
    var result = await _brewRepository.insertBrew(brew);
    getBrews();
    developer.log("Brew inserted");
    return result;
  }

  updateBrew(Brew brew) async {
    await _brewRepository.updateBrew(brew);
    getBrews();
  }

  deleteBrewById(String id) async {
    await _brewRepository.deleteBrewById(id);
    getBrews();
  }
}