// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

///
class CalendarDateRangePickerWidget extends StatefulWidget {
  const CalendarDateRangePickerWidget({super.key});

  @override
  State<CalendarDateRangePickerWidget> createState() =>
      _CalendarDateRangePickerWidgetState();
}

class _CalendarDateRangePickerWidgetState
    extends State<CalendarDateRangePickerWidget> {
  ///
  (NepaliDateTime, NepaliDateTime?) _dateRange = (
    NepaliDateTime.now(),
    NepaliDateTime.now().add(Duration(days: 5)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CalendarDateRangePicker(
              initialStartDate: NepaliDateTime.now(),
              initialEndDate: NepaliDateTime.now().add(Duration(days: 5)),
              firstDate: NepaliDateTime(1970),
              lastDate: NepaliDateTime(2100),
              onStartDateChanged: (date) {
                _dateRange = (date as NepaliDateTime, _dateRange.$2);
                setState(() {});
              },
              onEndDateChanged: (date) {
                _dateRange = (_dateRange.$1, date as NepaliDateTime?);
                setState(() {});
              },
              selectableDayPredicate: null,
              calendarDelegate: const NepaliCalendarDelegate(),
            ),
          ),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            title: Text('From: ${_format(_dateRange.$1)}'),
            subtitle: Text('To: ${_format(_dateRange.$2)}'),
            tileColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        ],
      ),
    );
  }

  String _format(NepaliDateTime? dateTime) {
    if (dateTime == null) return '';
    return NepaliDateFormat.yMMMMEEEEd().format(dateTime);
  }
}
