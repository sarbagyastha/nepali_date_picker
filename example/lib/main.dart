// Copyright 2019 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';

import 'modes/calendar_date_picker_widget.dart';
import 'modes/calendar_date_range_picker_widget.dart';
import 'modes/date_picker_widget.dart';
import 'modes/date_range_picker_widget.dart';

void main() => runApp(MyApp());

/// MyApp
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      title: 'Nepali Date Picker Demo',
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Nepali Date Picker"),
            centerTitle: true,
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Date Picker'),
                Tab(text: 'Calendar'),
                Tab(text: 'Date Range Picker'),
                Tab(text: 'Calendar Range'),
              ],
            ),
            actions: [
              IconButton(
                icon: Text(
                  NepaliUtils().language == Language.english ? 'ने' : 'En',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white),
                ),
                onPressed: () {
                  NepaliUtils().language =
                      NepaliUtils().language == Language.english
                          ? Language.nepali
                          : Language.english;
                  setState(() {});
                },
              ),
            ],
          ),
          body: TabBarView(
            children: [
              DatePickerWidget(),
              CalendarDatePickerWidget(),
              DateRangePickerWidget(),
              CalendarDateRangePickerWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
