// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import 'package:nepali_date_picker/nepali_date_picker.dart';

enum _ConversionDirection { adToBs, bsToAd }

final _bsFirstDate = NepaliDateTime(1970, 2, 5);
final _bsLastDate = NepaliDateTime(2250, 11, 6);

String _isoDate(int year, int month, int day) =>
    '${year.toString().padLeft(4, '0')}-'
    '${month.toString().padLeft(2, '0')}-'
    '${day.toString().padLeft(2, '0')}';

/// Date Converter Example
class const DateConverterWidget({super.key}) extends StatefulWidget {
  @override
  State<DateConverterWidget> createState() => _DateConverterWidgetState();
}

class _DateConverterWidgetState extends State<DateConverterWidget> {
  _ConversionDirection _direction = .adToBs;
  var _adDate = DateTime.now();
  var _bsDate = NepaliDateTime.now();

  late final _adFirstDate = _bsFirstDate.toDateTime();
  late final _adLastDate = _bsLastDate.toDateTime();

  late final _dateController = TextEditingController(text: _currentInputText);
  String? _inputError;

  String get _currentInputText => _direction == .adToBs
      ? _isoDate(_adDate.year, _adDate.month, _adDate.day)
      : _isoDate(_bsDate.year, _bsDate.month, _bsDate.day);

  void _syncInputField() {
    _inputError = null;
    _dateController.text = _currentInputText;
  }

  void _onCalendarDateChanged(DateTime date) {
    setState(() {
      if (_direction == .adToBs) {
        _adDate = date;
        _bsDate = _adDate.toNepaliDateTime();
      } else {
        _bsDate = date as NepaliDateTime;
        _adDate = _bsDate.toDateTime();
      }
      _syncInputField();
    });
  }

  void _onTypedDateChanged(String text) {
    if (_direction == .adToBs) {
      final parsed = DateTime.tryParse(text.trim());
      if (parsed == null) {
        setState(() => _inputError = 'Enter a valid date as yyyy-mm-dd');
        return;
      }
      if (parsed.isBefore(_adFirstDate) || parsed.isAfter(_adLastDate)) {
        setState(() => _inputError = 'Date is out of the supported range');
        return;
      }
      setState(() {
        _adDate = parsed;
        _bsDate = parsed.toNepaliDateTime();
        _inputError = null;
      });
    } else {
      final parsed = NepaliDateTime.tryParse(text.trim());
      if (parsed == null) {
        setState(() => _inputError = 'Enter a valid date as yyyy-mm-dd');
        return;
      }
      if (parsed.isBefore(_bsFirstDate) || parsed.isAfter(_bsLastDate)) {
        setState(() => _inputError = 'Date is out of the supported range');
        return;
      }
      setState(() {
        _bsDate = parsed;
        _adDate = parsed.toDateTime();
        _inputError = null;
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _ResultCard(
              bsDate: _bsDate,
              adDate: _adDate,
              direction: _direction,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<_ConversionDirection>(
              segments: const [
                ButtonSegment(value: .adToBs, label: Text('AD → BS')),
                ButtonSegment(value: .bsToAd, label: Text('BS → AD')),
              ],
              selected: {_direction},
              onSelectionChanged: (selected) => setState(() {
                _direction = selected.first;
                _syncInputField();
              }),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              key: ValueKey('input-${_direction.name}'),
              controller: _dateController,
              keyboardType: TextInputType.datetime,
              decoration: InputDecoration(
                labelText: _direction == .adToBs
                    ? 'Gregorian date (AD)'
                    : 'Bikram Sambat date (BS)',
                hintText: 'yyyy-mm-dd',
                errorText: _inputError,
                border: const OutlineInputBorder(),
              ),
              onChanged: _onTypedDateChanged,
            ),
          ),
          const SizedBox(height: 8),
          if (_direction == .adToBs)
            CalendarDatePicker(
              key: ValueKey(
                'ad-${_isoDate(_adDate.year, _adDate.month, _adDate.day)}',
              ),
              initialDate: _adDate,
              firstDate: _adFirstDate,
              lastDate: _adLastDate,
              onDateChanged: _onCalendarDateChanged,
            )
          else
            CalendarDatePicker(
              key: ValueKey(
                'bs-${_isoDate(_bsDate.year, _bsDate.month, _bsDate.day)}',
              ),
              initialDate: _bsDate,
              firstDate: _bsFirstDate,
              lastDate: _bsLastDate,
              calendarDelegate: const NepaliCalendarDelegate(),
              onDateChanged: _onCalendarDateChanged,
            ),
        ],
      ),
    );
  }
}

class const _ResultCard({
  required final NepaliDateTime bsDate,
  required final DateTime adDate,
  required final _ConversionDirection direction,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          spacing: 12,
          children: [
            _DateBlock(
              label: 'Bikram Sambat',
              text: NepaliDateFormat('EEE, MMMM d, y').format(bsDate),
              emphasized: direction == .adToBs,
            ),
            Icon(Icons.swap_vert, color: colorScheme.primary),
            _DateBlock(
              label: 'Gregorian (AD)',
              text: DateFormat('EEEE, MMMM d, y').format(adDate),
              emphasized: direction == .bsToAd,
            ),
          ],
        ),
      ),
    );
  }
}

class const _DateBlock({
  required final String label,
  required final String text,
  required final bool emphasized,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      spacing: 4,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: emphasized
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            fontWeight: .w600,
            letterSpacing: 1.1,
          ),
          textAlign: .center,
        ),
        Text(
          text,
          style: emphasized
              ? theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: .bold,
                )
              : theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          textAlign: .center,
        ),
      ],
    );
  }
}
