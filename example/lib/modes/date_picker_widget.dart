// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import 'package:nepali_date_picker/nepali_date_picker.dart';

/// Date Picker Example
class const DatePickerWidget({super.key}) extends StatefulWidget {
  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  final ValueNotifier<NepaliDateTime?> _selectedDateTime = ValueNotifier(
    NepaliDateTime.now(),
  );
  String _design = 'm';
  DateOrder _dateOrder = .mdy;
  bool _showTimerPicker = false;

  @override
  void dispose() {
    _selectedDateTime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: .stretch,
          mainAxisAlignment: .center,
          mainAxisSize: .min,
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: ValueListenableBuilder<NepaliDateTime?>(
                  valueListenable: _selectedDateTime,
                  builder: (context, selectedDateTime, _) {
                    if (selectedDateTime == null) {
                      return Text('No Date Picked!', textAlign: .center);
                    }
                    return Column(
                      spacing: 16,
                      children: [
                        Text(
                          NepaliDateFormat('EEE, MMMM d, y hh:mm aa')
                              .format(selectedDateTime),
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: .center,
                        ),
                        Text(
                          DateFormat('EEE, MMMM d, y hh:mm aa')
                              .format(selectedDateTime.toDateTime()),
                          style: Theme.of(context).textTheme.titleSmall,
                          textAlign: .center,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: () async {
                if (_design == 'm') {
                  var newDateTime = await showNepaliDatePicker(
                    context: context,
                    initialDate:
                        _selectedDateTime.value ?? NepaliDateTime.now(),
                    firstDate: NepaliDateTime(1970, 2, 5),
                    lastDate: NepaliDateTime(2250, 11, 6),
                    initialDatePickerMode: .day,
                  );
                  if (newDateTime != null) {
                    if (context.mounted && _showTimerPicker) {
                      final timeOfDay = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                          newDateTime.toDateTime(),
                        ),
                      );
                      newDateTime = newDateTime.mergeTime(
                        timeOfDay?.hour ?? 0,
                        timeOfDay?.minute ?? 0,
                        0,
                      );
                    } else {
                      final timeOfDay = TimeOfDay.now();
                      newDateTime = newDateTime.mergeTime(
                        timeOfDay.hour,
                        timeOfDay.minute,
                        0,
                      );
                    }
                    _selectedDateTime.value = newDateTime;
                  }
                } else {
                  showCupertinoDatePicker(
                    context: context,
                    initialDate:
                        _selectedDateTime.value ?? NepaliDateTime.now(),
                    firstDate: NepaliDateTime(1970),
                    lastDate: NepaliDateTime(2100, 12),
                    language: NepaliUtils().language,
                    dateOrder: _dateOrder,
                    onDateChanged: (newDate) {
                      final timeOfDay = TimeOfDay.now();
                      _selectedDateTime.value = newDate.mergeTime(
                        timeOfDay.hour,
                        timeOfDay.minute,
                        0,
                      );
                    },
                  );
                }
              },
              child: Text('PICK DATE'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisSize: .min,
              children: <Widget>[
                SizedBox(width: 10.0),
                Text('Design: ', style: TextStyle(fontSize: 18.0)),
                _radio<String>(
                  'Material',
                  'm',
                  _design,
                  (value) => setState(() => _design = value),
                ),
                _radio<String>(
                  'Cupertino',
                  'c',
                  _design,
                  (value) => setState(() => _design = value),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisSize: .min,
              mainAxisAlignment: .start,
              crossAxisAlignment: .start,
              children: <Widget>[
                SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: .start,
                  children: <Widget>[
                    SizedBox(height: 15.0),
                    Text('Order: ', style: TextStyle(fontSize: 18.0)),
                    Text(
                      '(only for Cupertino)',
                      style: TextStyle(fontSize: 8.0),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: .min,
                    children: <Widget>[
                      _radio<DateOrder>(
                        'D M Y',
                        .dmy,
                        _dateOrder,
                        (value) => setState(() => _dateOrder = value),
                      ),
                      _radio<DateOrder>(
                        'M D Y',
                        .mdy,
                        _dateOrder,
                        (value) => setState(() => _dateOrder = value),
                      ),
                      _radio<DateOrder>(
                        'Y D M',
                        .ydm,
                        _dateOrder,
                        (value) => setState(() => _dateOrder = value),
                      ),
                      _radio<DateOrder>(
                        'Y M D',
                        .ymd,
                        _dateOrder,
                        (value) => setState(() => _dateOrder = value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: .start,
                  children: <Widget>[
                    SizedBox(height: 15.0),
                    Text(
                      'Show Time Picker: ',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      '(only for Material)',
                      style: TextStyle(fontSize: 8.0),
                    ),
                  ],
                ),
                Switch(
                  value: _showTimerPicker,
                  onChanged: _design == 'm'
                      ? (v) => setState(() => _showTimerPicker = v)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _radio<T>(
    String title,
    T value,
    T groupValue,
    ValueChanged<T> onChanged,
  ) {
    return Flexible(
      child: RadioGroup<T>(
        groupValue: groupValue,
        onChanged: (v) => onChanged(v as T),
        child: RadioListTile<T>(value: value, title: Text(title)),
      ),
    );
  }
}
