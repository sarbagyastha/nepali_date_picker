// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import 'package:nepali_date_picker/nepali_date_picker.dart';

enum _ConversionDirection { adToBs, bsToAd }

final _bsFirstDate = NepaliDateTime(1970, 2, 5);
final _bsLastDate = NepaliDateTime(2250, 11, 6);

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

  @override
  Widget build(BuildContext context) {
    return Column(
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
            onSelectionChanged: (selected) =>
                setState(() => _direction = selected.first),
          ),
        ),
        const SizedBox(height: 8),
        if (_direction == .adToBs)
          CalendarDatePicker(
            key: const ValueKey('ad'),
            initialDate: _adDate,
            firstDate: _adFirstDate,
            lastDate: _adLastDate,
            onDateChanged: (date) => setState(() {
              _adDate = date;
              _bsDate = date.toNepaliDateTime();
            }),
          )
        else
          CalendarDatePicker(
            key: const ValueKey('bs'),
            initialDate: _bsDate,
            firstDate: _bsFirstDate,
            lastDate: _bsLastDate,
            calendarDelegate: const NepaliCalendarDelegate(),
            onDateChanged: (date) => setState(() {
              _bsDate = date as NepaliDateTime;
              _adDate = _bsDate.toDateTime();
            }),
          ),
      ],
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
