// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nepali_date_picker_example/locale_scope.dart';

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
    return LocaleScope(
      builder: (_, locale) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorSchemeSeed: Colors.orange),
          title: 'Nepali Date Picker Demo',
          locale: locale,
          supportedLocales: [Locale('en', 'US'), Locale('ne', 'NP')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: HomePage(),
        );
      },
    );
  }
}

///
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
            IconButton.filledTonal(
              icon: Text(LocaleScope.of(context).isNepali ? 'ने' : 'En'),
              onPressed: () => LocaleScope.of(context).toggleLocale(),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: TabBarView(
                  children: [
                    DatePickerWidget(),
                    CalendarDatePickerWidget(),
                    DateRangePickerWidget(),
                    CalendarDateRangePickerWidget(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
