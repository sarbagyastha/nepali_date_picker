import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';

class NepaliDatePickerDelegate implements DatePickerDelegate {
  const NepaliDatePickerDelegate();

  @override
  NepaliDateTime now() => NepaliDateTime.now();

  @override
  NepaliDateTime dateOnly(NepaliDateTime date) {
    return NepaliDateTime(date.year, date.month, date.day);
  }

  @override
  int getDaysInMonth(int year, int month) {
    return NepaliDateTime(year, month).totalDays;
  }

  @override
  DateTime addDaysToDate(NepaliDateTime date, int days) {
    return date.add(Duration(days: days));
  }

  @override
  NepaliDateTime addMonthsToMonthDate(
    NepaliDateTime monthDate,
    int monthsToAdd,
  ) {
    var year = monthDate.year;
    var month = monthDate.month + monthsToAdd;

    year += (month - 1) ~/ 12;
    month = month % 12;
    if (month == 0) month = 12;
    return NepaliDateTime(year, month);
  }

  @override
  DateTimeRange<NepaliDateTime> datesOnly(DateTimeRange<NepaliDateTime> range) {
    return DateTimeRange(
      start: dateOnly(range.start),
      end: dateOnly(range.end),
    );
  }

  @override
  int firstDayOffset(int year, int month, MaterialLocalizations localizations) {
    return NepaliDateTime(year, month).weekday - 1;
  }

  @override
  bool isSameDay(NepaliDateTime? dateA, NepaliDateTime? dateB) {
    return dateA?.year == dateB?.year &&
        dateA?.month == dateB?.month &&
        dateA?.day == dateB?.day;
  }

  @override
  bool isSameMonth(NepaliDateTime? dateA, NepaliDateTime? dateB) {
    return dateA?.year == dateB?.year && dateA?.month == dateB?.month;
  }

  @override
  int monthDelta(NepaliDateTime startDate, NepaliDateTime endDate) {
    return (endDate.year - startDate.year) * 12 +
        endDate.month -
        startDate.month;
  }

  @override
  NepaliDateTime getMonth(int year, int month) => NepaliDateTime(year, month);

  @override
  NepaliDateTime getDay(int year, int month, int day) {
    return NepaliDateTime(year, month, day);
  }

  @override
  String formatMonthYear(
    NepaliDateTime date,
    MaterialLocalizations localizations,
  ) {
    return NepaliDateFormat.yMMMM(_getLanguage(localizations)).format(date);
  }

  @override
  String formatYear(int year, MaterialLocalizations localizations) {
    return localizations.formatYear(DateTime(year));
  }

  @override
  String formatMediumDate(
    NepaliDateTime date,
    MaterialLocalizations localizations,
  ) {
    return NepaliDateFormat('EE, MMMM d', _getLanguage(localizations)).format(
      date,
    );
  }

  @override
  NepaliDateTime? parseCompactDate(
    String? inputString,
    MaterialLocalizations localizations,
  ) {
    final dateTime = localizations.parseCompactDate(inputString);
    if (dateTime == null) return null;

    return NepaliDateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  @override
  String formatShortDate(
    NepaliDateTime date,
    MaterialLocalizations localizations,
  ) {
    return NepaliDateFormat('MMMM d, y', _getLanguage(localizations))
        .format(date);
  }

  @override
  String formatShortMonthDay(
    NepaliDateTime date,
    MaterialLocalizations localizations,
  ) {
    return NepaliDateFormat('MMMM d', _getLanguage(localizations)).format(date);
  }

  @override
  String formatFullDate(
    NepaliDateTime date,
    MaterialLocalizations localizations,
  ) {
    return NepaliDateFormat('EEEE, MMMM d, y', _getLanguage(localizations))
        .format(date);
  }

  Language _getLanguage(MaterialLocalizations localizations) {
    return localizations is MaterialLocalizationNe
        ? Language.nepali
        : Language.english;
  }
}
