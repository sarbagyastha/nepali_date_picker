// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:nepali_utils/nepali_utils.dart';

import 'language_source.dart';
import 'utils.dart';

// Default aesthetic values obtained by comparing with iOS pickers.
const double _kItemExtent = 32.0;
const bool _kUseMagnifier = true;
const double _kMagnification = 1.05;
const double _kDatePickerPadSize = 12.0;
const double _kPickerSheetHeight = 216.0;
// Considers setting the default background color from the theme, in the future.
const Color _kBackgroundColor = CupertinoColors.white;

const TextStyle _kDefaultPickerTextStyle = TextStyle(letterSpacing: -0.83);

// Lays out the date picker based on how much space each single column needs.
//
// Each column is a child of this delegate, indexed from 0 to number of columns - 1.
// Each column will be padded horizontally by 12.0 both left and right.
//
// The picker will be placed in the center, and the leftmost and rightmost
// column will be extended equally to the remaining width.
class _DatePickerLayoutDelegate({
  // The list containing widths of all columns.
  required final List<double> columnWidths,

  // textDirectionFactor is 1 if text is written left to right, and -1 if right to left.
  required final int textDirectionFactor,
}) extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    var remainingWidth = size.width;

    for (var i = 0; i < columnWidths.length; i++) {
      remainingWidth -= columnWidths[i] + _kDatePickerPadSize * 2;
    }

    var currentHorizontalOffset = 0.0;

    for (var i = 0; i < columnWidths.length; i++) {
      final index = textDirectionFactor == 1 ? i : columnWidths.length - i - 1;

      var childWidth = columnWidths[index] + _kDatePickerPadSize * 2;
      if (index == 0 || index == columnWidths.length - 1) {
        childWidth += remainingWidth / 2;
      }

      layoutChild(index, BoxConstraints.tight(Size(childWidth, size.height)));
      positionChild(index, Offset(currentHorizontalOffset, 0.0));

      currentHorizontalOffset += childWidth;
    }
  }

  @override
  bool shouldRelayout(_DatePickerLayoutDelegate oldDelegate) {
    return !listEquals(columnWidths, oldDelegate.columnWidths) ||
        textDirectionFactor != oldDelegate.textDirectionFactor;
  }
}

enum _PickerColumnType { dayOfMonth, month, year }

String _localizedNumber(int value, Language language) {
  return language == .english
      ? '$value'
      : const NepaliUnicode().convert('$value');
}

/// Specifies date order arrangements in cupertino date picker.
enum DateOrder {
  /// Month Day Year
  mdy,

  /// Day Month Year
  dmy,

  /// Year Month Day
  ymd,

  /// Year Day Month
  ydm,
}

/// Cupertino styled nepali date picker.
// ignore: prefer_const_constructors_in_immutables
class NepaliCupertinoDatePicker({
  /// Callback called when the selected date changes. Must not be
  /// null.
  required final ValueChanged<NepaliDateTime> onDateChanged,
  NepaliDateTime? initialDate,

  /// Minimum year that the picker can be scrolled to.
  /// Defaults to 1 and must not be null.
  final int minimumYear = 1,

  /// Maximum year that the picker can be scrolled to. Null if there's no limit.
  final int? maximumYear,

  /// The language of the picker.
  ///
  /// When null, it is read from [languageSource].
  final Language? language,

  /// Where the language is read from when [language] is null.
  final LanguageSource languageSource = .app,

  /// Whether the default [initialDate] is today in Nepal instead of on the
  /// device.
  final bool useNepalTime = false,

  /// The arrangement of columns in the picker.
  final DateOrder dateOrder = .mdy,
  super.key,
}) extends StatefulWidget {
  /// The initial date of the picker.
  ///
  /// Changing this value after the initial build will not affect the currently
  /// selected date.
  final NepaliDateTime initialDate =
      initialDate ??
      (useNepalTime ? NepaliDateTime.nepalNow() : NepaliDateTime.now());

  @override
  State<StatefulWidget> createState() {
    return _CupertinoDatePickerDateState();
  }

  // Estimate the minimum width that each column needs to layout its content.
  static double _getColumnWidth(
    _PickerColumnType columnType,
    Language language,
    BuildContext context,
  ) {
    final longestText = switch (columnType) {
      // Every day number has at most two digits; 32 is the widest.
      .dayOfMonth => _localizedNumber(32, language),
      .month => List.generate(
        12,
        (i) => formattedMonth(i + 1, language),
      ).reduce((a, b) => a.length >= b.length ? a : b),
      .year => _localizedNumber(2076, language),
    };

    assert(longestText != '', 'column type is not appropriate');

    final painter = TextPainter(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        text: longestText,
      ),
      textDirection: Directionality.of(context),
    );

    // This operation is expensive and should be avoided. It is called here only
    // because there's no other way to get the information we want without
    // laying out the text.
    painter.layout();
    final width = painter.maxIntrinsicWidth;
    painter.dispose();
    return width;
  }
}

typedef _ColumnBuilder = Widget Function(
  double offAxisFraction,
  TransitionBuilder itemPositioningBuilder,
);

class _CupertinoDatePickerDateState extends State<NepaliCupertinoDatePicker> {
  late Language _language;

  late int textDirectionFactor;

  // Alignment based on text direction. The variable name is self descriptive,
  // however, when text direction is rtl, alignment is reversed.
  late Alignment alignCenterLeft;
  late Alignment alignCenterRight;

  // The currently selected values of the picker.
  late int selectedDay;
  late int selectedMonth;
  late int selectedYear;
  late int daysInCurrentMonth;

  late final FixedExtentScrollController dayController;
  late final FixedExtentScrollController monthController;
  late final FixedExtentScrollController yearController;

  // Estimated width of columns, computed lazily per column type.
  final Map<_PickerColumnType, double> estimatedColumnWidths = {};

  @override
  void initState() {
    super.initState();
    selectedDay = widget.initialDate.day;
    selectedMonth = widget.initialDate.month;
    selectedYear = widget.initialDate.year;

    dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    monthController = FixedExtentScrollController(
      initialItem: selectedMonth - 1,
    );
    yearController = FixedExtentScrollController(initialItem: selectedYear);
  }

  @override
  void dispose() {
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    textDirectionFactor = Directionality.of(context) == TextDirection.ltr
        ? 1
        : -1;

    alignCenterLeft = textDirectionFactor == 1
        ? Alignment.centerLeft
        : Alignment.centerRight;
    alignCenterRight = textDirectionFactor == 1
        ? Alignment.centerRight
        : Alignment.centerLeft;

    _resolveLanguage();
    daysInCurrentMonth = NepaliDateTime.utc(
      selectedYear,
      selectedMonth,
    ).totalDays;
  }

  @override
  void didUpdateWidget(NepaliCupertinoDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.language != oldWidget.language ||
        widget.languageSource != oldWidget.languageSource) {
      _resolveLanguage();
    }
  }

  void _resolveLanguage() {
    _language = widget.language ?? languageOf(context, widget.languageSource);
    // Widths depend on the language and the inherited text style.
    estimatedColumnWidths.clear();
  }

  Widget _buildDayPicker(
    double offAxisFraction,
    TransitionBuilder itemPositioningBuilder,
  ) {
    return CupertinoPicker(
      scrollController: dayController,
      offAxisFraction: offAxisFraction,
      itemExtent: _kItemExtent,
      useMagnifier: _kUseMagnifier,
      magnification: _kMagnification,
      backgroundColor: _kBackgroundColor,
      onSelectedItemChanged: (int index) {
        selectedDay = index + 1;
        if (selectedDay <= daysInCurrentMonth) {
          widget.onDateChanged(
            NepaliDateTime(selectedYear, selectedMonth, selectedDay),
          );
        }
      },
      looping: true,
      children: List<Widget>.generate(32, (int index) {
        TextStyle? disableTextStyle; // Null if not out of range.
        if (index >= daysInCurrentMonth) {
          disableTextStyle = const TextStyle(
            color: CupertinoColors.inactiveGray,
          );
        }
        return itemPositioningBuilder(
          context,
          Text(_localizedNumber(index + 1, _language), style: disableTextStyle),
        );
      }),
    );
  }

  Widget _buildMonthPicker(
    double offAxisFraction,
    TransitionBuilder itemPositioningBuilder,
  ) {
    return CupertinoPicker(
      scrollController: monthController,
      offAxisFraction: offAxisFraction,
      itemExtent: _kItemExtent,
      useMagnifier: _kUseMagnifier,
      magnification: _kMagnification,
      backgroundColor: _kBackgroundColor,
      onSelectedItemChanged: (int index) {
        setState(() {
          selectedMonth = index + 1;
          daysInCurrentMonth = NepaliDateTime.utc(
            selectedYear,
            selectedMonth,
          ).totalDays;
        });
        if (selectedDay <= daysInCurrentMonth) {
          widget.onDateChanged(
            NepaliDateTime(selectedYear, selectedMonth, selectedDay),
          );
        }
      },
      looping: true,
      children: List<Widget>.generate(12, (int index) {
        return itemPositioningBuilder(
          context,
          Text(formattedMonth(index + 1, _language)),
        );
      }),
    );
  }

  Widget _buildYearPicker(
    double offAxisFraction,
    TransitionBuilder itemPositioningBuilder,
  ) {
    return CupertinoPicker.builder(
      scrollController: yearController,
      itemExtent: _kItemExtent,
      offAxisFraction: offAxisFraction,
      useMagnifier: _kUseMagnifier,
      magnification: _kMagnification,
      backgroundColor: _kBackgroundColor,
      onSelectedItemChanged: (int index) {
        // Blank entries outside the supported years can't form a date.
        if (index < NepaliDateTime.minYear || index > NepaliDateTime.maxYear) {
          return;
        }
        setState(() {
          selectedYear = index;
          daysInCurrentMonth = NepaliDateTime.utc(
            selectedYear,
            selectedMonth,
          ).totalDays;
        });
        if (selectedDay <= daysInCurrentMonth) {
          widget.onDateChanged(
            NepaliDateTime(selectedYear, selectedMonth, selectedDay),
          );
        }
      },
      itemBuilder: (BuildContext context, int index) {
        // nepali_utils 4.0 throws a RangeError outside its supported years.
        if (index < widget.minimumYear || index < NepaliDateTime.minYear) {
          return null;
        }

        final maximumYear = widget.maximumYear ?? NepaliDateTime.maxYear;
        if (index > maximumYear || index > NepaliDateTime.maxYear) {
          return null;
        }

        return itemPositioningBuilder(
          context,
          Text(_localizedNumber(index, _language)),
        );
      },
    );
  }

  bool _keepInValidRange(ScrollEndNotification notification) {
    // Whenever scrolling lands on a day the month doesn't have, the picker
    // automatically scrolls back to the last valid day.
    final overflow = selectedDay - daysInCurrentMonth;
    if (overflow > 0) {
      SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
        if (!mounted) return;
        dayController.animateToItem(
          dayController.selectedItem - overflow,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final List<_PickerColumnType> columnTypes = switch (widget.dateOrder) {
      .mdy => const [_PickerColumnType.month, .dayOfMonth, .year],
      .dmy => const [_PickerColumnType.dayOfMonth, .month, .year],
      .ymd => const [_PickerColumnType.year, .month, .dayOfMonth],
      .ydm => const [_PickerColumnType.year, .dayOfMonth, .month],
    };
    final columnWidths = [
      for (final type in columnTypes) _getEstimatedColumnWidth(type),
    ];
    final padding = textDirectionFactor == 1
        ? const EdgeInsets.only(right: _kDatePickerPadSize)
        : const EdgeInsets.only(left: _kDatePickerPadSize);

    final pickers = <Widget>[];

    for (var i = 0; i < columnWidths.length; i++) {
      final offAxisFraction = (i - 1) * 0.3 * textDirectionFactor;
      final _ColumnBuilder buildColumn = switch (columnTypes[i]) {
        .dayOfMonth => _buildDayPicker,
        .month => _buildMonthPicker,
        .year => _buildYearPicker,
      };

      pickers.add(
        LayoutId(
          id: i,
          child: buildColumn(offAxisFraction, (
            BuildContext context,
            Widget? child,
          ) {
            return Container(
              alignment: i == columnWidths.length - 1
                  ? alignCenterLeft
                  : alignCenterRight,
              padding: i == 0 ? null : padding,
              child: Container(
                alignment: i == 0 ? alignCenterLeft : alignCenterRight,
                width: columnWidths[i] + _kDatePickerPadSize,
                child: child,
              ),
            );
          }),
        ),
      );
    }

    return MediaQuery.withNoTextScaling(
      child: NotificationListener<ScrollEndNotification>(
        onNotification: _keepInValidRange,
        child: DefaultTextStyle.merge(
          style: _kDefaultPickerTextStyle,
          child: CustomMultiChildLayout(
            delegate: _DatePickerLayoutDelegate(
              columnWidths: columnWidths,
              textDirectionFactor: textDirectionFactor,
            ),
            children: pickers,
          ),
        ),
      ),
    );
  }

  // Lazily calculate the column width of the column being displayed only.
  double _getEstimatedColumnWidth(_PickerColumnType columnType) {
    return estimatedColumnWidths[columnType] ??=
        NepaliCupertinoDatePicker._getColumnWidth(
          columnType,
          _language,
          context,
        );
  }
}

/// Shows Cupertino-styled nepali date picker.
void showCupertinoDatePicker({
  required BuildContext context,
  required NepaliDateTime initialDate,
  required NepaliDateTime firstDate,
  required NepaliDateTime lastDate,
  required ValueChanged<NepaliDateTime> onDateChanged,
  Language? language,
  LanguageSource languageSource = .app,
  DateOrder dateOrder = .mdy,
}) {
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

  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: _kPickerSheetHeight,
        padding: const EdgeInsets.only(top: 6.0),
        color: CupertinoColors.white,
        child: DefaultTextStyle(
          style: const TextStyle(color: CupertinoColors.black, fontSize: 22.0),
          child: GestureDetector(
            onTap: () {},
            child: SafeArea(
              top: false,
              child: NepaliCupertinoDatePicker(
                initialDate: initialDate,
                minimumYear: firstDate.year,
                maximumYear: lastDate.year,
                onDateChanged: onDateChanged,
                language: language,
                languageSource: languageSource,
                dateOrder: dateOrder,
              ),
            ),
          ),
        ),
      );
    },
  );
}
