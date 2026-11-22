import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

class _MondayFirstLocalizations extends DefaultMaterialLocalizations {
  const _MondayFirstLocalizations();

  @override
  int get firstDayOfWeekIndex => 1;
}

void main() {
  const delegate = NepaliCalendarDelegate();
  const sundayFirst = DefaultMaterialLocalizations();
  const mondayFirst = _MondayFirstLocalizations();

  group('firstDayOffset', () {
    // 2081-01-01 BS (2024-04-13 AD) is a Saturday.
    test('week starting Sunday', () {
      expect(delegate.firstDayOffset(2081, 1, sundayFirst), 6);
    });

    test('week starting Monday', () {
      expect(delegate.firstDayOffset(2081, 1, mondayFirst), 5);
    });
  });

  group('parseCompactDate', () {
    test('parses a valid date', () {
      expect(
        delegate.parseCompactDate('2081-01-15', sundayFirst),
        NepaliDateTime(2081, 1, 15),
      );
    });

    test('rejects out-of-range days and bad formats', () {
      expect(delegate.parseCompactDate('2081-01-33', sundayFirst), isNull);
      expect(delegate.parseCompactDate('2081-1-5', sundayFirst), isNull);
      expect(delegate.parseCompactDate(null, sundayFirst), isNull);
    });
  });

  test('addMonthsToMonthDate rolls over years', () {
    final date = delegate.addMonthsToMonthDate(NepaliDateTime(2080, 11), 3);
    expect((date.year, date.month), (2081, 2));
  });

  testWidgets('NepaliCupertinoDatePicker renders in both languages', (
    tester,
  ) async {
    for (final language in Language.values) {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: NepaliCupertinoDatePicker(
              initialDate: NepaliDateTime(2081, 1, 1),
              language: language,
              onDateChanged: (_) {},
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
