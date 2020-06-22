// Copyright 2019 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nepali_date_picker_example/modes/calendar_date_picker_widget.dart';
import 'package:nepali_date_picker_example/modes/date_picker_widget.dart';

void main() => runApp(MyApp());

/// MyApp
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      title: 'Nepali Date Picker Demo',
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Nepali Date Picker"),
            centerTitle: true,
            bottom: TabBar(
              tabs: [
                Tab(text: 'Date Picker'),
                Tab(text: 'Calendar'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              DatePickerWidget(),
              CalendarDatePickerWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
