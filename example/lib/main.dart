// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nepali_date_picker_example/app_scope.dart';

import 'modes/calendar_date_picker_widget.dart';
import 'modes/calendar_date_range_picker_widget.dart';
import 'modes/date_converter_widget.dart';
import 'modes/date_picker_widget.dart';
import 'modes/date_range_picker_widget.dart';

void main() => runApp(MyApp());

/// MyApp
class const MyApp({super.key}) extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return AppScope(
      builder: (_, locale, brightness, color) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorSchemeSeed: color, brightness: brightness),
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
class const HomePage({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appScope = AppScope.of(context);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Nepali Date Picker'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Converter'),
              Tab(text: 'Date Picker'),
              Tab(text: 'Calendar'),
              Tab(text: 'Date Range Picker'),
              Tab(text: 'Calendar Range'),
            ],
          ),
          actions: [
            IconButton.filledTonal(
              icon: Icon(Icons.color_lens_outlined),
              onPressed: () => ColorPicker(
                color: appScope.color,
                onColorChanged: appScope.updateColor,
              ).showPickerDialog(context),
            ),
            const SizedBox(width: 16),
            IconButton.filledTonal(
              icon: Icon(
                appScope.brightness == .light
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
              ),
              onPressed: appScope.toggleBrightness,
            ),
            const SizedBox(width: 16),
            IconButton.filledTonal(
              icon: Text(appScope.isNepali ? 'En' : 'ने'),
              onPressed: appScope.toggleLocale,
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
                    DateConverterWidget(),
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
