import 'dart:async';

import '../model/brew.dart';

abstract class IBrewBloc {
  final brewController = StreamController<List<Brew>>.broadcast();

  get brews => brewController.stream;

  Future<Brew> getBrewById(String id);

  Future<Brew> getBrewByRoasterAndBlend(String? roaster, String? blend);

  getBrews();

  searchBrews({required String query});

  Future<void> addBrew(Brew brew);

  updateBrew(Brew brew);

  deleteBrewById(String id);

  dispose() {
    brewController.close();
  }
}