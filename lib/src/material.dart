// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart'
    hide showDateRangePicker, SelectableDayForRangePredicate;
import 'package:nepali_utils/nepali_utils.dart';

import 'nepali_calendar_delegate.dart';
import 'overrides/date_range_picker.dart';

/// Shows a dialog containing a Material Design date picker
/// with Bikram Sambat Calendar.
///
/// The returned [Future] resolves to the date selected by the user when the
/// user confirms the dialog. If the user cancels the dialog, null is returned.
Future<NepaliDateTime?> showNepaliDatePicker({
  required BuildContext context,
  required NepaliDateTime firstDate,
  required NepaliDateTime lastDate,
  NepaliDateTime? initialDate,
  NepaliDateTime? currentDate,
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  SelectableDayPredicate? selectableDayPredicate,
  String? helpText,
  String? cancelText,
  String? confirmText,
  Locale? locale,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  TextDirection? textDirection,
  TransitionBuilder? builder,
  DatePickerMode initialDatePickerMode = DatePickerMode.day,
  String? errorFormatText,
  String? errorInvalidText,
  String? fieldHintText,
  String? fieldLabelText,
  TextInputType? keyboardType,
  Offset? anchorPoint,
  final ValueChanged<DatePickerEntryMode>? onDatePickerModeChange,
  final Icon? switchToInputEntryModeIcon,
  final Icon? switchToCalendarEntryModeIcon,
}) async {
  final date = await showDatePicker(
    context: context,
    firstDate: firstDate,
    lastDate: lastDate,
    initialDate: initialDate,
    currentDate: currentDate,
    initialEntryMode: initialEntryMode,
    selectableDayPredicate: selectableDayPredicate,
    helpText: helpText,
    cancelText: cancelText,
    confirmText: confirmText,
    locale: locale,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    textDirection: textDirection,
    builder: builder,
    initialDatePickerMode: initialDatePickerMode,
    errorFormatText: errorFormatText,
    errorInvalidText: errorInvalidText,
    fieldHintText: fieldHintText,
    fieldLabelText: fieldLabelText,
    keyboardType: keyboardType,
    anchorPoint: anchorPoint,
    onDatePickerModeChange: onDatePickerModeChange,
    switchToInputEntryModeIcon: switchToInputEntryModeIcon,
    switchToCalendarEntryModeIcon: switchToCalendarEntryModeIcon,
    calendarDelegate: const NepaliCalendarDelegate(),
  );

  return date as NepaliDateTime?;
}

/// Shows a full screen modal dialog containing a Material Design date range
/// picker with Bikram Sambat Calendar.
///
/// The returned [Future] resolves to the [DateTimeRange] selected by the user
/// when the user saves their selection. If the user cancels the dialog, null is
/// returned.
Future<DateTimeRange<NepaliDateTime>?> showNepaliDateRangePicker({
  required BuildContext context,
  required NepaliDateTime firstDate,
  required NepaliDateTime lastDate,
  DateTimeRange<NepaliDateTime>? initialDateRange,
  NepaliDateTime? currentDate,
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  String? helpText,
  String? cancelText,
  String? confirmText,
  String? saveText,
  String? errorFormatText,
  String? errorInvalidText,
  String? errorInvalidRangeText,
  String? fieldStartHintText,
  String? fieldEndHintText,
  String? fieldStartLabelText,
  String? fieldEndLabelText,
  Locale? locale,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  TextDirection? textDirection,
  TransitionBuilder? builder,
  Offset? anchorPoint,
  TextInputType keyboardType = TextInputType.datetime,
  final Icon? switchToInputEntryModeIcon,
  final Icon? switchToCalendarEntryModeIcon,
  SelectableDayForRangePredicate? selectableDayPredicate,
}) async {
  final dateRange = await showDateRangePicker(
    context: context,
    firstDate: firstDate,
    lastDate: lastDate,
    initialDateRange: initialDateRange,
    currentDate: currentDate,
    initialEntryMode: initialEntryMode,
    helpText: helpText,
    cancelText: cancelText,
    confirmText: confirmText,
    saveText: saveText,
    errorFormatText: errorFormatText,
    errorInvalidText: errorInvalidText,
    errorInvalidRangeText: errorInvalidRangeText,
    fieldStartHintText: fieldStartHintText,
    fieldEndHintText: fieldEndHintText,
    fieldStartLabelText: fieldStartLabelText,
    fieldEndLabelText: fieldEndLabelText,
    locale: locale,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    textDirection: textDirection,
    builder: builder,
    anchorPoint: anchorPoint,
    keyboardType: keyboardType,
    switchToInputEntryModeIcon: switchToInputEntryModeIcon,
    switchToCalendarEntryModeIcon: switchToCalendarEntryModeIcon,
    selectableDayPredicate: selectableDayPredicate,
    calendarDelegate: const NepaliCalendarDelegate(),
  );

  if (dateRange == null) return null;

  final DateTime(year: sYear, month: sMonth, day: sDay) = dateRange.start;
  final DateTime(year: eYear, month: eMonth, day: eDay) = dateRange.end;

  return DateTimeRange(
    start: NepaliDateTime(sYear, sMonth, sDay),
    end: NepaliDateTime(eYear, eMonth, eDay),
  );
}
