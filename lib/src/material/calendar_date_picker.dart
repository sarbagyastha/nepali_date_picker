// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';

import 'date_picker_common.dart' as common;
import 'date_utils.dart' as utils;

const Duration _monthScrollDuration = Duration(milliseconds: 200);

const double _dayPickerRowHeight = 42.0;
const int _maxDayPickerRowCount = 6; // A 31 day month that starts on Saturday.
// One extra row for the day-of-week header.
const double _maxDayPickerHeight =
    _dayPickerRowHeight * (_maxDayPickerRowCount + 1);
const double _monthPickerHorizontalPadding = 8.0;

const int _yearPickerColumnCount = 3;
const double _yearPickerPadding = 16.0;
const double _yearPickerRowHeight = 52.0;
const double _yearPickerRowSpacing = 8.0;

const double _subHeaderHeight = 52.0;
const double _monthNavButtonsWidth = 108.0;

/// Displays a grid of days for a given month and allows the user to select a date.
///
/// Days are arranged in a rectangular grid with one column for each day of the
/// week. Controls are provided to change the year and month that the grid is
/// showing.
///
/// The calendar picker widget is rarely used directly. Instead, consider using
/// [showMaterialDatePicker], which will create a dialog that uses this as well as provides
/// a text entry option.
class CalendarDatePicker extends StatefulWidget {
  /// Creates a calender date picker
  ///
  /// It will display a grid of days for the [initialDate]'s month. The day
  /// indicated by [initialDate] will be selected.
  ///
  /// The optional [onDisplayedMonthChanged] callback can be used to track
  /// the currently displayed month.
  ///
  /// The user interface provides a way to change the year of the month being
  /// displayed. By default it will show the day grid, but this can be changed
  /// to start in the year selection interface with [initialCalendarMode] set
  /// to [DatePickerMode.year].
  ///
  /// The [initialDate], [firstDate], [lastDate], [onDateChanged], and
  /// [initialCalendarMode] must be non-null.
  ///
  /// [lastDate] must be after or equal to [firstDate].
  ///
  /// [initialDate] must be between [firstDate] and [lastDate] or equal to
  /// one of them.
  ///
  /// [currentDate] represents the current day (i.e. today). This
  /// date will be highlighted in the day grid. If null, the date of
  /// `NepaliDateTime.now()` will be used.
  ///
  /// If [selectableDayPredicate] is non-null, it must return `true` for the
  /// [initialDate].
  CalendarDatePicker({
    Key? key,
    required NepaliDateTime initialDate,
    required NepaliDateTime firstDate,
    required NepaliDateTime lastDate,
    NepaliDateTime? currentDate,
    required this.onDateChanged,
    this.onDisplayedMonthChanged,
    this.initialCalendarMode = DatePickerMode.day,
    this.selectableDayPredicate,
    this.selectedDayDecoration,
    this.todayDecoration,
    this.dayBuilder,
  })  : initialDate = utils.dateOnly(initialDate),
        firstDate = utils.dateOnly(firstDate),
        lastDate = utils.dateOnly(lastDate),
        currentDate = utils.dateOnly(currentDate ?? NepaliDateTime.now()),
        super(key: key) {
    assert(
      !this.lastDate.isBefore(this.firstDate),
      'lastDate ${this.lastDate} must be on or after firstDate ${this.firstDate}.',
    );
    assert(
      !this.initialDate.isBefore(this.firstDate),
      'initialDate ${this.initialDate} must be on or after firstDate ${this.firstDate}.',
    );
    assert(
      !this.initialDate.isAfter(this.lastDate),
      'initialDate ${this.initialDate} must be on or before lastDate ${this.lastDate}.',
    );
    assert(
      selectableDayPredicate == null ||
          selectableDayPredicate!(this.initialDate),
      'Provided initialDate ${this.initialDate} must satisfy provided selectableDayPredicate.',
    );
  }

  /// The initially selected [NepaliDateTime] that the picker should display.
  final NepaliDateTime initialDate;

  /// The earliest allowable [NepaliDateTime] that the user can select.
  final NepaliDateTime firstDate;

  /// The latest allowable [NepaliDateTime] that the user can select.
  final NepaliDateTime lastDate;

  /// The [NepaliDateTime] representing today. It will be highlighted in the day grid.
  final NepaliDateTime currentDate;

  /// Called when the user selects a date in the picker.
  final ValueChanged<NepaliDateTime> onDateChanged;

  /// Called when the user navigates to a new month/year in the picker.
  final ValueChanged<NepaliDateTime>? onDisplayedMonthChanged;

  /// The initial display of the calendar picker.
  final DatePickerMode initialCalendarMode;

  /// Builds the widget for particular day.
  final Widget Function(NepaliDateTime)? dayBuilder;

  /// Decoration for today's cell.
  final BoxDecoration? todayDecoration;

  /// Decoration for selected day's cell.
  final BoxDecoration? selectedDayDecoration;

  /// Function to provide full control over which dates in the calendar can be selected.
  final common.SelectableDayPredicate? selectableDayPredicate;

  @override
  _CalendarDatePickerState createState() => _CalendarDatePickerState();
}

class _CalendarDatePickerState extends State<CalendarDatePicker> {
  bool _announcedInitialDate = false;
  late DatePickerMode _mode;
  late NepaliDateTime _currentDisplayedMonthDate;
  late NepaliDateTime _selectedDate;
  final GlobalKey _monthPickerKey = GlobalKey();
  final GlobalKey _yearPickerKey = GlobalKey();
  late TextDirection _textDirection;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialCalendarMode;
    _currentDisplayedMonthDate = NepaliDateTime(
      widget.initialDate.year,
      widget.initialDate.month,
    );
    _selectedDate = widget.initialDate;
  }

  @override
  void didUpdateWidget(CalendarDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCalendarMode != oldWidget.initialCalendarMode) {
      _mode = widget.initialCalendarMode;
    }
    if (!DateUtils.isSameDay(widget.initialDate, oldWidget.initialDate)) {
      _currentDisplayedMonthDate = NepaliDateTime(
        widget.initialDate.year,
        widget.initialDate.month,
      );
      _selectedDate = widget.initialDate;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasDirectionality(context));
    _textDirection = Directionality.of(context);
    if (!_announcedInitialDate) {
      _announcedInitialDate = true;
      SemanticsService.announce(
        NepaliDateFormat.yMMMMEEEEd().format(_selectedDate),
        _textDirection,
      );
    }
  }

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        HapticFeedback.vibrate();
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
  }

  void _handleModeChanged(DatePickerMode mode) {
    _vibrate();
    setState(() {
      _mode = mode;
      if (_mode == DatePickerMode.day) {
        SemanticsService.announce(
          NepaliDateFormat.yMMMM().format(_selectedDate),
          _textDirection,
        );
      } else {
        SemanticsService.announce(
          NepaliDateFormat.y().format(_selectedDate),
          _textDirection,
        );
      }
    });
  }

  void _handleMonthChanged(NepaliDateTime date) {
    setState(() {
      if (_currentDisplayedMonthDate.year != date.year ||
          _currentDisplayedMonthDate.month != date.month) {
        _currentDisplayedMonthDate = NepaliDateTime(date.year, date.month);
        widget.onDisplayedMonthChanged?.call(_currentDisplayedMonthDate);
      }
    });
  }

  void _handleYearChanged(NepaliDateTime value) {
    _vibrate();

    if (value.isBefore(widget.firstDate)) {
      value = widget.firstDate;
    } else if (value.isAfter(widget.lastDate)) {
      value = widget.lastDate;
    }

    setState(() {
      _mode = DatePickerMode.day;
      _handleMonthChanged(value);
    });
  }

  void _handleDayChanged(NepaliDateTime value) {
    _vibrate();
    setState(() {
      _selectedDate = value;
      widget.onDateChanged(_selectedDate);
    });
  }

  Widget _buildPicker() {
    switch (_mode) {
      case DatePickerMode.day:
        return _MonthPicker(
          key: _monthPickerKey,
          initialMonth: _currentDisplayedMonthDate,
          currentDate: widget.currentDate,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          selectedDate: _selectedDate,
          onChanged: _handleDayChanged,
          onDisplayedMonthChanged: _handleMonthChanged,
          selectableDayPredicate: widget.selectableDayPredicate,
          todayDecoration: widget.todayDecoration,
          selectedDayDecoration: widget.selectedDayDecoration,
          dayBuilder: widget.dayBuilder,
        );
      case DatePickerMode.year:
        return Padding(
          padding: const EdgeInsets.only(top: _subHeaderHeight),
          child: _YearPicker(
            key: _yearPickerKey,
            currentDate: widget.currentDate,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            initialDate: _currentDisplayedMonthDate,
            selectedDate: _selectedDate,
            onChanged: _handleYearChanged,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(
          height: _subHeaderHeight + _maxDayPickerHeight,
          child: _buildPicker(),
        ),
        _DatePickerModeToggleButton(
          mode: _mode,
          title: NepaliDateFormat.yMMMM().format(_currentDisplayedMonthDate),
          onTitlePressed: () {
            // Toggle the day/year mode.
            _handleModeChanged(
              _mode == DatePickerMode.day
                  ? DatePickerMode.year
                  : DatePickerMode.day,
            );
          },
        ),
      ],
    );
  }
}

/// A button that used to toggle the [DatePickerMode] for a date picker.
///
/// This appears above the calendar grid and allows the user to toggle the
/// [DatePickerMode] to display either the calendar view or the year list.
class _DatePickerModeToggleButton extends StatefulWidget {
  const _DatePickerModeToggleButton({
    required this.mode,
    required this.title,
    required this.onTitlePressed,
  });

  /// The current display of the calendar picker.
  final DatePickerMode mode;

  /// The text that displays the current month/year being viewed.
  final String title;

  /// The callback when the title is pressed.
  final VoidCallback onTitlePressed;

  @override
  _DatePickerModeToggleButtonState createState() =>
      _DatePickerModeToggleButtonState();
}

class _DatePickerModeToggleButtonState
    extends State<_DatePickerModeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: widget.mode == DatePickerMode.year ? 0.5 : 0,
      upperBound: 0.5,
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_DatePickerModeToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode == widget.mode) {
      return;
    }

    if (widget.mode == DatePickerMode.year) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final controlColor = colorScheme.onSurface.withOpacity(0.60);

    return Container(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
      height: _subHeaderHeight,
      child: Row(
        children: <Widget>[
          Flexible(
            child: Semantics(
              label: 'Select year',
              excludeSemantics: true,
              button: true,
              child: Container(
                height: _subHeaderHeight,
                child: InkWell(
                  onTap: widget.onTitlePressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            widget.title,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(
                              color: controlColor,
                            ),
                          ),
                        ),
                        RotationTransition(
                          turns: _controller,
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: controlColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.mode == DatePickerMode.day)
            // Give space for the prev/next month buttons that are underneath this row
            const SizedBox(width: _monthNavButtonsWidth),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _MonthPicker extends StatefulWidget {
  /// Creates a month picker.
  _MonthPicker({
    Key? key,
    required this.initialMonth,
    required this.currentDate,
    required this.firstDate,
    required this.lastDate,
    required this.selectedDate,
    required this.onChanged,
    required this.onDisplayedMonthChanged,
    this.selectedDayDecoration,
    this.todayDecoration,
    this.dayBuilder,
    this.selectableDayPredicate,
  })  : assert(!firstDate.isAfter(lastDate)),
        assert(!selectedDate.isBefore(firstDate)),
        assert(!selectedDate.isAfter(lastDate)),
        super(key: key);

  /// The initial month to display
  final NepaliDateTime initialMonth;

  /// The current date.
  ///
  /// This date is subtly highlighted in the picker.
  final NepaliDateTime currentDate;

  /// The earliest date the user is permitted to pick.
  ///
  /// This date must be on or before the [lastDate].
  final NepaliDateTime firstDate;

  /// The latest date the user is permitted to pick.
  ///
  /// This date must be on or after the [firstDate].
  final NepaliDateTime lastDate;

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final NepaliDateTime selectedDate;

  /// Called when the user picks a day.
  final ValueChanged<NepaliDateTime> onChanged;

  /// Called when the user navigates to a new month
  final ValueChanged<NepaliDateTime> onDisplayedMonthChanged;

  /// Builds the widget for particular day.
  final Widget Function(NepaliDateTime)? dayBuilder;

  /// Decoration for today's cell.
  final BoxDecoration? todayDecoration;

  /// Decoration for selected day's cell.
  final BoxDecoration? selectedDayDecoration;

  /// Optional user supplied predicate function to customize selectable days.
  final common.SelectableDayPredicate? selectableDayPredicate;

  @override
  State<StatefulWidget> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<_MonthPicker> {
  final GlobalKey _pageViewKey = GlobalKey();
  late NepaliDateTime _currentMonth;
  late NepaliDateTime _nextMonthDate;
  late NepaliDateTime _previousMonthDate;
  late PageController _pageController;
  late TextDirection _textDirection;
  Map<LogicalKeySet, Intent>? _shortcutMap;
  Map<Type, Action<Intent>>? _actionMap;
  late FocusNode _dayGridFocus;
  NepaliDateTime? _focusedDay;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialMonth;
    _previousMonthDate = utils.addMonthsToMonthDate(_currentMonth, -1);
    _nextMonthDate = utils.addMonthsToMonthDate(_currentMonth, 1);
    _pageController = PageController(
        initialPage: utils.monthDelta(widget.firstDate, _currentMonth));
    _shortcutMap = <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.arrowLeft):
          const DirectionalFocusIntent(TraversalDirection.left),
      LogicalKeySet(LogicalKeyboardKey.arrowRight):
          const DirectionalFocusIntent(TraversalDirection.right),
      LogicalKeySet(LogicalKeyboardKey.arrowDown):
          const DirectionalFocusIntent(TraversalDirection.down),
      LogicalKeySet(LogicalKeyboardKey.arrowUp):
          const DirectionalFocusIntent(TraversalDirection.up),
    };
    _actionMap = <Type, Action<Intent>>{
      NextFocusIntent:
          CallbackAction<NextFocusIntent>(onInvoke: _handleGridNextFocus),
      PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
          onInvoke: _handleGridPreviousFocus),
      DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
          onInvoke: _handleDirectionFocus),
    };
    _dayGridFocus = FocusNode(debugLabel: 'Day Grid');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textDirection = Directionality.of(context);
  }

  @override
  void didUpdateWidget(_MonthPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMonth != oldWidget.initialMonth) {
      // We can't interrupt this widget build with a scroll, so do it next frame
      WidgetsBinding.instance.addPostFrameCallback(
        (Duration timeStamp) => _showMonth(widget.initialMonth, jump: true),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dayGridFocus.dispose();
    super.dispose();
  }

  void _handleDateSelected(NepaliDateTime selectedDate) {
    _focusedDay = selectedDate;
    widget.onChanged(selectedDate);
  }

  void _handleMonthPageChanged(int monthPage) {
    setState(() {
      final monthDate = utils.addMonthsToMonthDate(widget.firstDate, monthPage);
      if (!utils.isSameMonth(_currentMonth, monthDate)) {
        _currentMonth = NepaliDateTime(monthDate.year, monthDate.month);
        _previousMonthDate = utils.addMonthsToMonthDate(_currentMonth, -1);
        _nextMonthDate = utils.addMonthsToMonthDate(_currentMonth, 1);
        widget.onDisplayedMonthChanged(_currentMonth);
        if (_focusedDay != null &&
            !utils.isSameMonth(_focusedDay!, _currentMonth)) {
          // We have navigated to a new month with the grid focused, but the
          // focused day is not in this month. Choose a new one trying to keep
          // the same day of the month.
          _focusedDay = _focusableDayForMonth(_currentMonth, _focusedDay!.day);
        }
      }
    });
  }

  /// Returns a focusable date for the given month.
  ///
  /// If the preferredDay is available in the month it will be returned,
  /// otherwise the first selectable day in the month will be returned. If
  /// no dates are selectable in the month, then it will return null.
  NepaliDateTime? _focusableDayForMonth(
      NepaliDateTime month, int preferredDay) {
    final daysInMonth = utils.getDaysInMonth(month.year, month.month);

    // Can we use the preferred day in this month?
    if (preferredDay <= daysInMonth) {
      final newFocus = NepaliDateTime(month.year, month.month, preferredDay);
      if (_isSelectable(newFocus)) return newFocus;
    }

    // Start at the 1st and take the first selectable date.
    for (var day = 1; day <= daysInMonth; day++) {
      final newFocus = NepaliDateTime(month.year, month.month, day);
      if (_isSelectable(newFocus)) return newFocus;
    }
    return null;
  }

  /// Navigate to the next month.
  void _handleNextMonth() {
    if (!_isDisplayingLastMonth) {
      SemanticsService.announce(
        NepaliDateFormat.yMMMM().format(_nextMonthDate),
        _textDirection,
      );
      _pageController.nextPage(
        duration: _monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  /// Navigate to the previous month.
  void _handlePreviousMonth() {
    if (!_isDisplayingFirstMonth) {
      SemanticsService.announce(
        NepaliDateFormat.yMMMM().format(_previousMonthDate),
        _textDirection,
      );
      _pageController.previousPage(
        duration: _monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  /// Navigate to the given month.
  void _showMonth(NepaliDateTime month, {bool jump = false}) {
    final monthPage = utils.monthDelta(widget.firstDate, month);
    if (jump) {
      _pageController.jumpToPage(monthPage);
    } else {
      _pageController.animateToPage(
        monthPage,
        duration: _monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  /// True if the earliest allowable month is displayed.
  bool get _isDisplayingFirstMonth {
    return !_currentMonth.isAfter(
      NepaliDateTime(widget.firstDate.year, widget.firstDate.month),
    );
  }

  /// True if the latest allowable month is displayed.
  bool get _isDisplayingLastMonth {
    return !_currentMonth.isBefore(
      NepaliDateTime(widget.lastDate.year, widget.lastDate.month),
    );
  }

  /// Handler for when the overall day grid obtains or loses focus.
  void _handleGridFocusChange(bool focused) {
    setState(() {
      if (focused && _focusedDay == null) {
        if (utils.isSameMonth(widget.selectedDate, _currentMonth)) {
          _focusedDay = widget.selectedDate;
        } else if (utils.isSameMonth(widget.currentDate, _currentMonth)) {
          _focusedDay =
              _focusableDayForMonth(_currentMonth, widget.currentDate.day);
        } else {
          _focusedDay = _focusableDayForMonth(_currentMonth, 1);
        }
      }
    });
  }

  /// Move focus to the next element after the day grid.
  void _handleGridNextFocus(NextFocusIntent intent) {
    _dayGridFocus.requestFocus();
    _dayGridFocus.nextFocus();
  }

  /// Move focus to the previous element before the day grid.
  void _handleGridPreviousFocus(PreviousFocusIntent intent) {
    _dayGridFocus.requestFocus();
    _dayGridFocus.previousFocus();
  }

  /// Move the internal focus date in the direction of the given intent.
  ///
  /// This will attempt to move the focused day to the next selectable day in
  /// the given direction. If the new date is not in the current month, then
  /// the page view will be scrolled to show the new date's month.
  ///
  /// For horizontal directions, it will move forward or backward a day (depending
  /// on the current [TextDirection]). For vertical directions it will move up and
  /// down a week at a time.
  void _handleDirectionFocus(DirectionalFocusIntent intent) {
    assert(_focusedDay != null);
    setState(() {
      final nextDate = _nextDateInDirection(_focusedDay!, intent.direction);
      if (nextDate != null) {
        _focusedDay = nextDate;
        if (!utils.isSameMonth(_focusedDay!, _currentMonth)) {
          _showMonth(_focusedDay!);
        }
      }
    });
  }

  static const Map<TraversalDirection, Duration> _directionOffset =
      <TraversalDirection, Duration>{
    TraversalDirection.up: Duration(days: -DateTime.daysPerWeek),
    TraversalDirection.right: Duration(days: 1),
    TraversalDirection.down: Duration(days: DateTime.daysPerWeek),
    TraversalDirection.left: Duration(days: -1),
  };

  Duration _dayDirectionOffset(
      TraversalDirection traversalDirection, TextDirection textDirection) {
    // Swap left and right if the text direction if RTL
    if (textDirection == TextDirection.rtl) {
      if (traversalDirection == TraversalDirection.left) {
        traversalDirection = TraversalDirection.right;
      } else if (traversalDirection == TraversalDirection.right) {
        traversalDirection = TraversalDirection.left;
      }
    }
    return _directionOffset[traversalDirection]!;
  }

  NepaliDateTime? _nextDateInDirection(
      NepaliDateTime date, TraversalDirection direction) {
    final textDirection = Directionality.of(context);
    var nextDate = date.add(_dayDirectionOffset(direction, textDirection));
    while (!nextDate.isBefore(widget.firstDate) &&
        !nextDate.isAfter(widget.lastDate)) {
      if (_isSelectable(nextDate)) {
        return nextDate;
      }
      nextDate = nextDate.add(_dayDirectionOffset(direction, textDirection));
    }
    return null;
  }

  bool _isSelectable(NepaliDateTime date) {
    return widget.selectableDayPredicate == null ||
        widget.selectableDayPredicate!.call(date);
  }

  Widget _buildItems(BuildContext context, int index) {
    final month = utils.addMonthsToMonthDate(widget.firstDate, index);
    return _DayPicker(
      key: ValueKey<NepaliDateTime>(month),
      selectedDate: widget.selectedDate,
      currentDate: widget.currentDate,
      onChanged: _handleDateSelected,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: month,
      selectableDayPredicate: widget.selectableDayPredicate,
      dayBuilder: widget.dayBuilder,
      selectedDayDecoration: widget.selectedDayDecoration,
      todayDecoration: widget.todayDecoration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final previousTooltipText =
        '${NepaliUtils().language == Language.english ? 'Previous Month' : 'अघिल्लो महिना'} ${NepaliDateFormat.yMMMM().format(_previousMonthDate)}';
    final nextTooltipText =
        '${NepaliUtils().language == Language.english ? 'Next Month' : 'अर्को महिना'} ${NepaliDateFormat.yMMMM().format(_nextMonthDate)}';
    final controlColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(0.60);

    return Semantics(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
            height: _subHeaderHeight,
            child: Row(
              children: <Widget>[
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: controlColor,
                  tooltip: _isDisplayingFirstMonth ? null : previousTooltipText,
                  onPressed:
                      _isDisplayingFirstMonth ? null : _handlePreviousMonth,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: controlColor,
                  tooltip: _isDisplayingLastMonth ? null : nextTooltipText,
                  onPressed: _isDisplayingLastMonth ? null : _handleNextMonth,
                ),
              ],
            ),
          ),
          Expanded(
            child: FocusableActionDetector(
              shortcuts: _shortcutMap,
              actions: _actionMap,
              focusNode: _dayGridFocus,
              onFocusChange: _handleGridFocusChange,
              child: _FocusedDate(
                date: _dayGridFocus.hasFocus ? _focusedDay : null,
                child: Container(
                  color: _dayGridFocus.hasFocus
                      ? Theme.of(context).focusColor
                      : null,
                  child: PageView.builder(
                    key: _pageViewKey,
                    controller: _pageController,
                    itemBuilder: _buildItems,
                    itemCount:
                        utils.monthDelta(widget.firstDate, widget.lastDate) + 1,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: _handleMonthPageChanged,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// InheritedWidget indicating what the current focused date is for its children.
///
/// This is used by the [_MonthPicker] to let its children [_DayPicker]s know
/// what the currently focused date (if any) should be.
class _FocusedDate extends InheritedWidget {
  const _FocusedDate({Key? key, required Widget child, this.date})
      : super(key: key, child: child);

  final NepaliDateTime? date;

  @override
  bool updateShouldNotify(_FocusedDate oldWidget) {
    return !DateUtils.isSameDay(date, oldWidget.date);
  }

  static NepaliDateTime? of(BuildContext context) {
    final focusedDate =
        context.dependOnInheritedWidgetOfExactType<_FocusedDate>();
    return focusedDate?.date;
  }
}

/// Displays the days of a given month and allows choosing a day.
///
/// The days are arranged in a rectangular grid with one column for each day of
/// the week.
class _DayPicker extends StatefulWidget {
  /// Creates a day picker.
  _DayPicker({
    Key? key,
    required this.currentDate,
    required this.displayedMonth,
    required this.firstDate,
    required this.lastDate,
    required this.selectedDate,
    required this.onChanged,
    this.todayDecoration,
    this.selectedDayDecoration,
    this.dayBuilder,
    this.selectableDayPredicate,
  })  : assert(!firstDate.isAfter(lastDate)),
        assert(!selectedDate.isBefore(firstDate)),
        assert(!selectedDate.isAfter(lastDate)),
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
  ///
  /// This date must be on or before the [lastDate].
  final NepaliDateTime firstDate;

  /// The latest date the user is permitted to pick.
  ///
  /// This date must be on or after the [firstDate].
  final NepaliDateTime lastDate;

  /// The month whose days are displayed by this picker.
  final NepaliDateTime displayedMonth;

  /// Builds the widget for particular day.
  final Widget Function(NepaliDateTime)? dayBuilder;

  /// Decoration for today's cell.
  final BoxDecoration? todayDecoration;

  /// Decoration for selected day's cell.
  final BoxDecoration? selectedDayDecoration;

  /// Optional user supplied predicate function to customize selectable days.
  final common.SelectableDayPredicate? selectableDayPredicate;

  @override
  _DayPickerState createState() => _DayPickerState();
}

class _DayPickerState extends State<_DayPicker> {
  /// List of [FocusNode]s, one for each day of the month.
  late List<FocusNode> _dayFocusNodes;

  @override
  void initState() {
    super.initState();
    final daysInMonth = utils.getDaysInMonth(
        widget.displayedMonth.year, widget.displayedMonth.month);
    _dayFocusNodes = List<FocusNode>.generate(
      daysInMonth,
      (index) => FocusNode(skipTraversal: true, debugLabel: 'Day ${index + 1}'),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check to see if the focused date is in this month, if so focus it.
    final focusedDate = _FocusedDate.of(context);
    if (focusedDate != null &&
        utils.isSameMonth(widget.displayedMonth, focusedDate)) {
      _dayFocusNodes[focusedDate.day - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (final node in _dayFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Builds widgets showing abbreviated days of week. The first widget in the
  /// returned list corresponds to the first day of week for the current locale.
  List<Widget> _dayHeaders(TextStyle? headerStyle) {
    return (NepaliUtils().language == Language.english
            ? ['S', 'M', 'T', 'W', 'T', 'F', 'S']
            : ['आ', 'सो', 'मं', 'बु', 'वि', 'शु', 'श'])
        .map<Widget>(
          (label) => ExcludeSemantics(
            child: Center(
              child: Text(label, style: headerStyle),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final headerStyle = textTheme.bodySmall?.apply(
      color: colorScheme.onSurface.withOpacity(0.60),
    );
    final dayStyle = textTheme.bodySmall;
    final enabledDayColor = colorScheme.onSurface.withOpacity(0.87);
    final disabledDayColor = colorScheme.onSurface.withOpacity(0.38);
    final selectedDayColor = colorScheme.onPrimary;
    final selectedDayBackground = colorScheme.primary;
    final todayColor = colorScheme.primary;

    final year = widget.displayedMonth.year;
    final month = widget.displayedMonth.month;

    final daysInMonth = utils.getDaysInMonth(year, month);
    final dayOffset = utils.firstDayOffset(year, month);

    final dayItems = _dayHeaders(headerStyle);
    var day = -dayOffset;
    while (day < daysInMonth) {
      day++;
      if (day < 1) {
        dayItems.add(Container());
      } else {
        final dayToBuild = NepaliDateTime(year, month, day);
        final isDisabled = dayToBuild.isAfter(widget.lastDate) ||
            dayToBuild.isBefore(widget.firstDate) ||
            (widget.selectableDayPredicate != null &&
                !widget.selectableDayPredicate!(dayToBuild));
        final isSelectedDay = utils.isSameDay(widget.selectedDate, dayToBuild);
        final isToday = utils.isSameDay(widget.currentDate, dayToBuild);

        BoxDecoration? decoration;
        var dayColor = enabledDayColor;
        if (isSelectedDay) {
          // The selected day gets a circle background highlight, and a
          // contrasting text color.
          dayColor = selectedDayColor;
          decoration = widget.selectedDayDecoration ??
              BoxDecoration(
                color: selectedDayBackground,
                shape: BoxShape.circle,
              );
        } else if (isDisabled) {
          dayColor = disabledDayColor;
        } else if (isToday) {
          // The current day gets a different text color and a circle stroke
          // border.
          dayColor = todayColor;
          decoration = widget.todayDecoration ??
              BoxDecoration(
                border: Border.all(color: todayColor, width: 1),
                shape: BoxShape.circle,
              );
        }

        Widget dayWidget = Container(
          decoration: decoration,
          child: widget.dayBuilder == null
              ? Center(
                  child: Text(
                    NepaliNumberFormat().format(day),
                    style: dayStyle?.apply(color: dayColor),
                  ),
                )
              : widget.dayBuilder!(dayToBuild),
        );

        if (isDisabled) {
          dayWidget = ExcludeSemantics(
            child: dayWidget,
          );
        } else {
          dayWidget = InkResponse(
            focusNode: _dayFocusNodes[day - 1],
            onTap: () => widget.onChanged(dayToBuild),
            radius: _dayPickerRowHeight / 2 + 4,
            splashColor: selectedDayBackground.withOpacity(0.38),
            child: Semantics(
              // We want the day of month to be spoken first irrespective of the
              // locale-specific preferences or TextDirection. This is because
              // an accessibility user is more likely to be interested in the
              // day of month before the rest of the date, as they are looking
              // for the day of month. To do that we prepend day of month to the
              // formatted full date.
              label:
                  '${NepaliNumberFormat().format(day)}, ${NepaliDateFormat.yMMMMEEEEd().format(dayToBuild)}',
              selected: isSelectedDay,
              excludeSemantics: true,
              child: dayWidget,
            ),
          );
        }

        dayItems.add(dayWidget);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _monthPickerHorizontalPadding,
      ),
      child: GridView.custom(
        physics: const ClampingScrollPhysics(),
        gridDelegate: _dayPickerGridDelegate,
        childrenDelegate: SliverChildListDelegate(
          dayItems,
          addRepaintBoundaries: false,
        ),
      ),
    );
  }
}

class _DayPickerGridDelegate extends SliverGridDelegate {
  const _DayPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const columnCount = DateTime.daysPerWeek;
    final tileWidth = constraints.crossAxisExtent / columnCount;
    final tileHeight = math.min(_dayPickerRowHeight,
        constraints.viewportMainAxisExtent / (_maxDayPickerRowCount + 1));
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: tileHeight,
      crossAxisCount: columnCount,
      crossAxisStride: tileWidth,
      mainAxisStride: tileHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_DayPickerGridDelegate oldDelegate) => false;
}

const _DayPickerGridDelegate _dayPickerGridDelegate = _DayPickerGridDelegate();

/// A scrollable list of years to allow picking a year.
class _YearPicker extends StatefulWidget {
  /// Creates a year picker.
  ///
  /// The [currentDate, [firstDate], [lastDate], [selectedDate], and [onChanged]
  /// arguments must be non-null. The [lastDate] must be after the [firstDate].
  _YearPicker({
    Key? key,
    required this.currentDate,
    required this.firstDate,
    required this.lastDate,
    required this.initialDate,
    required this.selectedDate,
    required this.onChanged,
  })  : assert(!firstDate.isAfter(lastDate)),
        super(key: key);

  /// The current date.
  ///
  /// This date is subtly highlighted in the picker.
  final NepaliDateTime currentDate;

  /// The earliest date the user is permitted to pick.
  final NepaliDateTime firstDate;

  /// The latest date the user is permitted to pick.
  final NepaliDateTime lastDate;

  /// The initial date to center the year display around.
  final NepaliDateTime initialDate;

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final NepaliDateTime selectedDate;

  /// Called when the user picks a year.
  final ValueChanged<NepaliDateTime> onChanged;

  @override
  _YearPickerState createState() => _YearPickerState();
}

class _YearPickerState extends State<_YearPicker> {
  late ScrollController scrollController;

  // The approximate number of years necessary to fill the available space.
  static const int minYears = 18;

  @override
  void initState() {
    super.initState();

    // Set the scroll position to approximately center the initial year.
    final initialYearIndex = widget.selectedDate.year - widget.firstDate.year;
    final initialYearRow = initialYearIndex ~/ _yearPickerColumnCount;
    // Move the offset down by 2 rows to approximately center it.
    final centeredYearRow = initialYearRow - 2;
    final scrollOffset =
        _itemCount < minYears ? 0.0 : centeredYearRow * _yearPickerRowHeight;
    scrollController = ScrollController(initialScrollOffset: scrollOffset);
  }

  Widget _buildYearItem(BuildContext context, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Backfill the _YearPicker with disabled years if necessary.
    final offset = _itemCount < minYears ? (minYears - _itemCount) ~/ 2 : 0;
    final year = widget.firstDate.year + index - offset;
    final isSelected = year == widget.selectedDate.year;
    final isCurrentYear = year == widget.currentDate.year;
    final isDisabled =
        year < widget.firstDate.year || year > widget.lastDate.year;
    const decorationHeight = 36.0;
    const decorationWidth = 72.0;

    Color textColor;
    if (isSelected) {
      textColor = colorScheme.onPrimary;
    } else if (isDisabled) {
      textColor = colorScheme.onSurface.withOpacity(0.38);
    } else if (isCurrentYear) {
      textColor = colorScheme.primary;
    } else {
      textColor = colorScheme.onSurface.withOpacity(0.87);
    }
    final itemStyle = textTheme.bodyLarge?.apply(color: textColor);

    BoxDecoration? decoration;
    if (isSelected) {
      decoration = BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(decorationHeight / 2),
        shape: BoxShape.rectangle,
      );
    } else if (isCurrentYear && !isDisabled) {
      decoration = BoxDecoration(
        border: Border.all(
          color: colorScheme.primary,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(decorationHeight / 2),
        shape: BoxShape.rectangle,
      );
    }

    Widget yearItem = Center(
      child: Container(
        decoration: decoration,
        height: decorationHeight,
        width: decorationWidth,
        child: Center(
          child: Semantics(
            selected: isSelected,
            child: Text(
              NepaliUtils().language == Language.english
                  ? year.toString()
                  : NepaliUnicode.convert(year.toString()),
              style: itemStyle,
            ),
          ),
        ),
      ),
    );

    if (isDisabled) {
      yearItem = ExcludeSemantics(
        child: yearItem,
      );
    } else {
      yearItem = InkWell(
        key: ValueKey<int>(year),
        onTap: () {
          widget.onChanged(
            NepaliDateTime(
              year,
              widget.initialDate.month,
              widget.initialDate.day,
            ),
          );
        },
        child: yearItem,
      );
    }

    return yearItem;
  }

  int get _itemCount {
    return widget.lastDate.year - widget.firstDate.year + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Divider(),
        Expanded(
          child: GridView.builder(
            controller: scrollController,
            gridDelegate: _yearPickerGridDelegate,
            itemBuilder: _buildYearItem,
            itemCount: math.max(_itemCount, minYears),
            padding: const EdgeInsets.symmetric(horizontal: _yearPickerPadding),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class _YearPickerGridDelegate extends SliverGridDelegate {
  const _YearPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final tileWidth = (constraints.crossAxisExtent -
            (_yearPickerColumnCount - 1) * _yearPickerRowSpacing) /
        _yearPickerColumnCount;
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: _yearPickerRowHeight,
      crossAxisCount: _yearPickerColumnCount,
      crossAxisStride: tileWidth + _yearPickerRowSpacing,
      mainAxisStride: _yearPickerRowHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_YearPickerGridDelegate oldDelegate) => false;
}

const _YearPickerGridDelegate _yearPickerGridDelegate =
    _YearPickerGridDelegate();
