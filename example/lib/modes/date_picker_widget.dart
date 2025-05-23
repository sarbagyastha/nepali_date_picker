// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';

/// Date Picker Example
class DatePickerWidget extends StatefulWidget {
  const DatePickerWidget({super.key});

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  NepaliDateTime? _selectedDateTime = NepaliDateTime.now();
  String _design = 'm';
  DateOrder _dateOrder = DateOrder.mdy;
  bool _showTimerPicker = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: _selectedDateTime == null
                    ? Text('No Date Picked!', textAlign: TextAlign.center)
                    : Column(
                        spacing: 16,
                        children: [
                          Text(
                            NepaliDateFormat(
                              'EEE, MMMM d, y hh:mm aa',
                            ).format(_selectedDateTime!),
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            DateFormat(
                              'EEE, MMMM d, y hh:mm aa',
                            ).format(_selectedDateTime!.toDateTime()),
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: () async {
                if (_design == 'm') {
                  _selectedDateTime = await showNepaliDatePicker(
                    context: context,
                    initialDate: _selectedDateTime ?? NepaliDateTime.now(),
                    firstDate: NepaliDateTime(1970, 2, 5),
                    lastDate: NepaliDateTime(2250, 11, 6),
                    initialDatePickerMode: DatePickerMode.day,
                  );
                  if (_selectedDateTime != null) {
                    if (context.mounted && _showTimerPicker) {
                      final timeOfDay = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                          _selectedDateTime!.toDateTime(),
                        ),
                      );
                      _selectedDateTime = _selectedDateTime!.mergeTime(
                        timeOfDay?.hour ?? 0,
                        timeOfDay?.minute ?? 0,
                        0,
                      );
                    } else {
                      final timeOfDay = TimeOfDay.now();
                      _selectedDateTime = _selectedDateTime!.mergeTime(
                        timeOfDay.hour,
                        timeOfDay.minute,
                        0,
                      );
                    }
                  }

                  setState(() {});
                } else {
                  showCupertinoDatePicker(
                    context: context,
                    initialDate: _selectedDateTime ?? NepaliDateTime.now(),
                    firstDate: NepaliDateTime(1970),
                    lastDate: NepaliDateTime(2100, 12),
                    language: NepaliUtils().language,
                    dateOrder: _dateOrder,
                    onDateChanged: (newDate) {
                      final timeOfDay = TimeOfDay.now();
                      setState(() {
                        _selectedDateTime = newDate.mergeTime(
                          timeOfDay.hour,
                          timeOfDay.minute,
                          0,
                        );
                      });
                    },
                  );
                }
              },
              child: Text('PICK DATE'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
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
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _radio<DateOrder>(
                        'D M Y',
                        DateOrder.dmy,
                        _dateOrder,
                        (value) => setState(() => _dateOrder = value),
                      ),
                      _radio<DateOrder>(
                        'M D Y',
                        DateOrder.mdy,
                        _dateOrder,
                        (value) => setState(() => _dateOrder = value),
                      ),
                      _radio<DateOrder>(
                        'Y D M',
                        DateOrder.ydm,
                        _dateOrder,
                        (value) => setState(() => _dateOrder = value),
                      ),
                      _radio<DateOrder>(
                        'Y M D',
                        DateOrder.ymd,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
      child: RadioListTile<T>(
        value: value,
        groupValue: groupValue,
        onChanged: _design == 'm' && groupValue == _dateOrder
            ? null
            : (v) => onChanged(v as T),
        title: Text(title),
      ),
    );
  }
}
