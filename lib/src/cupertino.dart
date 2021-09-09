// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nepali_utils/nepali_utils.dart';

import 'material/date_picker.dart' show showMaterialDatePicker;
import 'utils.dart';

// Default aesthetic values obtained by comparing with iOS pickers.
const double _kItemExtent = 32.0;
const bool _kUseMagnifier = true;
const double _kMagnification = 1.05;
const double _kDatePickerPadSize = 12.0;
const double _kPickerSheetHeight = 216.0;
// Considers setting the default background color from the theme, in the future.
const Color _kBackgroundColor = CupertinoColors.white;

const TextStyle _kDefaultPickerTextStyle = TextStyle(
  letterSpacing: -0.83,
);

// Lays out the date picker based on how much space each single column needs.
//
// Each column is a child of this delegate, indexed from 0 to number of columns - 1.
// Each column will be padded horizontally by 12.0 both left and right.
//
// The picker will be placed in the center, and the leftmost and rightmost
// column will be extended equally to the remaining width.
class _DatePickerLayoutDelegate extends MultiChildLayoutDelegate {
  _DatePickerLayoutDelegate({
    required this.columnWidths,
    required this.textDirectionFactor,
  });

  // The list containing widths of all columns.
  final List<double> columnWidths;

  // textDirectionFactor is 1 if text is written left to right, and -1 if right to left.
  final int textDirectionFactor;

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
    return columnWidths != oldDelegate.columnWidths ||
        textDirectionFactor != oldDelegate.textDirectionFactor;
  }
}

enum _PickerColumnType {
  dayOfMonth,
  month,
  year,
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

class _CupertinoDatePicker extends StatefulWidget {
  _CupertinoDatePicker({
    required this.onDateChanged,
    NepaliDateTime? initialDate,
    this.minimumYear = 1,
    this.maximumYear,
    this.language = Language.english,
    this.dateOrder = DateOrder.mdy,
  }) : initialDate = initialDate ?? NepaliDateTime.now();

  /// The initial date of the picker.
  ///
  /// Changing this value after the initial build will not affect the currently
  /// selected date.
  final NepaliDateTime initialDate;

  /// Minimum year that the picker can be scrolled to.
  /// Defaults to 1 and must not be null.
  final int minimumYear;

  /// Maximum year that the picker can be scrolled to. Null if there's no limit.
  final int? maximumYear;

  /// Callback called when the selected date changes. Must not be
  /// null.
  final ValueChanged<NepaliDateTime> onDateChanged;

  final Language language;

  final DateOrder dateOrder;

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
    var longestText = '';

    switch (columnType) {
      case _PickerColumnType.dayOfMonth:
        for (var i = 1; i <= 32; i++) {
          final dayOfMonth =
              language == Language.english ? '$i' : NepaliUnicode.convert('$i');
          if (longestText.length < dayOfMonth.length) longestText = dayOfMonth;
        }
        break;
      case _PickerColumnType.month:
        for (var i = 1; i <= 12; i++) {
          final month = NepaliDateFormat.MMMM(language).format(
            NepaliDateTime(1970, i),
          );
          if (longestText.length < month.length) longestText = month;
        }
        break;
      case _PickerColumnType.year:
        longestText = NepaliDateFormat.y(language).format(
          NepaliDateTime(2076),
        );
        break;
    }

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

    return painter.maxIntrinsicWidth;
  }
}

typedef _ColumnBuilder = Widget Function(
    double offAxisFraction, TransitionBuilder itemPositioningBuilder);

class _CupertinoDatePickerDateState extends State<_CupertinoDatePicker> {
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

  // Estimated width of columns.
  Map<int, double> estimatedColumnWidths = <int, double>{};

  @override
  void initState() {
    super.initState();
    selectedDay = widget.initialDate.day;
    selectedMonth = widget.initialDate.month;
    selectedYear = widget.initialDate.year;

    dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    textDirectionFactor =
        Directionality.of(context) == TextDirection.ltr ? 1 : -1;

    alignCenterLeft =
        textDirectionFactor == 1 ? Alignment.centerLeft : Alignment.centerRight;
    alignCenterRight =
        textDirectionFactor == 1 ? Alignment.centerRight : Alignment.centerLeft;

    estimatedColumnWidths[_PickerColumnType.dayOfMonth.index] =
        _CupertinoDatePicker._getColumnWidth(
            _PickerColumnType.dayOfMonth, widget.language, context);
    estimatedColumnWidths[_PickerColumnType.month.index] =
        _CupertinoDatePicker._getColumnWidth(
            _PickerColumnType.month, widget.language, context);
    estimatedColumnWidths[_PickerColumnType.year.index] =
        _CupertinoDatePicker._getColumnWidth(
            _PickerColumnType.year, widget.language, context);
    daysInCurrentMonth = NepaliDateTime(selectedYear, selectedMonth).totalDays;
  }

  Widget _buildDayPicker(
      double offAxisFraction, TransitionBuilder itemPositioningBuilder) {
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
              NepaliDateTime(selectedYear, selectedMonth, selectedDay));
        }
      },
      children: List<Widget>.generate(32, (int index) {
        TextStyle? disableTextStyle; // Null if not out of range.
        if (index >= daysInCurrentMonth) {
          disableTextStyle =
              const TextStyle(color: CupertinoColors.inactiveGray);
        }
        return itemPositioningBuilder(
          context,
          Text(
            widget.language == Language.english
                ? '${index + 1}'
                : NepaliUnicode.convert('${index + 1}'),
            style: disableTextStyle,
          ),
        );
      }),
      looping: true,
    );
  }

  Widget _buildMonthPicker(
      double offAxisFraction, TransitionBuilder itemPositioningBuilder) {
    return CupertinoPicker(
      scrollController:
          FixedExtentScrollController(initialItem: selectedMonth - 1),
      offAxisFraction: offAxisFraction,
      itemExtent: _kItemExtent,
      useMagnifier: _kUseMagnifier,
      magnification: _kMagnification,
      backgroundColor: _kBackgroundColor,
      onSelectedItemChanged: (int index) {
        selectedMonth = index + 1;
        if (selectedDay <= daysInCurrentMonth) {
          widget.onDateChanged(
              NepaliDateTime(selectedYear, selectedMonth, selectedDay));
        }
      },
      children: List<Widget>.generate(12, (int index) {
        return itemPositioningBuilder(
          context,
          Text(
            formattedMonth(index + 1, widget.language),
          ),
        );
      }),
      looping: true,
    );
  }

  Widget _buildYearPicker(
      double offAxisFraction, TransitionBuilder itemPositioningBuilder) {
    return CupertinoPicker.builder(
      scrollController: FixedExtentScrollController(initialItem: selectedYear),
      itemExtent: _kItemExtent,
      offAxisFraction: offAxisFraction,
      useMagnifier: _kUseMagnifier,
      magnification: _kMagnification,
      backgroundColor: _kBackgroundColor,
      onSelectedItemChanged: (int index) {
        selectedYear = index;
        if (selectedDay <= daysInCurrentMonth) {
          widget.onDateChanged(
              NepaliDateTime(selectedYear, selectedMonth, selectedDay));
        }
      },
      itemBuilder: (BuildContext context, int index) {
        if (index < widget.minimumYear) return null;

        if (widget.maximumYear != null && index > widget.maximumYear!) {
          return null;
        }

        return itemPositioningBuilder(
          context,
          Text(
            widget.language == Language.english
                ? '$index'
                : NepaliUnicode.convert('$index'),
          ),
        );
      },
    );
  }

  bool _keepInValidRange(ScrollEndNotification notification) {
    // Whenever scrolling lands on an invalid entry, the picker
    // automatically scrolls to a valid one.
    final desiredDay = selectedDay % daysInCurrentMonth;
    if (desiredDay != selectedDay) {
      SchedulerBinding.instance!.addPostFrameCallback((Duration timestamp) {
        dayController.animateToItem(
          // The next valid date is also the amount of days overflown.
          dayController.selectedItem - desiredDay,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }
    setState(() {
      // Rebuild because the number of valid days per month are different
      // depending on the month and year.
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var pickerBuilders = <_ColumnBuilder>[];
    var columnWidths = <double>[];

    switch (widget.dateOrder) {
      case DateOrder.mdy:
        pickerBuilders = <_ColumnBuilder>[
          _buildMonthPicker,
          _buildDayPicker,
          _buildYearPicker
        ];
        columnWidths = <double>[
          _getEstimatedColumnWidth(_PickerColumnType.month),
          _getEstimatedColumnWidth(_PickerColumnType.dayOfMonth),
          _getEstimatedColumnWidth(_PickerColumnType.year),
        ];
        break;
      case DateOrder.dmy:
        pickerBuilders = <_ColumnBuilder>[
          _buildDayPicker,
          _buildMonthPicker,
          _buildYearPicker
        ];
        columnWidths = <double>[
          _getEstimatedColumnWidth(_PickerColumnType.dayOfMonth),
          _getEstimatedColumnWidth(_PickerColumnType.month),
          _getEstimatedColumnWidth(_PickerColumnType.year),
        ];
        break;
      case DateOrder.ymd:
        pickerBuilders = <_ColumnBuilder>[
          _buildYearPicker,
          _buildMonthPicker,
          _buildDayPicker
        ];
        columnWidths = <double>[
          _getEstimatedColumnWidth(_PickerColumnType.year),
          _getEstimatedColumnWidth(_PickerColumnType.month),
          _getEstimatedColumnWidth(_PickerColumnType.dayOfMonth),
        ];
        break;
      case DateOrder.ydm:
        pickerBuilders = <_ColumnBuilder>[
          _buildYearPicker,
          _buildDayPicker,
          _buildMonthPicker
        ];
        columnWidths = <double>[
          _getEstimatedColumnWidth(_PickerColumnType.year),
          _getEstimatedColumnWidth(_PickerColumnType.dayOfMonth),
          _getEstimatedColumnWidth(_PickerColumnType.month),
        ];
        break;
      default:
        assert(false, 'date order is not specified');
    }

    final pickers = <Widget>[];

    for (var i = 0; i < columnWidths.length; i++) {
      final offAxisFraction = (i - 1) * 0.3 * textDirectionFactor;

      var padding = const EdgeInsets.only(right: _kDatePickerPadSize);
      if (textDirectionFactor == -1) {
        padding = const EdgeInsets.only(left: _kDatePickerPadSize);
      }

      pickers.add(LayoutId(
        id: i,
        child: pickerBuilders[i](
          offAxisFraction,
          (BuildContext context, Widget? child) {
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
          },
        ),
      ));
    }

    return MediaQuery(
      data: const MediaQueryData(textScaleFactor: 1.0),
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
    if (estimatedColumnWidths[columnType.index] == null) {
      estimatedColumnWidths[columnType.index] =
          _CupertinoDatePicker._getColumnWidth(
        columnType,
        widget.language,
        context,
      );
    }

    return estimatedColumnWidths[columnType.index]!;
  }
}

/// Shows Cupertino-styled nepali date picker.
void showCupertinoDatePicker({
  required BuildContext context,
  required NepaliDateTime initialDate,
  required NepaliDateTime firstDate,
  required NepaliDateTime lastDate,
  required ValueChanged<NepaliDateTime> onDateChanged,
  Language language = Language.english,
  DateOrder dateOrder = DateOrder.mdy,
}) {
  assert(firstDate.year >= 1970 && lastDate.year <= 2100,
      'Invalid Date Range. Valid Range = [1970, 2100]');
  assert(!initialDate.isBefore(firstDate),
      'initialDate must be on or after firstDate');
  assert(!initialDate.isAfter(lastDate),
      'initialDate must be on or before lastDate');
  assert(
      !firstDate.isAfter(lastDate), 'lastDate must be on or after firstDate');

  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: _kPickerSheetHeight,
        padding: const EdgeInsets.only(top: 6.0),
        color: CupertinoColors.white,
        child: DefaultTextStyle(
          style: const TextStyle(
            color: CupertinoColors.black,
            fontSize: 22.0,
          ),
          child: GestureDetector(
            onTap: () {},
            child: SafeArea(
              top: false,
              child: _CupertinoDatePicker(
                initialDate: initialDate,
                minimumYear: firstDate.year,
                maximumYear: lastDate.year,
                onDateChanged: onDateChanged,
                language: language,
                dateOrder: dateOrder,
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<NepaliDateTime?> _showCupertinoDatePicker({
  required BuildContext context,
  required NepaliDateTime initialDate,
  required NepaliDateTime firstDate,
  required NepaliDateTime lastDate,
  Language language = Language.english,
  DateOrder dateOrder = DateOrder.mdy,
}) async {
  assert(firstDate.year >= 2000 && lastDate.year <= 2099,
      'Invalid Date Range. Valid Range = [2000, 2099]');
  assert(!initialDate.isBefore(firstDate),
      'initialDate must be on or after firstDate');
  assert(!initialDate.isAfter(lastDate),
      'initialDate must be on or before lastDate');
  assert(
      !firstDate.isAfter(lastDate), 'lastDate must be on or after firstDate');

  return await _showCupertinoPopup<NepaliDateTime>(
    context: context,
    builder: (BuildContext context) {
      NepaliDateTime? _selectedDate;
      return Container(
        height: _kPickerSheetHeight + 40.0,
        padding: const EdgeInsets.only(top: 6.0),
        color: CupertinoColors.white,
        child: DefaultTextStyle(
          style: const TextStyle(
            color: CupertinoColors.black,
            fontSize: 22.0,
          ),
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
                        onPressed: () => Navigator.pop(context, _selectedDate),
                      ),
                    ],
                  ),
                  Expanded(
                    child: _CupertinoDatePicker(
                      initialDate: NepaliDateTime.now(),
                      minimumYear: firstDate.year,
                      maximumYear: lastDate.year,
                      onDateChanged: (date) => _selectedDate = date,
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
  assert(firstDate.year >= 1970 && lastDate.year <= 2100,
      'Invalid Date Range. Valid Range = [1970, 2100]');
  assert(!initialDate.isBefore(firstDate),
      'initialDate must be on or after firstDate');
  assert(!initialDate.isAfter(lastDate),
      'initialDate must be on or before lastDate');
  assert(
      !firstDate.isAfter(lastDate), 'lastDate must be on or after firstDate');

  final theme = Theme.of(context);
  switch (theme.platform) {
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return await showMaterialDatePicker(
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

Future<T?> _showCupertinoPopup<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return Navigator.of(context, rootNavigator: true).push(
    _CupertinoPopupRoute<T>(
      builder: builder,
      barrierLabel: 'Dismiss',
    ),
  );
}

class _CupertinoPopupRoute<T> extends PopupRoute<T> {
  _CupertinoPopupRoute({
    required this.builder,
    required this.barrierLabel,
    RouteSettings? settings,
  }) : super(settings: settings);

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
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionalTranslation(
        translation: _offsetTween.evaluate(_animation),
        child: child,
      ),
    );
  }
}
