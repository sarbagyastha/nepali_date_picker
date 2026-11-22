// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nepali_utils/nepali_utils.dart';

import 'cupertino.dart';
import 'language_source.dart';
import 'material.dart';
import 'utils.dart';

const double _kPickerSheetHeight = 216.0;

/// Shows nepali date picker of style that adapts as per the platform.
Future<NepaliDateTime?> showAdaptiveDatePicker({
  required BuildContext context,
  required NepaliDateTime initialDate,
  required NepaliDateTime firstDate,
  required NepaliDateTime lastDate,

  /// The language of the Cupertino picker. When null, it is read from
  /// [languageSource]. The Material picker follows [languageSource] only.
  Language? language,

  /// Where the language is read from when [language] is null.
  LanguageSource languageSource = .app,

  /// Only for Android and Fuchsia: whether "today" is the current date in
  /// Nepal instead of on the device.
  bool useNepalTime = false,

  /// Only for iOS
  DateOrder dateOrder = .mdy,

  /// Only for Android and Fuchsia
  DatePickerMode initialDatePickerMode = .day,
}) async {
  assert(
    firstDate.year >= NepaliDateTime.minYear &&
        lastDate.year <= NepaliDateTime.maxYear,
    'Invalid Date Range. '
    'Valid Range = [${NepaliDateTime.minYear}, ${NepaliDateTime.maxYear}]',
  );
  assert(
    !initialDate.isBefore(firstDate),
    'initialDate must be on or after firstDate',
  );
  assert(
    !initialDate.isAfter(lastDate),
    'initialDate must be on or before lastDate',
  );
  assert(
    !firstDate.isAfter(lastDate),
    'lastDate must be on or after firstDate',
  );

  final theme = Theme.of(context);
  switch (theme.platform) {
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return await showNepaliDatePicker(
        context: context,
        firstDate: firstDate,
        lastDate: lastDate,
        initialDate: initialDate,
        initialDatePickerMode: initialDatePickerMode,
        useNepalTime: useNepalTime,
        languageSource: languageSource,
      );
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return await _showCupertinoDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        language: language,
        languageSource: languageSource,
        dateOrder: dateOrder,
      );
  }
}

Future<NepaliDateTime?> _showCupertinoDatePicker({
  required BuildContext context,
  required NepaliDateTime initialDate,
  required NepaliDateTime firstDate,
  required NepaliDateTime lastDate,
  Language? language,
  LanguageSource languageSource = .app,
  DateOrder dateOrder = .mdy,
}) async {
  assert(
    firstDate.year >= NepaliDateTime.minYear &&
        lastDate.year <= NepaliDateTime.maxYear,
    'Invalid Date Range. '
    'Valid Range = [${NepaliDateTime.minYear}, ${NepaliDateTime.maxYear}]',
  );
  assert(
    !initialDate.isBefore(firstDate),
    'initialDate must be on or after firstDate',
  );
  assert(
    !initialDate.isAfter(lastDate),
    'initialDate must be on or before lastDate',
  );
  assert(
    !firstDate.isAfter(lastDate),
    'lastDate must be on or after firstDate',
  );

  // Lives outside the builder so a rebuild of the sheet keeps the selection,
  // and DONE without scrolling returns the initial date.
  var selectedDate = initialDate;

  return await showCupertinoModalPopup<NepaliDateTime>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final resolvedLanguage = language ?? languageOf(context, languageSource);

      return Container(
        height: _kPickerSheetHeight + 40.0,
        padding: const EdgeInsets.only(top: 6.0),
        color: CupertinoColors.white,
        child: DefaultTextStyle(
          style: const TextStyle(color: CupertinoColors.black, fontSize: 22.0),
          child: GestureDetector(
            onTap: () {},
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      TextButton(
                        child: Text(
                          resolvedLanguage == .english
                              ? 'CANCEL'
                              : 'रद्द गर्नुहोस',
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Spacer(),
                      TextButton(
                        child: Text(
                          resolvedLanguage == .english ? 'DONE' : 'ठिक छ',
                        ),
                        onPressed: () => Navigator.pop(context, selectedDate),
                      ),
                    ],
                  ),
                  Expanded(
                    child: NepaliCupertinoDatePicker(
                      initialDate: initialDate,
                      minimumYear: firstDate.year,
                      maximumYear: lastDate.year,
                      onDateChanged: (date) => selectedDate = date,
                      language: resolvedLanguage,
                      dateOrder: dateOrder,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
