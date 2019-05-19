// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:nepali_utils/nepali_utils.dart';

var daysInMonths = <int, List<int>>{};
var startDayInMonths = <int, List<int>>{};

// Examples can assume:
// BuildContext context;

/// Initial display mode of the date picker dialog.
///
/// Date picker UI mode for either showing a list of available years or a
/// monthly calendar initially in the dialog shown by calling [showDatePicker].
///
/// See also:
///
///  * [showDatePicker], which shows a dialog that contains a material design
///    date picker.
enum DatePickerMode {
  /// Show a date picker UI for choosing a month and day.
  day,

  /// Show a date picker UI for choosing a year.
  year,
}

const double _kDatePickerHeaderPortraitHeight = 100.0;
const double _kDatePickerHeaderLandscapeWidth = 168.0;

const Duration _kMonthScrollDuration = Duration(milliseconds: 200);
const double _kDayPickerRowHeight = 42.0;
const int _kMaxDayPickerRowCount = 6; // A 31 day month that starts on Saturday.
// Two extra rows: one for the day-of-week header and one for the month header.
const double _kMaxDayPickerHeight =
    _kDayPickerRowHeight * (_kMaxDayPickerRowCount + 2);

const double _kMonthPickerPortraitWidth = 330.0;
const double _kMonthPickerLandscapeWidth = 344.0;

const double _kDialogActionBarHeight = 52.0;
const double _kDatePickerLandscapeHeight =
    _kMaxDayPickerHeight + _kDialogActionBarHeight;

// Shows the selected date in large font and toggles between year and day mode
class _DatePickerHeader extends StatelessWidget {
  const _DatePickerHeader({
    Key key,
    @required this.selectedDate,
    @required this.mode,
    @required this.onModeChanged,
    @required this.orientation,
    @required this.language,
  })  : assert(selectedDate != null),
        assert(mode != null),
        assert(orientation != null),
        super(key: key);

  final NepaliDateTime selectedDate;
  final DatePickerMode mode;
  final ValueChanged<DatePickerMode> onModeChanged;
  final Orientation orientation;
  final Language language;

  void _handleChangeMode(DatePickerMode value) {
    if (value != mode) onModeChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme headerTextTheme = themeData.primaryTextTheme;
    Color dayColor;
    Color yearColor;
    switch (themeData.primaryColorBrightness) {
      case Brightness.light:
        dayColor = mode == DatePickerMode.day ? Colors.black87 : Colors.black54;
        yearColor =
            mode == DatePickerMode.year ? Colors.black87 : Colors.black54;
        break;
      case Brightness.dark:
        dayColor = mode == DatePickerMode.day ? Colors.white : Colors.white70;
        yearColor = mode == DatePickerMode.year ? Colors.white : Colors.white70;
        break;
    }
    final TextStyle dayStyle =
        headerTextTheme.display1.copyWith(color: dayColor, height: 1.4);
    final TextStyle yearStyle =
        headerTextTheme.subhead.copyWith(color: yearColor, height: 1.4);

    Color backgroundColor;
    switch (themeData.brightness) {
      case Brightness.light:
        backgroundColor = themeData.primaryColor;
        break;
      case Brightness.dark:
        backgroundColor = themeData.backgroundColor;
        break;
    }

    double width;
    double height;
    EdgeInsets padding;
    MainAxisAlignment mainAxisAlignment;
    switch (orientation) {
      case Orientation.portrait:
        height = _kDatePickerHeaderPortraitHeight;
        padding = const EdgeInsets.symmetric(horizontal: 16.0);
        mainAxisAlignment = MainAxisAlignment.center;
        break;
      case Orientation.landscape:
        width = _kDatePickerHeaderLandscapeWidth;
        padding = const EdgeInsets.all(8.0);
        mainAxisAlignment = MainAxisAlignment.start;
        break;
    }

    final Widget yearButton = IgnorePointer(
      ignoring: mode != DatePickerMode.day,
      ignoringSemantics: false,
      child: _DateHeaderButton(
        color: backgroundColor,
        onTap: Feedback.wrapForTap(
            () => _handleChangeMode(DatePickerMode.year), context),
        child: Semantics(
          selected: mode == DatePickerMode.year,
          child: Text(
              NepaliDateFormatter("yyyy", language: language)
                  .format(selectedDate),
              style: yearStyle),
        ),
      ),
    );

    final Widget dayButton = IgnorePointer(
      ignoring: mode == DatePickerMode.day,
      ignoringSemantics: false,
      child: _DateHeaderButton(
        color: backgroundColor,
        onTap: Feedback.wrapForTap(
            () => _handleChangeMode(DatePickerMode.day), context),
        child: Semantics(
          selected: mode == DatePickerMode.day,
          child: Text(
              NepaliDateFormatter("EE, MMMM dd", language: language)
                  .format(selectedDate),
              style: dayStyle),
        ),
      ),
    );

    return Container(
      width: width,
      height: height,
      padding: padding,
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[yearButton, dayButton],
      ),
    );
  }
}

class _DateHeaderButton extends StatelessWidget {
  const _DateHeaderButton({
    Key key,
    this.onTap,
    this.color,
    this.child,
  }) : super(key: key);

  final VoidCallback onTap;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      type: MaterialType.button,
      color: color,
      child: InkWell(
        borderRadius: kMaterialEdges[MaterialType.button],
        highlightColor: theme.highlightColor,
        splashColor: theme.splashColor,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: child,
        ),
      ),
    );
  }
}

class _DayPickerGridDelegate extends SliverGridDelegate {
  const _DayPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = 7;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double tileHeight = math.min(_kDayPickerRowHeight,
        constraints.viewportMainAxisExtent / (_kMaxDayPickerRowCount + 1));
    return SliverGridRegularTileLayout(
      crossAxisCount: columnCount,
      mainAxisStride: tileHeight,
      crossAxisStride: tileWidth,
      childMainAxisExtent: tileHeight,
      childCrossAxisExtent: tileWidth,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_DayPickerGridDelegate oldDelegate) => false;
}

const _DayPickerGridDelegate _kDayPickerGridDelegate = _DayPickerGridDelegate();

/// Displays the days of a given month and allows choosing a day.
///
/// The days are arranged in a rectangular grid with one column for each day of
/// the week.
///
/// The day picker widget is rarely used directly. Instead, consider using
/// [showDatePicker], which creates a date picker dialog.
///
/// See also:
///
///  * [showDatePicker], which shows a dialog that contains a material design
///    date picker.
///  * [showTimePicker], which shows a dialog that contains a material design
///    time picker.
class DayPicker extends StatelessWidget {
  /// Creates a day picker.
  ///
  /// Rarely used directly. Instead, typically used as part of a [MonthPicker].
  DayPicker({
    Key key,
    @required this.selectedDate,
    @required this.currentDate,
    @required this.onChanged,
    @required this.firstDate,
    @required this.lastDate,
    @required this.displayedMonth,
    @required this.language,
    this.selectableDayPredicate,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(selectedDate != null),
        assert(currentDate != null),
        assert(onChanged != null),
        assert(displayedMonth != null),
        assert(dragStartBehavior != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(selectedDate.isAfter(firstDate)),
        super(key: key);

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final NepaliDateTime selectedDate;

  /// The current date at the time the picker is displayed.
  final NepaliDateTime currentDate;

  /// Called when the user picks a day.
  final ValueChanged<NepaliDateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  final NepaliDateTime firstDate;

  /// The latest date the user is permitted to pick.
  final NepaliDateTime lastDate;

  /// The month whose days are displayed by this picker.
  final NepaliDateTime displayedMonth;

  /// Optional user supplied predicate function to customize selectable days.
  final SelectableDayPredicate selectableDayPredicate;

  /// Determines the way that drag start behavior is handled.
  ///
  /// If set to [DragStartBehavior.start], the drag gesture used to scroll a
  /// date picker wheel will begin upon the detection of a drag gesture. If set
  /// to [DragStartBehavior.down] it will begin when a down event is first
  /// detected.
  ///
  /// In general, setting this to [DragStartBehavior.start] will make drag
  /// animation smoother and setting it to [DragStartBehavior.down] will make
  /// drag behavior feel slightly more reactive.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// See also:
  ///
  ///  * [DragGestureRecognizer.dragStartBehavior], which gives an example for the different behaviors.
  final DragStartBehavior dragStartBehavior;

  final Language language;

  List<Widget> _getDayHeaders(Language language, TextStyle headerStyle) {
    var result = <Widget>[];
    language == Language.ENGLISH
        ? ['S', 'M', 'T', 'W', 'T', 'F', 'S'].forEach(
            (label) => result.add(
                  ExcludeSemantics(
                    child: Center(
                      child: Text(label, style: headerStyle),
                    ),
                  ),
                ),
          )
        : ['आ', 'सो', 'मं', 'बु', 'वि', 'शु', 'श'].forEach(
            (label) => result.add(
                  ExcludeSemantics(
                    child: Center(
                      child: Text(label, style: headerStyle),
                    ),
                  ),
                ),
          );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final int year = displayedMonth.year;
    final int month = displayedMonth.month;
    final int daysInMonth = daysInMonths[year][month];
    final int firstDayOffset = startDayInMonths[year][month] - 1;
    final labels = <Widget>[];
    labels.addAll(
      _getDayHeaders(language, themeData.textTheme.caption),
    );
    for (int i = 0; true; i += 1) {
      // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
      // a leap year.
      final int day = i - firstDayOffset + 1;
      if (day > daysInMonth) break;
      if (day < 1) {
        labels.add(Container());
      } else {
        final NepaliDateTime dayToBuild = NepaliDateTime(year, month, day);
        final bool disabled = dayToBuild.isAfter(lastDate) ||
            dayToBuild.isBefore(firstDate) ||
            (selectableDayPredicate != null &&
                !selectableDayPredicate(dayToBuild));

        BoxDecoration decoration;
        TextStyle itemStyle = themeData.textTheme.body1;

        final bool isSelectedDay = selectedDate.year == year &&
            selectedDate.month == month &&
            selectedDate.day == day;
        if (isSelectedDay) {
          // The selected day gets a circle background highlight, and a contrasting text color.
          itemStyle = themeData.accentTextTheme.body2;
          decoration = BoxDecoration(
            color: themeData.accentColor,
            shape: BoxShape.circle,
          );
        } else if (disabled) {
          itemStyle = themeData.textTheme.body1
              .copyWith(color: themeData.disabledColor);
        } else if (currentDate.year == year &&
            currentDate.month == month &&
            currentDate.day == day) {
          // The current day gets a different text color.
          itemStyle =
              themeData.textTheme.body2.copyWith(color: themeData.accentColor);
        }

        Widget dayWidget = Container(
          decoration: decoration,
          child: Center(
            child: Semantics(
              label: '${_indexToMonth(month, Language.ENGLISH)} $day, $year',
              selected: isSelectedDay,
              child: ExcludeSemantics(
                child: Text(
                    '${language == Language.ENGLISH ? day : NepaliNumber.from(day)}',
                    style: itemStyle),
              ),
            ),
          ),
        );

        if (!disabled) {
          dayWidget = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              onChanged(dayToBuild);
            },
            child: dayWidget,
            dragStartBehavior: dragStartBehavior,
          );
        }

        labels.add(dayWidget);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: <Widget>[
          Container(
            height: _kDayPickerRowHeight,
            child: Center(
              child: ExcludeSemantics(
                child: Text(
                  '${_indexToMonth(month, language)} ${language == Language.ENGLISH ? year : NepaliNumber.from(year)}',
                  style: themeData.textTheme.subhead,
                ),
              ),
            ),
          ),
          Flexible(
            child: GridView.custom(
              gridDelegate: _kDayPickerGridDelegate,
              childrenDelegate:
                  SliverChildListDelegate(labels, addRepaintBoundaries: false),
            ),
          ),
        ],
      ),
    );
  }
}

/// A scrollable list of months to allow picking a month.
///
/// Shows the days of each month in a rectangular grid with one column for each
/// day of the week.
///
/// The month picker widget is rarely used directly. Instead, consider using
/// [showDatePicker], which creates a date picker dialog.
///
/// See also:
///
///  * [showDatePicker], which shows a dialog that contains a material design
///    date picker.
///  * [showTimePicker], which shows a dialog that contains a material design
///    time picker.
class MonthPicker extends StatefulWidget {
  /// Creates a month picker.
  ///
  /// Rarely used directly. Instead, typically used as part of the dialog shown
  /// by [showDatePicker].
  MonthPicker({
    Key key,
    @required this.selectedDate,
    @required this.onChanged,
    @required this.firstDate,
    @required this.lastDate,
    @required this.language,
    this.selectableDayPredicate,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(selectedDate != null),
        assert(onChanged != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(selectedDate.isAfter(firstDate)),
        super(key: key);

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final NepaliDateTime selectedDate;

  /// Called when the user picks a month.
  final ValueChanged<NepaliDateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  final NepaliDateTime firstDate;

  /// The latest date the user is permitted to pick.
  final NepaliDateTime lastDate;

  /// Optional user supplied predicate function to customize selectable days.
  final SelectableDayPredicate selectableDayPredicate;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;
  final Language language;

  @override
  _MonthPickerState createState() => _MonthPickerState();
}

class _MonthPickerState extends State<MonthPicker>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _chevronOpacityTween =
      Tween<double>(begin: 1.0, end: 0.0)
          .chain(CurveTween(curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    // Initially display the pre-selected date.
    final int monthPage = _monthDelta(widget.firstDate, widget.selectedDate);
    _dayPickerController = PageController(initialPage: monthPage);
    _handleMonthPageChanged(monthPage);
    _updateCurrentDate();

    // Setup the fade animation for chevrons
    _chevronOpacityController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _chevronOpacityAnimation =
        _chevronOpacityController.drive(_chevronOpacityTween);
  }

  @override
  void didUpdateWidget(MonthPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      final int monthPage = _monthDelta(widget.firstDate, widget.selectedDate);
      _dayPickerController = PageController(initialPage: monthPage);
      _handleMonthPageChanged(monthPage);
    }
  }

  TextDirection textDirection;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    textDirection = Directionality.of(context);
  }

  NepaliDateTime _todayDate;
  NepaliDateTime _currentDisplayedMonthDate;
  Timer _timer;
  PageController _dayPickerController;
  AnimationController _chevronOpacityController;
  Animation<double> _chevronOpacityAnimation;

  void _updateCurrentDate() {
    _todayDate = NepaliDateTime.now();
    final NepaliDateTime tomorrow =
        NepaliDateTime(_todayDate.year, _todayDate.month, _todayDate.day + 1);
    Duration timeUntilTomorrow = tomorrow.difference(_todayDate);
    timeUntilTomorrow +=
        const Duration(seconds: 1); // so we don't miss it by rounding
    _timer?.cancel();
    _timer = Timer(timeUntilTomorrow, () {
      setState(() {
        _updateCurrentDate();
      });
    });
  }

  static int _monthDelta(NepaliDateTime startDate, NepaliDateTime endDate) {
    return (endDate.year - startDate.year) * 12 +
        endDate.month -
        startDate.month;
  }

  /// Add months to a month truncated date.
  NepaliDateTime _addMonthsToMonthDate(
      NepaliDateTime monthDate, int monthsToAdd) {
    return NepaliDateTime(
        monthDate.year + monthsToAdd ~/ 12, monthDate.month + monthsToAdd % 12);
  }

  Widget _buildItems(BuildContext context, int index) {
    final NepaliDateTime month = _addMonthsToMonthDate(widget.firstDate, index);
    return DayPicker(
      key: ValueKey<NepaliDateTime>(month),
      selectedDate: widget.selectedDate,
      currentDate: _todayDate,
      onChanged: widget.onChanged,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: month,
      language: widget.language,
      selectableDayPredicate: widget.selectableDayPredicate,
      dragStartBehavior: widget.dragStartBehavior,
    );
  }

  void _handleNextMonth() {
    if (!_isDisplayingLastMonth) {
      SemanticsService.announce(
          "${_indexToMonth(_nextMonthDate.month, Language.ENGLISH)} ${_nextMonthDate.year}",
          textDirection);
      _dayPickerController.nextPage(
          duration: _kMonthScrollDuration, curve: Curves.ease);
    }
  }

  void _handlePreviousMonth() {
    if (!_isDisplayingFirstMonth) {
      SemanticsService.announce(
          "${_indexToMonth(_previousMonthDate.month, Language.ENGLISH)} ${_previousMonthDate.year}",
          textDirection);
      _dayPickerController.previousPage(
          duration: _kMonthScrollDuration, curve: Curves.ease);
    }
  }

  /// True if the earliest allowable month is displayed.
  bool get _isDisplayingFirstMonth {
    return !_currentDisplayedMonthDate
        .isAfter(NepaliDateTime(widget.firstDate.year, widget.firstDate.month));
  }

  /// True if the latest allowable month is displayed.
  bool get _isDisplayingLastMonth {
    return !_currentDisplayedMonthDate
        .isBefore(NepaliDateTime(widget.lastDate.year, widget.lastDate.month));
  }

  NepaliDateTime _previousMonthDate;
  NepaliDateTime _nextMonthDate;

  void _handleMonthPageChanged(int monthPage) {
    setState(() {
      _previousMonthDate =
          _addMonthsToMonthDate(widget.firstDate, monthPage - 1);
      _currentDisplayedMonthDate =
          _addMonthsToMonthDate(widget.firstDate, monthPage);
      _nextMonthDate = _addMonthsToMonthDate(widget.firstDate, monthPage + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kMonthPickerPortraitWidth,
      height: _kMaxDayPickerHeight,
      child: Stack(
        children: <Widget>[
          Semantics(
            sortKey: _MonthPickerSortKey.calendar,
            child: NotificationListener<ScrollStartNotification>(
              onNotification: (_) {
                _chevronOpacityController.forward();
                return false;
              },
              child: NotificationListener<ScrollEndNotification>(
                onNotification: (_) {
                  _chevronOpacityController.reverse();
                  return false;
                },
                child: PageView.builder(
                  dragStartBehavior: widget.dragStartBehavior,
                  key: ValueKey<NepaliDateTime>(widget.selectedDate),
                  controller: _dayPickerController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _monthDelta(widget.firstDate, widget.lastDate) + 1,
                  itemBuilder: _buildItems,
                  onPageChanged: _handleMonthPageChanged,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 0.0,
            start: 8.0,
            child: Semantics(
              sortKey: _MonthPickerSortKey.previousMonth,
              child: FadeTransition(
                opacity: _chevronOpacityAnimation,
                child: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: _isDisplayingFirstMonth
                      ? null
                      : 'Previous month ${_indexToMonth(_previousMonthDate.month, Language.ENGLISH)} ${_previousMonthDate.year}',
                  onPressed:
                      _isDisplayingFirstMonth ? null : _handlePreviousMonth,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 0.0,
            end: 8.0,
            child: Semantics(
              sortKey: _MonthPickerSortKey.nextMonth,
              child: FadeTransition(
                opacity: _chevronOpacityAnimation,
                child: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: _isDisplayingLastMonth
                      ? null
                      : 'Next month ${_indexToMonth(_nextMonthDate.month, Language.ENGLISH)} ${_nextMonthDate.year}',
                  onPressed: _isDisplayingLastMonth ? null : _handleNextMonth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dayPickerController?.dispose();
    super.dispose();
  }
}

// Defines semantic traversal order of the top-level widgets inside the month
// picker.
class _MonthPickerSortKey extends OrdinalSortKey {
  const _MonthPickerSortKey(double order) : super(order);

  static const _MonthPickerSortKey previousMonth = _MonthPickerSortKey(1.0);
  static const _MonthPickerSortKey nextMonth = _MonthPickerSortKey(2.0);
  static const _MonthPickerSortKey calendar = _MonthPickerSortKey(3.0);
}

/// A scrollable list of years to allow picking a year.
///
/// The year picker widget is rarely used directly. Instead, consider using
/// [showDatePicker], which creates a date picker dialog.
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// See also:
///
///  * [showDatePicker], which shows a dialog that contains a material design
///    date picker.
///  * [showTimePicker], which shows a dialog that contains a material design
///    time picker.
class YearPicker extends StatefulWidget {
  /// Creates a year picker.
  ///
  /// The [selectedDate] and [onChanged] arguments must not be null. The
  /// [lastDate] must be after the [firstDate].
  ///
  /// Rarely used directly. Instead, typically used as part of the dialog shown
  /// by [showDatePicker].
  YearPicker({
    Key key,
    @required this.selectedDate,
    @required this.onChanged,
    @required this.firstDate,
    @required this.lastDate,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(selectedDate != null),
        assert(onChanged != null),
        assert(!firstDate.isAfter(lastDate)),
        super(key: key);

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final NepaliDateTime selectedDate;

  /// Called when the user picks a year.
  final ValueChanged<NepaliDateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  final NepaliDateTime firstDate;

  /// The latest date the user is permitted to pick.
  final NepaliDateTime lastDate;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  @override
  _YearPickerState createState() => _YearPickerState();
}

class _YearPickerState extends State<YearPicker> {
  static const double _itemExtent = 50.0;
  ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(
      // Move the initial scroll position to the currently selected date's year.
      initialScrollOffset:
          (widget.selectedDate.year - widget.firstDate.year) * _itemExtent,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final ThemeData themeData = Theme.of(context);
    final TextStyle style = themeData.textTheme.body1;
    return ListView.builder(
      dragStartBehavior: widget.dragStartBehavior,
      controller: scrollController,
      itemExtent: _itemExtent,
      itemCount: widget.lastDate.year - widget.firstDate.year + 1,
      itemBuilder: (BuildContext context, int index) {
        final int year = widget.firstDate.year + index;
        final bool isSelected = year == widget.selectedDate.year;
        final TextStyle itemStyle = isSelected
            ? themeData.textTheme.headline
                .copyWith(color: themeData.accentColor)
            : style;
        return InkWell(
          key: ValueKey<int>(year),
          onTap: () {
            widget.onChanged(NepaliDateTime(
                year, widget.selectedDate.month, widget.selectedDate.day));
          },
          child: Center(
            child: Semantics(
              selected: isSelected,
              child: Text(year.toString(), style: itemStyle),
            ),
          ),
        );
      },
    );
  }
}

class _DatePickerDialog extends StatefulWidget {
  const _DatePickerDialog({
    Key key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.initialDatePickerMode,
    this.language,
  }) : super(key: key);

  final NepaliDateTime initialDate;
  final NepaliDateTime firstDate;
  final NepaliDateTime lastDate;
  final SelectableDayPredicate selectableDayPredicate;
  final DatePickerMode initialDatePickerMode;
  final Language language;

  @override
  _DatePickerDialogState createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  @override
  void initState() {
    super.initState();
    _initializeDaysInMonths();
    _initializeStartDayInMonths();
    _selectedDate = widget.initialDate;
    _mode = widget.initialDatePickerMode;
  }

  @override
  void dispose() {
    daysInMonths.clear();
    startDayInMonths.clear();
    super.dispose();
  }

  bool _announcedInitialDate = false;

  MaterialLocalizations localizations;
  TextDirection textDirection;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    textDirection = Directionality.of(context);
    if (!_announcedInitialDate) {
      _announcedInitialDate = true;
      SemanticsService.announce(
        NepaliDateFormatter("MMMM dd, yyyy").format(_selectedDate),
        textDirection,
      );
    }
  }

  NepaliDateTime _selectedDate;
  DatePickerMode _mode;
  final GlobalKey _pickerKey = GlobalKey();

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        HapticFeedback.vibrate();
        break;
      case TargetPlatform.iOS:
        break;
    }
  }

  void _handleModeChanged(DatePickerMode mode) {
    _vibrate();
    setState(() {
      _mode = mode;
      if (_mode == DatePickerMode.day) {
        SemanticsService.announce(
            NepaliDateFormatter("MMMM yyyy").format(_selectedDate),
            textDirection);
      } else {
        SemanticsService.announce(
            NepaliDateFormatter("yyyy").format(_selectedDate), textDirection);
      }
    });
  }

  void _handleYearChanged(NepaliDateTime value) {
    if (value.isBefore(widget.firstDate))
      value = widget.firstDate;
    else if (value.isAfter(widget.lastDate)) value = widget.lastDate;
    if (value == _selectedDate) return;

    _vibrate();
    setState(() {
      _mode = DatePickerMode.day;
      _selectedDate = value;
    });
  }

  void _handleDayChanged(NepaliDateTime value) {
    _vibrate();
    setState(() {
      _selectedDate = value;
    });
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() {
    Navigator.pop(context, _selectedDate);
  }

  Widget _buildPicker() {
    assert(_mode != null);
    switch (_mode) {
      case DatePickerMode.day:
        return MonthPicker(
          key: _pickerKey,
          language: widget.language,
          selectedDate: _selectedDate,
          onChanged: _handleDayChanged,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          selectableDayPredicate: widget.selectableDayPredicate,
        );
      case DatePickerMode.year:
        return YearPicker(
          key: _pickerKey,
          selectedDate: _selectedDate,
          onChanged: _handleYearChanged,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
        );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget picker = Flexible(
      child: SizedBox(
        height: _kMaxDayPickerHeight,
        child: _buildPicker(),
      ),
    );
    final Widget actions = ButtonTheme.bar(
      child: ButtonBar(
        children: <Widget>[
          FlatButton(
            child: Text(widget.language == Language.ENGLISH
                ? 'CANCEL'
                : 'रद्द गर्नुहोस'),
            onPressed: _handleCancel,
          ),
          FlatButton(
            child: Text(widget.language == Language.ENGLISH ? 'OK' : 'ठिक छ'),
            onPressed: _handleOk,
          ),
        ],
      ),
    );
    final Dialog dialog = Dialog(
      child: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
        assert(orientation != null);
        final Widget header = _DatePickerHeader(
          selectedDate: _selectedDate,
          mode: _mode,
          onModeChanged: _handleModeChanged,
          orientation: orientation,
          language: widget.language,
        );
        switch (orientation) {
          case Orientation.portrait:
            return SizedBox(
              width: _kMonthPickerPortraitWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  header,
                  Container(
                    color: theme.dialogBackgroundColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        picker,
                        actions,
                      ],
                    ),
                  ),
                ],
              ),
            );
          case Orientation.landscape:
            return SizedBox(
              height: _kDatePickerLandscapeHeight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  header,
                  Flexible(
                    child: Container(
                      width: _kMonthPickerLandscapeWidth,
                      color: theme.dialogBackgroundColor,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[picker, actions],
                      ),
                    ),
                  ),
                ],
              ),
            );
        }
        return null;
      }),
    );

    return Theme(
      data: theme.copyWith(
        dialogBackgroundColor: Colors.transparent,
      ),
      child: dialog,
    );
  }
}

/// Signature for predicating dates for enabled date selections.
///
/// See [showDatePicker].
typedef SelectableDayPredicate = bool Function(NepaliDateTime day);

/// Shows a dialog containing a material design date picker.
///
/// The returned [Future] resolves to the date selected by the user when the
/// user closes the dialog. If the user cancels the dialog, null is returned.
///
/// An optional [selectableDayPredicate] function can be passed in to customize
/// the days to enable for selection. If provided, only the days that
/// [selectableDayPredicate] returned true for will be selectable.
///
/// An optional [initialDatePickerMode] argument can be used to display the
/// date picker initially in the year or month+day picker mode. It defaults
/// to month+day, and must not be null.
///
/// An optional [textDirection] argument can be used to set the text direction
/// (RTL or LTR) for the date picker. It defaults to the ambient text direction
/// provided by [Directionality]. If both [locale] and [textDirection] are not
/// null, [textDirection] overrides the direction chosen for the [locale].
///
/// The [context] argument is passed to [showDialog], the documentation for
/// which discusses how it is used.
///
/// The [builder] parameter can be used to wrap the dialog widget
/// to add inherited widgets like [Theme].
///
/// {@tool sample}
/// Show a date picker with the dark theme.
///
/// ```dart
/// Future<NepaliDateTime> selectedDate = showDatePicker(
///   context: context,
///   initialDate: NepaliDateTime.now(),
///   firstDate: NepaliDateTime(2018),
///   lastDate: NepaliDateTime(2030),
///   builder: (BuildContext context, Widget child) {
///     return Theme(
///       data: ThemeData.dark(),
///       child: child,
///     );
///   },
/// );
/// ```
/// {@end-tool}
///
/// The [context], [initialDate], [firstDate], and [lastDate] parameters must
/// not be null.
///
/// See also:
///
///  * [showTimePicker], which shows a dialog that contains a material design
///    time picker.
///  * [DayPicker], which displays the days of a given month and allows
///    choosing a day.
///  * [MonthPicker], which displays a scrollable list of months to allow
///    picking a month.
///  * [YearPicker], which displays a scrollable list of years to allow picking
///    a year.
Future<NepaliDateTime> showNepaliDatePicker({
  @required BuildContext context,
  @required NepaliDateTime initialDate,
  @required NepaliDateTime firstDate,
  @required NepaliDateTime lastDate,
  SelectableDayPredicate selectableDayPredicate,
  DatePickerMode initialDatePickerMode = DatePickerMode.day,
  Language language = Language.ENGLISH,
  TextDirection textDirection,
  TransitionBuilder builder,
}) async {
  assert(initialDate != null);
  assert(firstDate != null);
  assert(lastDate != null);
  assert(!initialDate.isBefore(firstDate),
      'initialDate must be on or after firstDate');
  assert(!initialDate.isAfter(lastDate),
      'initialDate must be on or before lastDate');
  assert(
      !firstDate.isAfter(lastDate), 'lastDate must be on or after firstDate');
  assert(selectableDayPredicate == null || selectableDayPredicate(initialDate),
      'Provided initialDate must satisfy provided selectableDayPredicate');
  assert(
      initialDatePickerMode != null, 'initialDatePickerMode must not be null');
  assert(context != null);
  assert(debugCheckHasMaterialLocalizations(context));

  Widget child = _DatePickerDialog(
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    selectableDayPredicate: selectableDayPredicate,
    initialDatePickerMode: initialDatePickerMode,
    language: language,
  );

  if (textDirection != null) {
    child = Directionality(
      textDirection: textDirection,
      child: child,
    );
  }

  return await showDialog<NepaliDateTime>(
    context: context,
    builder: (BuildContext context) {
      return builder == null ? child : builder(context, child);
    },
  );
}

String _indexToMonth(int index, Language language) =>
    NepaliDateFormatter('MMMM', language: language)
        .format(NepaliDateTime(0, index));

void _initializeDaysInMonths() {
  daysInMonths[2000] = [0, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2001] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2002] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2003] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2004] = [0, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2005] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2006] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2007] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2008] = [0, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31];
  daysInMonths[2009] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2010] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2011] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2012] = [0, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30];
  daysInMonths[2013] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2014] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2015] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2016] = [0, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30];
  daysInMonths[2017] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2018] = [0, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2019] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2020] = [0, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2021] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2022] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30];
  daysInMonths[2023] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2024] = [0, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2025] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2026] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2027] = [0, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2028] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2029] = [0, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2030] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2031] = [0, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2032] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2033] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2034] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2035] = [0, 30, 32, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31];
  daysInMonths[2036] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2037] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2038] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2039] = [0, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30];
  daysInMonths[2040] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2041] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2042] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2043] = [0, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30];
  daysInMonths[2044] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2045] = [0, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2046] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2047] = [0, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2048] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2049] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30];
  daysInMonths[2050] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2051] = [0, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2052] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2053] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30];
  daysInMonths[2054] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2055] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2056] = [0, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2057] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2058] = [0, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2059] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2060] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2061] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2062] = [0, 30, 32, 31, 32, 31, 31, 29, 30, 29, 30, 29, 31];
  daysInMonths[2063] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2064] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2065] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2066] = [0, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31];
  daysInMonths[2067] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2068] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2069] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2070] = [0, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30];
  daysInMonths[2071] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2072] = [0, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2073] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2074] = [0, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2075] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2076] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30];
  daysInMonths[2077] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2078] = [0, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2079] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2080] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30];
  daysInMonths[2081] = [0, 31, 31, 32, 32, 31, 30, 30, 30, 29, 30, 30, 30];
  daysInMonths[2082] = [0, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30];
  daysInMonths[2083] = [0, 31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 30, 30];
  daysInMonths[2084] = [0, 31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 30, 30];
  daysInMonths[2085] = [0, 31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 30, 30];
  daysInMonths[2086] = [0, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30];
  daysInMonths[2087] = [0, 31, 31, 32, 31, 31, 31, 30, 30, 29, 30, 30, 30];
  daysInMonths[2088] = [0, 30, 31, 32, 32, 30, 31, 30, 30, 29, 30, 30, 30];
  daysInMonths[2089] = [0, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30];
  daysInMonths[2090] = [0, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30];
}

void _initializeStartDayInMonths() {
  startDayInMonths[2000] = [0, 4, 6, 3, 6, 3, 6, 1, 3, 5, 6, 1, 2];
  startDayInMonths[2001] = [0, 5, 1, 4, 1, 4, 7, 3, 5, 6, 1, 2, 4];
  startDayInMonths[2002] = [0, 6, 2, 5, 2, 6, 2, 4, 6, 7, 2, 3, 5];
  startDayInMonths[2003] = [0, 7, 3, 7, 3, 7, 3, 5, 7, 2, 3, 4, 6];
  startDayInMonths[2004] = [0, 2, 4, 1, 4, 1, 4, 6, 1, 3, 4, 6, 7];
  startDayInMonths[2005] = [0, 3, 6, 2, 6, 2, 5, 1, 3, 4, 6, 7, 2];
  startDayInMonths[2006] = [0, 4, 7, 3, 7, 4, 7, 2, 4, 5, 7, 1, 3];
  startDayInMonths[2007] = [0, 5, 1, 5, 1, 5, 1, 3, 5, 7, 1, 2, 4];
  startDayInMonths[2008] = [0, 7, 3, 6, 2, 6, 2, 5, 6, 1, 3, 4, 5];
  startDayInMonths[2009] = [0, 1, 4, 7, 4, 7, 3, 6, 1, 2, 4, 5, 7];
  startDayInMonths[2010] = [0, 2, 5, 1, 5, 2, 5, 7, 2, 3, 5, 6, 1];
  startDayInMonths[2011] = [0, 3, 6, 3, 6, 3, 6, 1, 3, 5, 6, 7, 2];
  startDayInMonths[2012] = [0, 5, 1, 4, 7, 4, 7, 3, 4, 6, 1, 2, 4];
  startDayInMonths[2013] = [0, 6, 2, 5, 2, 5, 1, 4, 6, 7, 2, 3, 5];
  startDayInMonths[2014] = [0, 7, 3, 6, 3, 7, 3, 5, 7, 1, 3, 4, 6];
  startDayInMonths[2015] = [0, 1, 4, 1, 4, 1, 4, 6, 1, 3, 4, 5, 7];
  startDayInMonths[2016] = [0, 3, 6, 2, 5, 2, 5, 1, 2, 4, 6, 7, 2];
  startDayInMonths[2017] = [0, 4, 7, 3, 7, 3, 6, 2, 4, 5, 7, 1, 3];
  startDayInMonths[2018] = [0, 5, 1, 5, 1, 5, 1, 3, 5, 6, 1, 2, 4];
  startDayInMonths[2019] = [0, 6, 2, 6, 2, 6, 2, 4, 6, 1, 2, 4, 5];
  startDayInMonths[2020] = [0, 1, 4, 7, 3, 7, 3, 6, 1, 2, 4, 5, 7];
  startDayInMonths[2021] = [0, 2, 5, 1, 5, 1, 4, 7, 2, 3, 5, 6, 1];
  startDayInMonths[2022] = [0, 3, 6, 3, 6, 3, 6, 1, 3, 5, 6, 7, 2];
  startDayInMonths[2023] = [0, 4, 7, 4, 7, 4, 7, 2, 4, 6, 7, 2, 3];
  startDayInMonths[2024] = [0, 6, 2, 5, 1, 5, 1, 4, 6, 7, 2, 3, 5];
  startDayInMonths[2025] = [0, 7, 3, 6, 3, 6, 2, 5, 7, 1, 3, 4, 6];
  startDayInMonths[2026] = [0, 1, 4, 1, 4, 1, 4, 6, 1, 3, 4, 5, 7];
  startDayInMonths[2027] = [0, 3, 5, 2, 5, 2, 5, 7, 2, 4, 5, 7, 1];
  startDayInMonths[2028] = [0, 4, 7, 3, 7, 3, 6, 2, 4, 5, 7, 1, 3];
  startDayInMonths[2029] = [0, 5, 1, 4, 1, 4, 1, 3, 5, 6, 1, 2, 4];
  startDayInMonths[2030] = [0, 6, 2, 6, 2, 6, 2, 4, 6, 1, 2, 3, 5];
  startDayInMonths[2031] = [0, 1, 3, 7, 3, 7, 3, 5, 7, 2, 3, 5, 6];
  startDayInMonths[2032] = [0, 2, 5, 1, 5, 1, 4, 7, 2, 3, 5, 6, 1];
  startDayInMonths[2033] = [0, 3, 6, 2, 6, 3, 6, 1, 3, 4, 6, 7, 2];
  startDayInMonths[2034] = [0, 4, 7, 4, 7, 4, 7, 2, 4, 6, 7, 1, 3];
  startDayInMonths[2035] = [0, 6, 1, 5, 1, 5, 1, 4, 5, 7, 2, 3, 4];
  startDayInMonths[2036] = [0, 7, 3, 6, 3, 6, 2, 5, 7, 1, 3, 4, 6];
  startDayInMonths[2037] = [0, 1, 4, 7, 4, 1, 4, 6, 1, 2, 4, 5, 7];
  startDayInMonths[2038] = [0, 2, 5, 2, 5, 2, 5, 7, 2, 4, 5, 6, 1];
  startDayInMonths[2039] = [0, 4, 7, 3, 6, 3, 6, 2, 3, 5, 7, 1, 3];
  startDayInMonths[2040] = [0, 5, 1, 4, 1, 4, 7, 3, 5, 6, 1, 2, 4];
  startDayInMonths[2041] = [0, 6, 2, 5, 2, 6, 2, 4, 6, 7, 2, 3, 5];
  startDayInMonths[2042] = [0, 7, 3, 7, 3, 7, 3, 5, 7, 2, 3, 4, 6];
  startDayInMonths[2043] = [0, 2, 5, 1, 4, 1, 4, 7, 1, 3, 5, 6, 1];
  startDayInMonths[2044] = [0, 3, 6, 2, 6, 2, 5, 1, 3, 4, 6, 7, 2];
  startDayInMonths[2045] = [0, 4, 7, 4, 7, 4, 7, 2, 4, 5, 7, 1, 3];
  startDayInMonths[2046] = [0, 5, 1, 5, 1, 5, 1, 3, 5, 7, 1, 2, 4];
  startDayInMonths[2047] = [0, 7, 3, 6, 2, 6, 2, 5, 7, 1, 3, 4, 6];
  startDayInMonths[2048] = [0, 1, 4, 7, 4, 7, 3, 6, 1, 2, 4, 5, 7];
  startDayInMonths[2049] = [0, 2, 5, 2, 5, 2, 5, 7, 2, 4, 5, 6, 1];
  startDayInMonths[2050] = [0, 3, 6, 3, 6, 3, 6, 1, 3, 5, 6, 1, 2];
  startDayInMonths[2051] = [0, 5, 1, 4, 7, 4, 7, 3, 5, 6, 1, 2, 4];
  startDayInMonths[2052] = [0, 6, 2, 5, 2, 5, 1, 4, 6, 7, 2, 3, 5];
  startDayInMonths[2053] = [0, 7, 3, 7, 3, 7, 3, 5, 7, 2, 3, 4, 6];
  startDayInMonths[2054] = [0, 1, 4, 1, 4, 1, 4, 6, 1, 3, 4, 6, 7];
  startDayInMonths[2055] = [0, 3, 6, 2, 6, 2, 5, 1, 3, 4, 6, 7, 2];
  startDayInMonths[2056] = [0, 4, 7, 3, 7, 3, 7, 2, 4, 5, 7, 1, 3];
  startDayInMonths[2057] = [0, 5, 1, 5, 1, 5, 1, 3, 5, 7, 1, 2, 4];
  startDayInMonths[2058] = [0, 7, 2, 6, 2, 6, 2, 4, 6, 1, 2, 4, 5];
  startDayInMonths[2059] = [0, 1, 4, 7, 4, 7, 3, 6, 1, 2, 4, 5, 7];
  startDayInMonths[2060] = [0, 2, 5, 1, 5, 2, 5, 7, 2, 3, 5, 6, 1];
  startDayInMonths[2061] = [0, 3, 6, 3, 6, 3, 6, 1, 3, 5, 6, 7, 2];
  startDayInMonths[2062] = [0, 5, 7, 4, 7, 4, 7, 3, 4, 6, 7, 2, 3];
  startDayInMonths[2063] = [0, 6, 2, 5, 2, 5, 1, 4, 6, 7, 2, 3, 5];
  startDayInMonths[2064] = [0, 7, 3, 6, 3, 7, 3, 5, 7, 1, 3, 4, 6];
  startDayInMonths[2065] = [0, 1, 4, 1, 4, 1, 4, 6, 1, 3, 4, 5, 7];
  startDayInMonths[2066] = [0, 3, 6, 2, 5, 2, 5, 1, 2, 4, 6, 7, 1];
  startDayInMonths[2067] = [0, 4, 7, 3, 7, 3, 6, 2, 4, 5, 7, 1, 3];
  startDayInMonths[2068] = [0, 5, 1, 4, 1, 5, 1, 3, 5, 6, 1, 2, 4];
  startDayInMonths[2069] = [0, 6, 2, 6, 2, 6, 2, 4, 6, 1, 2, 3, 5];
  startDayInMonths[2070] = [0, 1, 4, 7, 3, 7, 3, 6, 7, 2, 4, 5, 7];
  startDayInMonths[2071] = [0, 2, 5, 1, 5, 1, 4, 7, 2, 3, 5, 6, 1];
  startDayInMonths[2072] = [0, 3, 6, 3, 6, 3, 6, 1, 3, 4, 6, 7, 2];
  startDayInMonths[2073] = [0, 4, 7, 4, 7, 4, 7, 2, 4, 6, 7, 1, 3];
  startDayInMonths[2074] = [0, 6, 2, 5, 1, 5, 1, 4, 6, 7, 2, 3, 5];
  startDayInMonths[2075] = [0, 7, 3, 6, 3, 6, 2, 5, 7, 1, 3, 4, 6];
  startDayInMonths[2076] = [0, 1, 4, 1, 4, 1, 4, 6, 1, 3, 4, 5, 7];
  startDayInMonths[2077] = [0, 2, 5, 2, 5, 2, 5, 7, 2, 4, 5, 7, 1];
  startDayInMonths[2078] = [0, 4, 7, 3, 6, 3, 6, 2, 4, 5, 7, 1, 3];
  startDayInMonths[2079] = [0, 5, 1, 4, 1, 4, 7, 3, 5, 6, 1, 2, 4];
  startDayInMonths[2080] = [0, 6, 2, 6, 2, 6, 2, 4, 6, 1, 2, 3, 5];
  startDayInMonths[2081] = [0, 7, 3, 6, 3, 7, 3, 5, 7, 2, 3, 5, 7];
  startDayInMonths[2082] = [0, 2, 4, 1, 4, 1, 4, 6, 1, 3, 4, 6, 1];
  startDayInMonths[2083] = [0, 3, 6, 2, 6, 2, 5, 7, 2, 4, 5, 7, 2];
  startDayInMonths[2084] = [0, 4, 7, 3, 7, 3, 6, 1, 3, 5, 6, 1, 3];
  startDayInMonths[2085] = [0, 5, 1, 5, 1, 5, 7, 3, 5, 7, 1, 3, 5];
  startDayInMonths[2086] = [0, 7, 2, 6, 2, 6, 2, 4, 6, 1, 2, 4, 6];
  startDayInMonths[2087] = [0, 1, 4, 7, 4, 7, 3, 6, 1, 3, 4, 6, 1];
  startDayInMonths[2088] = [0, 3, 5, 1, 5, 2, 4, 7, 2, 4, 5, 7, 2];
  startDayInMonths[2089] = [0, 4, 6, 3, 6, 3, 6, 1, 3, 5, 6, 1, 3];
  startDayInMonths[2090] = [0, 5, 7, 4, 7, 4, 7, 2, 4, 6, 7, 2, 4];
}
