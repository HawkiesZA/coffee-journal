import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:coffee_journal/create_or_edit_brew.dart';
import 'package:coffee_journal/extensions.dart';
import 'package:coffee_journal/model/brew.dart';

class MockBrew extends Mock implements Brew {}

void main() {
  group('filterUniqueVarietal', () {
    test('should return a list of Brews with unique varietals', () {
      final brews = [
        Brew(varietal: 'Varietal 1'),
        Brew(varietal: 'Varietal 2'),
        Brew(varietal: 'Varietal 1'),
        Brew(varietal: 'Varietal 3'),
      ];

      final uniqueBrews = brews.filterUniqueVarietal();

      expect(uniqueBrews.length, 3);
      expect(uniqueBrews[0].varietal, 'Varietal 1');
      expect(uniqueBrews[1].varietal, 'Varietal 2');
      expect(uniqueBrews[2].varietal, 'Varietal 3');
    });
  });

  group('CreateOrEditBrew', () {
    testWidgets('should allow entering a varietal', (WidgetTester tester) async {
      await tester.pumpWidget(CreateOrEditBrew());

      final varietalField = find.byType(RawAutocomplete).first;
      expect(varietalField, findsOneWidget);

      await tester.enterText(varietalField, 'Varietal 1');

      expect(find.text('Varietal 1'), findsOneWidget);
    });
  });
}
