// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';

/// Returns a [NepaliDateTime] with just the date of the original, but no time set.
NepaliDateTime dateOnly(NepaliDateTime date) {
  return NepaliDateTime(date.year, date.month, date.day);
}

/// Returns true if the two [NepaliDateTime] objects have the same day, month, and
/// year, or are both null.
bool isSameDay(NepaliDateTime? dateA, NepaliDateTime? dateB) {
  return dateA?.year == dateB?.year &&
      dateA?.month == dateB?.month &&
      dateA?.day == dateB?.day;
}

/// Returns true if the two [NepaliDateTime] objects have the same month, and
/// year, or are both null.
bool isSameMonth(NepaliDateTime? dateA, NepaliDateTime? dateB) {
  return dateA?.year == dateB?.year && dateA?.month == dateB?.month;
}

/// Determines the number of months between two [NepaliDateTime] objects.
int monthDelta(NepaliDateTime startDate, NepaliDateTime endDate) {
  return (endDate.year - startDate.year) * 12 + endDate.month - startDate.month;
}

/// Returns a [NepaliDateTime] with the added number of months and truncates any day
/// and time information.
NepaliDateTime addMonthsToMonthDate(NepaliDateTime monthDate, int monthsToAdd) {
  var _year = monthDate.year;
  var _month = monthDate.month + monthsToAdd;

  _year += (_month - 1) ~/ 12;
  _month = _month % 12;
  if (_month == 0) _month = 12;
  return NepaliDateTime(_year, _month);
}

/// Computes the offset from the first day of the week that the first day of
/// the [month] falls on.
int firstDayOffset(int year, int month) {
  return NepaliDateTime(year, month).weekday - 1;
}

/// Returns the number of days in a month.
int getDaysInMonth(int year, int month) {
  return NepaliDateTime(year, month).totalDays;
}

/// Returns a locale-appropriate string to describe the start of a date range.
///
/// If `startDate` is null, then it defaults to 'Start Date', otherwise if it
/// is in the same year as the `endDate` then it will use the short month
/// day format (i.e. 'Asr 21'). Otherwise it will return the short date format
/// (i.e. 'Asr 21, 2077').
String formatRangeStartDate(MaterialLocalizations localizations,
    NepaliDateTime? startDate, NepaliDateTime? endDate) {
  return startDate == null
      ? localizations.dateRangeStartLabel
      : (endDate == null || startDate.year == endDate.year)
          ? NepaliDateFormat('MMMM d').format(startDate)
          : NepaliDateFormat.yMd().format(startDate);
}

/// Returns an locale-appropriate string to describe the end of a date range.
///
/// If `endDate` is null, then it defaults to 'End Date', otherwise if it
/// is in the same year as the `startDate` and the `currentDate` then it will
/// just use the short month day format (i.e. 'Asr 21'), otherwise it will
/// include the year (i.e. 'Asr 21, 2077').
String formatRangeEndDate(
    MaterialLocalizations localizations,
    NepaliDateTime? startDate,
    NepaliDateTime? endDate,
    NepaliDateTime currentDate) {
  return endDate == null
      ? localizations.dateRangeEndLabel
      : (startDate != null &&
              startDate.year == endDate.year &&
              startDate.year == currentDate.year)
          ? NepaliDateFormat('MMMM d').format(endDate)
          : NepaliDateFormat.yMd().format(endDate);
}

/// Returns a [NepaliDateTimeRange] with the dates of the original without any times set.
NepaliDateTimeRange datesOnly(NepaliDateTimeRange range) {
  return NepaliDateTimeRange(
      start: dateOnly(range.start), end: dateOnly(range.end));
}
