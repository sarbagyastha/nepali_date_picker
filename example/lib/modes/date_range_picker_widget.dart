// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

///
class DateRangePickerWidget extends StatefulWidget {
  @override
  _DateRangePickerWidgetState createState() => _DateRangePickerWidgetState();
}

class _DateRangePickerWidgetState extends State<DateRangePickerWidget> {
  DateTimeRange<NepaliDateTime>? _selectedDateTimeRange = DateTimeRange(
    start: NepaliDateTime.now(),
    end: NepaliDateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child:
                    _selectedDateTimeRange == null
                        ? Text(
                          'No Date Range Picked!',
                          textAlign: TextAlign.center,
                        )
                        : Column(
                          spacing: 16,
                          children: [
                            Text(
                              NepaliDateFormat(
                                "EEE, MMMM d, y",
                              ).format(_selectedDateTimeRange!.start),
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              DateFormat("EEE, MMMM d, y").format(
                                _selectedDateTimeRange!.start.toDateTime(),
                              ),
                              style: Theme.of(context).textTheme.titleSmall,
                              textAlign: TextAlign.center,
                            ),
                            Icon(Icons.arrow_downward_rounded),
                            Text(
                              NepaliDateFormat(
                                "EEE, MMMM d, y",
                              ).format(_selectedDateTimeRange!.end),
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              DateFormat("EEE, MMMM d, y").format(
                                _selectedDateTimeRange!.end.toDateTime(),
                              ),
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
                _selectedDateTimeRange = await showNepaliDateRangePicker(
                  context: context,
                  firstDate: NepaliDateTime(2020),
                  lastDate: NepaliDateTime(2099),
                );
                setState(() {});
              },
              child: Text('PICK DATE RANGE'),
            ),
          ],
        ),
      ),
    );
  }
}
