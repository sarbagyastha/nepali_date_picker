// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';

import 'cupertino.dart';
import 'material.dart';

const double _kPickerSheetHeight = 216.0;

/// Shows nepali date picker of style that adapts as per the platform.
Future<NepaliDateTime?> showAdaptiveDatePicker({
  required BuildContext context,
  required NepaliDateTime initialDate,
  required NepaliDateTime firstDate,
  required NepaliDateTime lastDate,
  Language language = Language.english,

  /// Only for iOS
  DateOrder dateOrder = DateOrder.mdy,

  /// Only for Android and Fuchsia
  DatePickerMode initialDatePickerMode = DatePickerMode.day,
}) async {
  assert(
    firstDate.year >= 1970 && lastDate.year <= 2100,
    'Invalid Date Range. Valid Range = [1970, 2100]',
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
      );
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return await _showCupertinoDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        language: language,
        dateOrder: dateOrder,
      );
  }
}

Future<NepaliDateTime?> _showCupertinoDatePicker({
  required BuildContext context,
  required NepaliDateTime initialDate,
  required NepaliDateTime firstDate,
  required NepaliDateTime lastDate,
  Language language = Language.english,
  DateOrder dateOrder = DateOrder.mdy,
}) async {
  assert(
    firstDate.year >= 2000 && lastDate.year <= 2099,
    'Invalid Date Range. Valid Range = [2000, 2099]',
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

  return await _showCupertinoPopup<NepaliDateTime>(
    context: context,
    builder: (BuildContext context) {
      NepaliDateTime? selectedDate;

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
                          language == Language.english
                              ? 'CANCEL'
                              : 'रद्द गर्नुहोस',
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Spacer(),
                      TextButton(
                        child: Text(
                          language == Language.english ? 'DONE' : 'ठिक छ',
                        ),
                        onPressed: () => Navigator.pop(context, selectedDate),
                      ),
                    ],
                  ),
                  Expanded(
                    child: NepaliCupertinoDatePicker(
                      initialDate: NepaliDateTime.now(),
                      minimumYear: firstDate.year,
                      maximumYear: lastDate.year,
                      onDateChanged: (date) => selectedDate = date,
                      language: language,
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

Future<T?> _showCupertinoPopup<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return Navigator.of(
    context,
    rootNavigator: true,
  ).push(_CupertinoPopupRoute<T>(builder: builder, barrierLabel: 'Dismiss'));
}

class _CupertinoPopupRoute<T> extends PopupRoute<T> {
  _CupertinoPopupRoute({
    required this.builder,
    required this.barrierLabel,
    super.settings,
  });

  final WidgetBuilder builder;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => Color(0x6604040F);

  @override
  bool get barrierDismissible => false;

  @override
  bool get semanticsDismissible => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 335);

  late Animation<double> _animation;

  late Tween<Offset> _offsetTween;

  @override
  Animation<double> createAnimation() {
    _animation = CurvedAnimation(
      parent: super.createAnimation(),

      // These curves were initially measured from native iOS horizontal page
      // route animations and seemed to be a good match here as well.
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.linearToEaseOut.flipped,
    );
    _offsetTween = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, 0.0),
    );
    return _animation;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionalTranslation(
        translation: _offsetTween.evaluate(_animation),
        child: child,
      ),
    );
  }
}
