// Copyright 2019 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';

import 'modes/calendar_date_picker_widget.dart';
import 'modes/calendar_date_range_picker_widget.dart';
import 'modes/date_picker_widget.dart';
import 'modes/date_range_picker_widget.dart';

void main() => runApp(MyApp());

/// MyApp
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple),
      title: 'Nepali Date Picker Demo',
      home: HomePage(),
    );
  }
}

///
class HomePage extends StatefulWidget {
  ///
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
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
              Tab(text: 'Fused Date Picker'),
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
            Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showFusedDatePickerDialog(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2090),
                  ),
                  child: Text('Show Fused Date Picker'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
