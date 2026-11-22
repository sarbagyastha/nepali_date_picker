// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

import 'utils.dart';

const _compactDatePattern = 'y-MM-dd';
final _compactDateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

// NepaliDateFormat is immutable in nepali_utils 4.0, so formatters are cached
// per (pattern, language) instead of being rebuilt for every call. The date
// picker formats every visible day (e.g. semantics labels), so this matters.
final Map<(String, Language), NepaliDateFormat> _formatters = {};

NepaliDateFormat _formatter(
  String key,
  Language language,
  NepaliDateFormat Function() create,
) {
  return _formatters[(key, language)] ??= create();
}

/// A [CalendarDelegate] implementation for the Nepali (Bikram Sambat) calendar system.
///
/// The Nepali calendar, also known as the **Bikram Sambat (BS) calendar**,
/// is the official calendar of Nepal and differs from the Gregorian calendar
/// in terms of year calculation, month lengths, and leap year rules.
///
/// Features:
/// - **Lunisolar structure**: The number of days in each month varies between **28 to 32 days**.
/// - **Ahead of the Gregorian calendar**: The Bikram Sambat year is typically **56-57 years**
///   ahead of the Gregorian year.
/// - **Months start on different days** each year, unlike fixed weekday-based calendars.
/// - **Leap years follow distinct rules** that are different from the Gregorian system.
///
/// This delegate allows [CalendarDatePicker] to interpret and navigate dates
/// based on the Nepali calendar system.
///
/// Creates a [NepaliCalendarDelegate] for interpreting dates
/// according to the Nepali (Bikram Sambat) calendar system.
///
/// [useNepalTime] decides what "today" is: `false` (the default) uses the
/// device's local time ([NepaliDateTime.now]), `true` uses Nepal time
/// ([NepaliDateTime.nepalNow]).
///
/// [languageSource] decides where the language used for formatting comes
/// from: the app's [MaterialLocalizations] ([LanguageSource.app], the
/// default) or the device locale ([LanguageSource.device]).
class const NepaliCalendarDelegate({
  /// Whether "today" is the current date in Nepal instead of on the device.
  final bool useNepalTime = false,

  /// Where the formatting language is read from.
  final LanguageSource languageSource = .app,
}) extends CalendarDelegate<NepaliDateTime> {
  @override
  NepaliDateTime now() =>
      useNepalTime ? NepaliDateTime.nepalNow() : NepaliDateTime.now();

  @override
  NepaliDateTime dateOnly(NepaliDateTime date) {
    // Fast path: already a local date at midnight, nothing to rebuild.
    if (!date.isUtc &&
        !date.isNepalTime &&
        date.hour == 0 &&
        date.minute == 0 &&
        date.second == 0 &&
        date.millisecond == 0 &&
        date.microsecond == 0) {
      return date;
    }
    return NepaliDateTime(date.year, date.month, date.day);
  }

  @override
  int monthDelta(NepaliDateTime startDate, NepaliDateTime endDate) {
    final yearDelta = endDate.year - startDate.year;
    final monthDelta = endDate.month - startDate.month;
    return yearDelta * 12 + monthDelta;
  }

  @override
  NepaliDateTime addMonthsToMonthDate(
    NepaliDateTime monthDate,
    int monthsToAdd,
  ) {
    // Out-of-range months roll over into the adjacent years.
    return NepaliDateTime(monthDate.year, monthDate.month + monthsToAdd);
  }

  @override
  NepaliDateTime addDaysToDate(NepaliDateTime date, int days) {
    // Out-of-range days roll over into the adjacent months. Unlike adding a
    // Duration, this is not shifted by daylight saving transitions.
    return NepaliDateTime(date.year, date.month, date.day + days);
  }

  @override
  int firstDayOffset(int year, int month, MaterialLocalizations localizations) {
    // Calendar-only lookup: UTC avoids resolving the local time zone.
    // NepaliDateTime.weekday is 1 for Sunday, matching the index base of
    // MaterialLocalizations.firstDayOfWeekIndex (0 = Sunday).
    final weekdayFromSunday = NepaliDateTime.utc(year, month).weekday - 1;
    return (weekdayFromSunday - localizations.firstDayOfWeekIndex) % 7;
  }

  @override
  int getDaysInMonth(int year, int month) {
    return NepaliDateTime.utc(year, month).totalDays;
  }

  @override
  NepaliDateTime getMonth(int year, int month) => NepaliDateTime(year, month);

  @override
  NepaliDateTime getDay(int year, int month, int day) {
    return NepaliDateTime(year, month, day);
  }

  @override
  String formatYear(int year, MaterialLocalizations localizations) {
    final language = _getLanguage(localizations);
    return _formatter(
      'y',
      language,
      () => NepaliDateFormat.y(language),
    ).format(NepaliDateTime.utc(year));
  }

  @override
  String formatMonthYear(
    NepaliDateTime date,
    MaterialLocalizations localizations,
  ) {
    final language = _getLanguage(localizations);
    return _formatter(
      'yMMMM',
      language,
      () => NepaliDateFormat.yMMMM(language),
    ).format(date);
  }

  @override
  String formatMediumDate(
    NepaliDateTime date,
    MaterialLocalizations localizations,
  ) {
    return _pattern('EE, MMMM d', localizations).format(date);
  }

  @override
  String formatShortMonthDay(
    NepaliDateTime date,
    MaterialLocalizations localizations,
  ) {
    return _pattern('MMMM d', localizations).format(date);
  }

  @override
  String formatShortDate(
    NepaliDateTime date,
    MaterialLocalizations localizations,
  ) {
    return _pattern('MMMM d, y', localizations).format(date);
  }

  @override
  String formatFullDate(
    NepaliDateTime date,
    MaterialLocalizations localizations,
  ) {
    return _pattern('EEEE, MMMM d, y', localizations).format(date);
  }

  @override
  String formatCompactDate(
    NepaliDateTime date,
    MaterialLocalizations localizations,
  ) {
    return _pattern(_compactDatePattern, localizations).format(date);
  }

  @override
  NepaliDateTime? parseCompactDate(
    String? inputString,
    MaterialLocalizations localizations,
  ) {
    if (inputString == null) return null;
    final input = inputString.trim();
    if (!_compactDateRegex.hasMatch(input)) return null;

    final date = NepaliDateTime.tryParse(input);
    if (date == null) return null;

    // NepaliDateTime.parse rolls over out-of-range days (e.g. 2080-01-33),
    // so check the fields round-trip to keep parsing strict.
    final [year, month, day] = input.split('-').map(int.parse).toList();
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  @override
  String dateHelpText(MaterialLocalizations localizations) {
    return 'yyyy-mm-dd';
  }

  NepaliDateFormat _pattern(
    String pattern,
    MaterialLocalizations localizations,
  ) {
    final language = _getLanguage(localizations);
    return _formatter(
      pattern,
      language,
      () => NepaliDateFormat(pattern, language),
    );
  }

  Language _getLanguage(MaterialLocalizations localizations) {
    return switch (languageSource) {
      .app => localizations is MaterialLocalizationNe ? .nepali : .english,
      .device => deviceLanguage(),
    };
  }
}
