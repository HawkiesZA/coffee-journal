import 'package:coffee_journal/brew_details.dart';
import 'package:coffee_journal/extensions.dart';
import 'package:coffee_journal/model/brew.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BrewDetails displays correctly', (tester) async {
    Brew fakeBrew = Brew(
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
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
            settings: RouteSettings(arguments: fakeBrew),
            builder: (context) { return BrewDetails(); }
        );
      },
    ));

    final titleFinder = find.text('Details for ${fakeBrew.roaster}');
    expect(titleFinder, findsOneWidget);

    final headingFinder = find.text('${fakeBrew.blend}');
    expect(headingFinder, findsOneWidget);

    final roastedFinder = find.text('roasted ${fakeBrew.roastProfile} by ${fakeBrew.roaster}');
    expect(roastedFinder, findsOneWidget);

    final doseFinder = find.text('${fakeBrew.dose} ${fakeBrew.doseMeasurement} ${fakeBrew.grindSize} ground brewed with');
    expect(doseFinder, findsOneWidget);

    final waterFinder = find.text('${fakeBrew.water} ${fakeBrew.waterMeasurement} water for');
    expect(waterFinder, findsOneWidget);

    final durationFinder = find.text('${Duration(seconds: fakeBrew.duration ?? 0).strFormat()}');
    expect(durationFinder, findsOneWidget);

    final methodFinder = find.text('${fakeBrew.method} at');
    expect(methodFinder, findsOneWidget);

    final timeFinder = find.text('${DateTime.fromMillisecondsSinceEpoch(fakeBrew.time ?? 0, isUtc: true).format()}');
    expect(timeFinder, findsOneWidget);
  });
}