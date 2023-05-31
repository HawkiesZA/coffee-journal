import 'package:coffee_journal/bloc/ibrew_bloc.dart';
import 'package:coffee_journal/extensions.dart';
import 'package:coffee_journal/main.dart';
import 'package:coffee_journal/model/brew.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class FakeBloc extends IBrewBloc {
  List<Brew> nextBrews = [];
  bool searchCalled = false;
  bool deleteCalled = false;
  bool getBrewByIdCalled = false;
  bool getBrewByRoasterAndBlendCalled = false;
  bool updateBrewCalled = false;

  FakeBloc() {
    this.searchCalled = false;
    this.deleteCalled = false;
    this.getBrewByIdCalled = false;
    this.updateBrewCalled = false;
  }

  @override
  Future<void> addBrew(Brew brew) async {
    nextBrews.add(brew);
  }

  @override
  deleteBrewById(String id) {
    deleteCalled = true;
  }

  @override
  Future<Brew> getBrewById(String id) async {
    getBrewByIdCalled = true;
    return Brew();
  }

  @override
  Future<Brew> getBrewByRoasterAndBlend(String? roaster, String? blend) async {
    getBrewByRoasterAndBlendCalled = true;
    return Brew();
  }

  @override
  getBrews() {
    brewController.sink.add(nextBrews);
  }

  @override
  searchBrews({required String query}) {
    searchCalled = true;
  }

  @override
  updateBrew(Brew brew) {
    updateBrewCalled = true;
  }
}

void main() {
  testWidgets('No brews displays correctly', (tester) async {
    FakeBloc fakeBloc = FakeBloc();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MyApp(brewBloc: fakeBloc, firebaseAuth: auth, signInWithGoogle: () => {}));

    await tester.pumpAndSettle();

    final titleFinder = find.text("No brews yet. Let's brew some coffee!");
    expect(titleFinder, findsOneWidget);
  });

  testWidgets('BrewDetails displays correctly', (tester) async {
    Brew fakeBrew = Brew(
      id: 'fakeId',
      roaster: 'Bluebird',
      blend: 'Volcan Azul',
      roastProfile: 'Light',
      method: 'FakeOPress',
      grindSize: 'Massive',
      dose: 20,
      doseMeasurement: 'g',
      water: 200,
      waterMeasurement: 'g',
      duration: 120,
      time: 1640979000000, // 2022-01-01 10:00:00.000Z
    );
    FakeBloc fakeBloc = FakeBloc();
    fakeBloc.nextBrews.add(fakeBrew);
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MyApp(brewBloc: fakeBloc, firebaseAuth: auth, signInWithGoogle: () => {},));

    final loadingFinder = find.text('Loading...');
    expect(loadingFinder, findsOneWidget);

    await tester.pumpAndSettle();

    final titleFinder = find.text('${fakeBrew.roaster}: ${fakeBrew.blend}', findRichText: true);
    expect(titleFinder, findsOneWidget);

    final methodFinder = find.text('${fakeBrew.method}: ${fakeBrew.grindSize}', findRichText: true);
    expect(methodFinder, findsOneWidget);

    final waterMeasurementFinder = find.textContaining('${fakeBrew.water} ${fakeBrew.waterMeasurement}', findRichText: true);
    expect(waterMeasurementFinder, findsOneWidget);
    final waterIconFinder = find.byIcon(Icons.water);
    expect(waterIconFinder, findsOneWidget);

    final doseMeasurementFinder = find.textContaining('${fakeBrew.dose} ${fakeBrew.doseMeasurement}', findRichText: true);
    expect(doseMeasurementFinder, findsOneWidget);
    final coffeeIconFinder = find.byIcon(Icons.coffee);
    expect(coffeeIconFinder, findsNWidgets(2)); // one for the card & one for the fab

    final durationFinder = find.text('02:00');
    expect(durationFinder, findsOneWidget);

    final timeFinder = find.text('${DateTime.fromMillisecondsSinceEpoch(fakeBrew.time!, isUtc: true).format()}');
    expect(timeFinder, findsOneWidget);

    final searchIconFinder = find.byIcon(Icons.search);
    expect(searchIconFinder, findsOneWidget);
    final homeIconFinder = find.byIcon(Icons.home);
    expect(homeIconFinder, findsOneWidget);
    final settingsIconFinder = find.byIcon(Icons.settings);
    expect(settingsIconFinder, findsOneWidget);
  });
}