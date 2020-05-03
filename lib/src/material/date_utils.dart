// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:nepali_utils/nepali_utils.dart';

/// Returns a [NepaliDateTime] with just the date of the original, but no time set.
NepaliDateTime dateOnly(NepaliDateTime date) {
  return NepaliDateTime(date.year, date.month, date.day);
}

/// Returns true if the two [NepaliDateTime] objects have the same day, month, and
/// year.
bool isSameDay(NepaliDateTime dateA, NepaliDateTime dateB) {
  return dateA.year == dateB.year && dateA.month == dateB.month && dateA.day == dateB.day;
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
//  return NepaliDateTime(
//    monthDate.year + monthsToAdd ~/ 12,
//    monthDate.month + monthsToAdd % 12,
//  );
}

/// Computes the offset from the first day of the week that the first day of
/// the [month] falls on.
int firstDayOffset(int year, int month) {
  return NepaliDateTime(year, month).weekday - 1;
}

/// Returns the number of days in a month.
int getDaysInMonth(int year, int month) {
//  var _year = year;
//  var _month = month;
//  if (month > 12) {
//    _year += month ~/ 12;
//    _month = month % 12;
//  }
  return NepaliDateTime(year, month).totalDays;
}
