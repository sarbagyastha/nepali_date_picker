import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';

import 'material/date_picker.dart';

/// A date picker dialog that allows users to select a date.
class FusedDatePickerDialog extends StatefulWidget {
  /// Creates a date picker dialog.
  const FusedDatePickerDialog({
    super.key,
    required this.firstDate,
    required this.lastDate,
  });

  /// The first allowable date.
  final DateTime firstDate;

  /// The last allowable date.
  final DateTime lastDate;

  @override
  State<FusedDatePickerDialog> createState() => _FusedDatePickerDialogState();
}

class _FusedDatePickerDialogState extends State<FusedDatePickerDialog> {
  CalendarMode _mode = CalendarMode.bs;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _AdBsToggle(
          onChanged: (mode) {
            _mode = mode;
            setState(() {});
          },
        ),
        switch (_mode) {
          CalendarMode.ad => DatePickerDialog(
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              currentDate: _selectedDate,
            ),
          CalendarMode.bs => NepaliDatePickerDialog(
              initialDate: NepaliDateTime.now(),
              firstDate: widget.firstDate.toNepaliDateTime(),
              lastDate: widget.lastDate.toNepaliDateTime(),
              onDateChanged: (date) {
                _selectedDate = date.toDateTime();
              },
            ),
        }
      ],
    );
  }
}

/// The mode of the calendar.
enum CalendarMode {
  /// Bikram Sambat calendar.
  bs,

  /// Gregorian calendar.
  ad
}

class _AdBsToggle extends StatefulWidget {
  const _AdBsToggle({required this.onChanged});

  final ValueChanged<CalendarMode> onChanged;

  @override
  State<_AdBsToggle> createState() => _AdBsToggleState();
}

class _AdBsToggleState extends State<_AdBsToggle> {
  CalendarMode _selectedMode = CalendarMode.bs;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: OverflowBar(
          children: [
            FilledButton(
              style: _getStyle(CalendarMode.ad),
              onPressed: () {
                _selectedMode = CalendarMode.ad;
                setState(() {});
                widget.onChanged(_selectedMode);
              },
              child: Text('AD'),
            ),
            FilledButton(
              style: _getStyle(CalendarMode.bs),
              onPressed: () {
                _selectedMode = CalendarMode.bs;
                setState(() {});
                widget.onChanged(_selectedMode);
              },
              child: Text('BS'),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _getStyle(CalendarMode mode) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FilledButton.styleFrom(
      backgroundColor: _selectedMode == mode
          ? theme.colorScheme.primary
          : theme.colorScheme.surfaceContainerHighest,
      foregroundColor:
          _selectedMode == mode ? colorScheme.onPrimary : colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(mode == CalendarMode.ad ? 50 : 0),
          right: Radius.circular(mode == CalendarMode.bs ? 50 : 0),
        ),
      ),
    );
  }
}

/// Shows a dialog containing a date picker.
Future<DateTime?> showFusedDatePickerDialog({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      return Localizations.override(
        context: context,
        child: FusedDatePickerDialog(
          firstDate: firstDate,
          lastDate: lastDate,
        ),
      );
    },
  );
}
