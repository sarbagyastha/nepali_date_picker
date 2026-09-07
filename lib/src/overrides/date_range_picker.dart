// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Signature for predicating enabled dates in date range pickers.
///
/// The [selectedStartDay] and [selectedEndDay] are the currently selected start
/// and end dates of a date range, which conditionally enables or disables each
/// date in the picker based on the user selection. (Example: in a hostel's room
/// selection, you are not able to select the end date after the next
/// non-selectable day).
///
/// See [showDateRangePicker], which has a [SelectableDayForRangePredicate]
/// parameter used to specify allowable days in the date range picker.
typedef SelectableDayForRangePredicate =
    bool Function(
      DateTime day,
      DateTime? selectedStartDay,
      DateTime? selectedEndDay,
    );

const Duration _monthScrollDuration = Duration(milliseconds: 200);

const double _monthItemHeaderHeight = 58.0;
const double _monthItemFooterHeight = 12.0;
const double _monthItemRowHeight = 42.0;
const double _monthItemSpaceBetweenRows = 8.0;
const double _horizontalPadding = 8.0;
const double _maxCalendarWidthLandscape = 384.0;
const double _maxCalendarWidthPortrait = 480.0;

/// Displays a scrollable calendar grid that allows a user to select a range
/// of dates.
class CalendarDateRangePicker extends StatefulWidget {
  /// Creates a scrollable calendar grid for picking date ranges.
  CalendarDateRangePicker({
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required this.selectableDayPredicate,
    DateTime? currentDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.calendarDelegate,
    super.key,
  }) : initialStartDate = initialStartDate != null
           ? calendarDelegate.dateOnly(initialStartDate)
           : null,
       initialEndDate = initialEndDate != null
           ? calendarDelegate.dateOnly(initialEndDate)
           : null,
       firstDate = calendarDelegate.dateOnly(firstDate),
       lastDate = calendarDelegate.dateOnly(lastDate),
       currentDate = calendarDelegate.dateOnly(
         currentDate ?? calendarDelegate.now(),
       ) {
    assert(
      this.initialStartDate == null ||
          this.initialEndDate == null ||
          !this.initialStartDate!.isAfter(initialEndDate!),
      'initialStartDate must be on or before initialEndDate.',
    );
    assert(
      !this.lastDate.isBefore(this.firstDate),
      'firstDate must be on or before lastDate.',
    );
  }

  /// The [DateTime] that represents the start of the initial date range selection.
  final DateTime? initialStartDate;

  /// The [DateTime] that represents the end of the initial date range selection.
  final DateTime? initialEndDate;

  /// The earliest allowable [DateTime] that the user can select.
  final DateTime firstDate;

  /// The latest allowable [DateTime] that the user can select.
  final DateTime lastDate;

  /// Function to provide full control over which [DateTime] can be selected.
  final SelectableDayForRangePredicate? selectableDayPredicate;

  /// The [DateTime] representing today. It will be highlighted in the day grid.
  final DateTime currentDate;

  /// Called when the user changes the start date of the selected range.
  final ValueChanged<DateTime>? onStartDateChanged;

  /// Called when the user changes the end date of the selected range.
  final ValueChanged<DateTime?>? onEndDateChanged;

  /// {@macro flutter.material.calendar_date_picker.calendarDelegate}
  final CalendarDelegate<DateTime> calendarDelegate;

  @override
  State<CalendarDateRangePicker> createState() =>
      _CalendarDateRangePickerState();
}

class _CalendarDateRangePickerState extends State<CalendarDateRangePicker> {
  final GlobalKey _scrollViewKey = GlobalKey();
  DateTime? _startDate;
  DateTime? _endDate;
  int _initialMonthIndex = 0;
  late ScrollController _controller;
  late bool _showWeekBottomDivider;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);

    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;

    // Calculate the index for the initially displayed month. This is needed to
    // divide the list of months into two `SliverList`s.
    final DateTime initialDate = widget.initialStartDate ?? widget.currentDate;
    if (!initialDate.isBefore(widget.firstDate) &&
        !initialDate.isAfter(widget.lastDate)) {
      _initialMonthIndex = widget.calendarDelegate.monthDelta(
        widget.firstDate,
        initialDate,
      );
    }

    _showWeekBottomDivider = _initialMonthIndex != 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_controller.offset <= _controller.position.minScrollExtent) {
      setState(() {
        _showWeekBottomDivider = false;
      });
    } else if (!_showWeekBottomDivider) {
      setState(() {
        _showWeekBottomDivider = true;
      });
    }
  }

  int get _numberOfMonths =>
      widget.calendarDelegate.monthDelta(widget.firstDate, widget.lastDate) + 1;

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        HapticFeedback.vibrate();
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        break;
    }
  }

  // This updates the selected date range using this logic:
  //
  // * From the unselected state, selecting one date creates the start date.
  //   * If the next selection is before the start date, reset date range and
  //     set the start date to that selection.
  //   * If the next selection is on or after the start date, set the end date
  //     to that selection.
  // * After both start and end dates are selected, any subsequent selection
  //   resets the date range and sets start date to that selection.
  void _updateSelection(DateTime date) {
    _vibrate();
    setState(() {
      if (_startDate != null &&
          _endDate == null &&
          !date.isBefore(_startDate!)) {
        _endDate = date;
        widget.onEndDateChanged?.call(_endDate);
      } else {
        _startDate = date;
        widget.onStartDateChanged?.call(_startDate!);
        if (_endDate != null) {
          _endDate = null;
          widget.onEndDateChanged?.call(_endDate);
        }
      }
    });
  }

  Widget _buildMonthItem(
    BuildContext context,
    int index,
    bool beforeInitialMonth,
  ) {
    final int monthIndex = beforeInitialMonth
        ? _initialMonthIndex - index - 1
        : _initialMonthIndex + index;
    final DateTime month = widget.calendarDelegate.addMonthsToMonthDate(
      widget.firstDate,
      monthIndex,
    );
    return _MonthItem(
      calendarDelegate: widget.calendarDelegate,
      selectedDateStart: _startDate,
      selectedDateEnd: _endDate,
      currentDate: widget.currentDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: month,
      onChanged: _updateSelection,
      selectableDayPredicate: widget.selectableDayPredicate,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Key sliverAfterKey = Key('sliverAfterKey');

    return Column(
      children: <Widget>[
        const _DayHeaders(),
        if (_showWeekBottomDivider) const Divider(height: 0),
        Expanded(
          child: _CalendarKeyboardNavigator(
            calendarDelegate: widget.calendarDelegate,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            initialFocusedDay:
                _startDate ?? widget.initialStartDate ?? widget.currentDate,
            // In order to prevent performance issues when displaying the
            // correct initial month, 2 `SliverList`s are used to split the
            // months. The first item in the second SliverList is the initial
            // month to be displayed.
            child: CustomScrollView(
              key: _scrollViewKey,
              controller: _controller,
              center: sliverAfterKey,
              slivers: <Widget>[
                SliverList.builder(
                  itemCount: _initialMonthIndex,
                  itemBuilder: (BuildContext context, int index) =>
                      _buildMonthItem(context, index, true),
                ),
                SliverList.builder(
                  key: sliverAfterKey,
                  itemCount: _numberOfMonths - _initialMonthIndex,
                  itemBuilder: (BuildContext context, int index) =>
                      _buildMonthItem(context, index, false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CalendarKeyboardNavigator extends StatefulWidget {
  const _CalendarKeyboardNavigator({
    required this.child,
    required this.firstDate,
    required this.lastDate,
    required this.initialFocusedDay,
    required this.calendarDelegate,
  });

  final Widget child;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime initialFocusedDay;
  final CalendarDelegate<DateTime> calendarDelegate;

  @override
  _CalendarKeyboardNavigatorState createState() =>
      _CalendarKeyboardNavigatorState();
}

class _CalendarKeyboardNavigatorState
    extends State<_CalendarKeyboardNavigator> {
  final Map<ShortcutActivator, Intent> _shortcutMap =
      const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowLeft): DirectionalFocusIntent(
          TraversalDirection.left,
        ),
        SingleActivator(LogicalKeyboardKey.arrowRight): DirectionalFocusIntent(
          TraversalDirection.right,
        ),
        SingleActivator(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(
          TraversalDirection.down,
        ),
        SingleActivator(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(
          TraversalDirection.up,
        ),
      };
  late Map<Type, Action<Intent>> _actionMap;
  late FocusNode _dayGridFocus;
  TraversalDirection? _dayTraversalDirection;
  DateTime? _focusedDay;

  @override
  void initState() {
    super.initState();

    _actionMap = <Type, Action<Intent>>{
      NextFocusIntent: CallbackAction<NextFocusIntent>(
        onInvoke: _handleGridNextFocus,
      ),
      PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
        onInvoke: _handleGridPreviousFocus,
      ),
      DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
        onInvoke: _handleDirectionFocus,
      ),
    };
    _dayGridFocus = FocusNode(debugLabel: 'Day Grid');
  }

  @override
  void dispose() {
    _dayGridFocus.dispose();
    super.dispose();
  }

  void _handleGridFocusChange(bool focused) {
    setState(() {
      if (focused) {
        _focusedDay ??= widget.initialFocusedDay;
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
      final DateTime? nextDate = _nextDateInDirection(
        _focusedDay!,
        intent.direction,
      );
      if (nextDate != null) {
        _focusedDay = nextDate;
        _dayTraversalDirection = intent.direction;
      }
    });
  }

  static const Map<TraversalDirection, int> _directionOffset =
      <TraversalDirection, int>{
        TraversalDirection.up: -DateTime.daysPerWeek,
        TraversalDirection.right: 1,
        TraversalDirection.down: DateTime.daysPerWeek,
        TraversalDirection.left: -1,
      };

  int _dayDirectionOffset(
    TraversalDirection traversalDirection,
    TextDirection textDirection,
  ) {
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

  DateTime? _nextDateInDirection(DateTime date, TraversalDirection direction) {
    final TextDirection textDirection = Directionality.of(context);
    final DateTime nextDate = widget.calendarDelegate.addDaysToDate(
      date,
      _dayDirectionOffset(direction, textDirection),
    );
    if (!nextDate.isBefore(widget.firstDate) &&
        !nextDate.isAfter(widget.lastDate)) {
      return nextDate;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      shortcuts: _shortcutMap,
      actions: _actionMap,
      focusNode: _dayGridFocus,
      onFocusChange: _handleGridFocusChange,
      child: _FocusedDate(
        calendarDelegate: widget.calendarDelegate,
        date: _dayGridFocus.hasFocus ? _focusedDay : null,
        scrollDirection: _dayGridFocus.hasFocus ? _dayTraversalDirection : null,
        child: widget.child,
      ),
    );
  }
}

/// InheritedWidget indicating what the current focused date is for its children.
// See also: _FocusedDate in calendar_date_picker.dart
class _FocusedDate extends InheritedWidget {
  const _FocusedDate({
    required super.child,
    required this.calendarDelegate,
    this.date,
    this.scrollDirection,
  });

  final CalendarDelegate<DateTime> calendarDelegate;
  final DateTime? date;
  final TraversalDirection? scrollDirection;

  @override
  bool updateShouldNotify(_FocusedDate oldWidget) {
    return !calendarDelegate.isSameDay(date, oldWidget.date) ||
        scrollDirection != oldWidget.scrollDirection;
  }

  static _FocusedDate? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FocusedDate>();
  }
}

/// Displays the days of a given month and allows choosing a date range.
///
/// The days are arranged in a rectangular grid with one column for each day of
/// the week.
class _MonthItem extends StatefulWidget {
  /// Creates a month item.
  _MonthItem({
    required this.selectedDateStart,
    required this.selectedDateEnd,
    required this.currentDate,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    required this.displayedMonth,
    required this.selectableDayPredicate,
    required this.calendarDelegate,
  }) : assert(!firstDate.isAfter(lastDate)),
       assert(
         selectedDateStart == null || !selectedDateStart.isBefore(firstDate),
       ),
       assert(selectedDateEnd == null || !selectedDateEnd.isBefore(firstDate)),
       assert(
         selectedDateStart == null || !selectedDateStart.isAfter(lastDate),
       ),
       assert(selectedDateEnd == null || !selectedDateEnd.isAfter(lastDate)),
       assert(
         selectedDateStart == null ||
             selectedDateEnd == null ||
             !selectedDateStart.isAfter(selectedDateEnd),
       );

  /// The currently selected start date.
  ///
  /// This date is highlighted in the picker.
  final DateTime? selectedDateStart;

  /// The currently selected end date.
  ///
  /// This date is highlighted in the picker.
  final DateTime? selectedDateEnd;

  /// The current date at the time the picker is displayed.
  final DateTime currentDate;

  /// Called when the user picks a day.
  final ValueChanged<DateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// The month whose days are displayed by this picker.
  final DateTime displayedMonth;

  final SelectableDayForRangePredicate? selectableDayPredicate;

  /// {@macro flutter.material.calendar_date_picker.calendarDelegate}
  final CalendarDelegate<DateTime> calendarDelegate;

  @override
  _MonthItemState createState() => _MonthItemState();
}

class _MonthItemState extends State<_MonthItem> {
  /// List of [FocusNode]s, one for each day of the month.
  late List<FocusNode> _dayFocusNodes;

  @override
  void initState() {
    super.initState();
    final int daysInMonth = widget.calendarDelegate.getDaysInMonth(
      widget.displayedMonth.year,
      widget.displayedMonth.month,
    );
    _dayFocusNodes = List<FocusNode>.generate(
      daysInMonth,
      (int index) =>
          FocusNode(skipTraversal: true, debugLabel: 'Day ${index + 1}'),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check to see if the focused date is in this month, if so focus it.
    final DateTime? focusedDate = _FocusedDate.maybeOf(context)?.date;
    if (focusedDate != null &&
        widget.calendarDelegate.isSameMonth(
          widget.displayedMonth,
          focusedDate,
        )) {
      _dayFocusNodes[focusedDate.day - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (final FocusNode node in _dayFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Color _highlightColor(BuildContext context) {
    return DatePickerTheme.of(context).rangeSelectionBackgroundColor ??
        DatePickerTheme.defaults(context).rangeSelectionBackgroundColor!;
  }

  void _dayFocusChanged(bool focused) {
    if (focused) {
      final TraversalDirection? focusDirection = _FocusedDate.maybeOf(
        context,
      )?.scrollDirection;
      if (focusDirection != null) {
        ScrollPositionAlignmentPolicy policy =
            ScrollPositionAlignmentPolicy.explicit;
        switch (focusDirection) {
          case TraversalDirection.up:
          case TraversalDirection.left:
            policy = ScrollPositionAlignmentPolicy.keepVisibleAtStart;
          case TraversalDirection.right:
          case TraversalDirection.down:
            policy = ScrollPositionAlignmentPolicy.keepVisibleAtEnd;
        }
        Scrollable.ensureVisible(
          primaryFocus!.context!,
          duration: _monthScrollDuration,
          alignmentPolicy: policy,
        );
      }
    }
  }

  Widget _buildDayItem(
    BuildContext context,
    DateTime dayToBuild,
    int firstDayOffset,
    int daysInMonth,
  ) {
    final int day = dayToBuild.day;

    final bool isDisabled =
        dayToBuild.isAfter(widget.lastDate) ||
        dayToBuild.isBefore(widget.firstDate) ||
        widget.selectableDayPredicate != null &&
            !widget.selectableDayPredicate!(
              dayToBuild,
              widget.selectedDateStart,
              widget.selectedDateEnd,
            );
    final bool isRangeSelected =
        widget.selectedDateStart != null && widget.selectedDateEnd != null;
    final bool isSelectedDayStart =
        widget.selectedDateStart != null &&
        dayToBuild.isAtSameMomentAs(widget.selectedDateStart!);
    final bool isSelectedDayEnd =
        widget.selectedDateEnd != null &&
        dayToBuild.isAtSameMomentAs(widget.selectedDateEnd!);
    final bool isInRange =
        isRangeSelected &&
        dayToBuild.isAfter(widget.selectedDateStart!) &&
        dayToBuild.isBefore(widget.selectedDateEnd!);
    final bool isOneDayRange =
        isRangeSelected && widget.selectedDateStart == widget.selectedDateEnd;
    final bool isToday = widget.calendarDelegate.isSameDay(
      widget.currentDate,
      dayToBuild,
    );

    return _DayItem(
      calendarDelegate: widget.calendarDelegate,
      day: dayToBuild,
      focusNode: _dayFocusNodes[day - 1],
      onChanged: widget.onChanged,
      onFocusChange: _dayFocusChanged,
      highlightColor: _highlightColor(context),
      isDisabled: isDisabled,
      isRangeSelected: isRangeSelected,
      isSelectedDayStart: isSelectedDayStart,
      isSelectedDayEnd: isSelectedDayEnd,
      isInRange: isInRange,
      isOneDayRange: isOneDayRange,
      isToday: isToday,
    );
  }

  Widget _buildEdgeBox(BuildContext context, bool isHighlighted) {
    const Widget empty = LimitedBox(
      maxWidth: 0.0,
      maxHeight: 0.0,
      child: SizedBox.expand(),
    );
    return isHighlighted
        ? ColoredBox(color: _highlightColor(context), child: empty)
        : empty;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final int year = widget.displayedMonth.year;
    final int month = widget.displayedMonth.month;
    final int daysInMonth = widget.calendarDelegate.getDaysInMonth(year, month);
    final int dayOffset = widget.calendarDelegate.firstDayOffset(
      year,
      month,
      localizations,
    );
    final int weeks = ((daysInMonth + dayOffset) / DateTime.daysPerWeek).ceil();
    final double gridHeight =
        weeks * _monthItemRowHeight + (weeks - 1) * _monthItemSpaceBetweenRows;
    final List<Widget> dayItems = <Widget>[];

    // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
    // a leap year.
    for (int day = 0 - dayOffset + 1; day <= daysInMonth; day += 1) {
      if (day < 1) {
        dayItems.add(
          const LimitedBox(
            maxWidth: 0.0,
            maxHeight: 0.0,
            child: SizedBox.expand(),
          ),
        );
      } else {
        final DateTime dayToBuild = widget.calendarDelegate.getDay(
          year,
          month,
          day,
        );
        final Widget dayItem = _buildDayItem(
          context,
          dayToBuild,
          dayOffset,
          daysInMonth,
        );
        dayItems.add(dayItem);
      }
    }

    // Add the leading/trailing edge containers to each week in order to
    // correctly extend the range highlight.
    final List<Widget> paddedDayItems = <Widget>[];
    for (int i = 0; i < weeks; i++) {
      final int start = i * DateTime.daysPerWeek;
      final int end = math.min(start + DateTime.daysPerWeek, dayItems.length);
      final List<Widget> weekList = dayItems.sublist(start, end);

      final DateTime dateAfterLeadingPadding = widget.calendarDelegate.getDay(
        year,
        month,
        start - dayOffset + 1,
      );
      // Only color the edge container if it is after the start date and
      // on/before the end date.
      final bool isLeadingInRange =
          !(dayOffset > 0 && i == 0) &&
          widget.selectedDateStart != null &&
          widget.selectedDateEnd != null &&
          dateAfterLeadingPadding.isAfter(widget.selectedDateStart!) &&
          !dateAfterLeadingPadding.isAfter(widget.selectedDateEnd!);
      weekList.insert(0, _buildEdgeBox(context, isLeadingInRange));

      // Only add a trailing edge container if it is for a full week and not a
      // partial week.
      if (end < dayItems.length ||
          (end == dayItems.length &&
              dayItems.length % DateTime.daysPerWeek == 0)) {
        final DateTime dateBeforeTrailingPadding = widget.calendarDelegate
            .getDay(year, month, end - dayOffset);
        // Only color the edge container if it is on/after the start date and
        // before the end date.
        final bool isTrailingInRange =
            widget.selectedDateStart != null &&
            widget.selectedDateEnd != null &&
            !dateBeforeTrailingPadding.isBefore(widget.selectedDateStart!) &&
            dateBeforeTrailingPadding.isBefore(widget.selectedDateEnd!);
        weekList.add(_buildEdgeBox(context, isTrailingInRange));
      }

      paddedDayItems.addAll(weekList);
    }

    final double maxWidth =
        MediaQuery.orientationOf(context) == Orientation.landscape
        ? _maxCalendarWidthLandscape
        : _maxCalendarWidthPortrait;
    return Column(
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ).tighten(height: _monthItemHeaderHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: ExcludeSemantics(
                child: Text(
                  widget.calendarDelegate.formatMonthYear(
                    widget.displayedMonth,
                    localizations,
                  ),
                  style: textTheme.bodyMedium!.apply(
                    color: themeData.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: gridHeight,
          ),
          child: GridView.custom(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: _monthItemGridDelegate,
            childrenDelegate: SliverChildListDelegate(
              paddedDayItems,
              addRepaintBoundaries: false,
            ),
          ),
        ),
        const SizedBox(height: _monthItemFooterHeight),
      ],
    );
  }
}

class _DayItem extends StatefulWidget {
  const _DayItem({
    required this.day,
    required this.focusNode,
    required this.onChanged,
    required this.onFocusChange,
    required this.highlightColor,
    required this.isDisabled,
    required this.isRangeSelected,
    required this.isSelectedDayStart,
    required this.isSelectedDayEnd,
    required this.isInRange,
    required this.isOneDayRange,
    required this.isToday,
    required this.calendarDelegate,
  });

  final DateTime day;

  final FocusNode focusNode;

  final ValueChanged<DateTime> onChanged;

  final ValueChanged<bool> onFocusChange;

  final Color highlightColor;

  final bool isDisabled;

  final bool isRangeSelected;

  final bool isSelectedDayStart;

  final bool isSelectedDayEnd;

  final bool isInRange;

  final bool isOneDayRange;

  final bool isToday;

  final CalendarDelegate<DateTime> calendarDelegate;

  @override
  State<_DayItem> createState() => _DayItemState();
}

class _DayItemState extends State<_DayItem> {
  final WidgetStatesController _statesController = WidgetStatesController();

  @override
  void dispose() {
    _statesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final DatePickerThemeData datePickerTheme = DatePickerTheme.of(context);
    final DatePickerThemeData defaults = DatePickerTheme.defaults(context);
    final TextDirection textDirection = Directionality.of(context);
    final Color highlightColor = widget.highlightColor;

    ShapeDecoration? decoration;
    TextStyle? itemStyle = textTheme.bodyMedium;

    T? effectiveValue<T>(T? Function(DatePickerThemeData? theme) getProperty) {
      return getProperty(datePickerTheme) ?? getProperty(defaults);
    }

    T? resolve<T>(
      WidgetStateProperty<T>? Function(DatePickerThemeData? theme) getProperty,
      Set<WidgetState> states,
    ) {
      return effectiveValue((DatePickerThemeData? theme) {
        return getProperty(theme)?.resolve(states);
      });
    }

    final Set<WidgetState> states = <WidgetState>{
      if (widget.isDisabled) WidgetState.disabled,
      if (widget.isSelectedDayStart || widget.isSelectedDayEnd)
        WidgetState.selected,
    };

    final OutlinedBorder dayShape =
        resolve<OutlinedBorder?>(
          (DatePickerThemeData? theme) => theme?.dayShape,
          states,
        ) ??
        const CircleBorder();

    _statesController.value = states;

    final Color? dayForegroundColor = resolve<Color?>(
      (DatePickerThemeData? theme) => theme?.dayForegroundColor,
      states,
    );
    final Color? dayBackgroundColor = resolve<Color?>(
      (DatePickerThemeData? theme) => theme?.dayBackgroundColor,
      states,
    );
    final WidgetStateProperty<Color?> dayOverlayColor =
        WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) => effectiveValue(
            (DatePickerThemeData? theme) => widget.isInRange
                ? theme?.rangeSelectionOverlayColor?.resolve(states)
                : theme?.dayOverlayColor?.resolve(states),
          ),
        );

    _HighlightPainter? highlightPainter;

    if (widget.isSelectedDayStart || widget.isSelectedDayEnd) {
      // The selected start and end dates get a custom shaped background
      // highlight, and a contrasting text color.
      itemStyle = itemStyle?.apply(color: dayForegroundColor);
      decoration = ShapeDecoration(color: dayBackgroundColor, shape: dayShape);

      if (widget.isRangeSelected && !widget.isOneDayRange) {
        final _HighlightPainterStyle style = widget.isSelectedDayStart
            ? _HighlightPainterStyle.highlightTrailing
            : _HighlightPainterStyle.highlightLeading;
        highlightPainter = _HighlightPainter(
          color: highlightColor,
          style: style,
          textDirection: textDirection,
        );
      }
    } else if (widget.isInRange) {
      // The days within the range get a light background highlight.
      highlightPainter = _HighlightPainter(
        color: highlightColor,
        style: _HighlightPainterStyle.highlightAll,
        textDirection: textDirection,
      );
      if (widget.isDisabled) {
        itemStyle = itemStyle?.apply(
          color: colorScheme.onSurface.withValues(alpha: 0.38),
        );
      }
    } else if (widget.isDisabled) {
      itemStyle = itemStyle?.apply(
        color: colorScheme.onSurface.withValues(alpha: 0.38),
      );
    } else if (widget.isToday) {
      // The current day gets a different text color and a custom shape
      // border.
      itemStyle = itemStyle?.apply(color: colorScheme.primary);
      final BorderSide todaySide =
          (datePickerTheme.todayBorder ?? defaults.todayBorder!).copyWith(
            color: colorScheme.primary,
          );
      decoration = ShapeDecoration(shape: dayShape.copyWith(side: todaySide));
    }

    final String dayText = localizations.formatDecimal(widget.day.day);

    // We want the day of month to be spoken first irrespective of the
    // locale-specific preferences or TextDirection. This is because
    // an accessibility user is more likely to be interested in the
    // day of month before the rest of the date, as they are looking
    // for the day of month. To do that we prepend day of month to the
    // formatted full date.
    final String semanticLabelSuffix = widget.isToday
        ? ', ${localizations.currentDateLabel}'
        : '';
    String semanticLabel =
        '$dayText, ${widget.calendarDelegate.formatFullDate(widget.day, localizations)}$semanticLabelSuffix';
    if (widget.isSelectedDayStart) {
      semanticLabel = localizations.dateRangeStartDateSemanticLabel(
        semanticLabel,
      );
    } else if (widget.isSelectedDayEnd) {
      semanticLabel = localizations.dateRangeEndDateSemanticLabel(
        semanticLabel,
      );
    }

    Widget dayWidget = Container(
      decoration: decoration,
      alignment: Alignment.center,
      child: Semantics(
        label: semanticLabel,
        selected: widget.isSelectedDayStart || widget.isSelectedDayEnd,
        child: ExcludeSemantics(child: Text(dayText, style: itemStyle)),
      ),
    );

    if (highlightPainter != null) {
      dayWidget = CustomPaint(painter: highlightPainter, child: dayWidget);
    }

    if (!widget.isDisabled) {
      dayWidget = InkResponse(
        focusNode: widget.focusNode,
        onTap: () => widget.onChanged(widget.day),
        customBorder: dayShape,
        containedInkWell: true,
        statesController: _statesController,
        overlayColor: dayOverlayColor,
        onFocusChange: widget.onFocusChange,
        child: dayWidget,
      );
    }

    return dayWidget;
  }
}

/// Determines which style to use to paint the highlight.
enum _HighlightPainterStyle {
  /// Paints nothing.
  none,

  /// Paints a rectangle that occupies the leading half of the space.
  highlightLeading,

  /// Paints a rectangle that occupies the trailing half of the space.
  highlightTrailing,

  /// Paints a rectangle that occupies all available space.
  highlightAll,
}

/// This custom painter will add a background highlight to its child.
///
/// This highlight will be drawn depending on the [style], [color], and
/// [textDirection] supplied. It will either paint a rectangle on the
/// left/right, a full rectangle, or nothing at all. This logic is determined by
/// a combination of the [style] and [textDirection].
class _HighlightPainter extends CustomPainter {
  _HighlightPainter({
    required this.color,
    this.style = _HighlightPainterStyle.none,
    this.textDirection,
  });

  final Color color;
  final _HighlightPainterStyle style;
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    if (style == _HighlightPainterStyle.none) {
      return;
    }

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final bool rtl = switch (textDirection) {
      TextDirection.rtl || null => true,
      TextDirection.ltr => false,
    };

    switch (style) {
      case _HighlightPainterStyle.highlightLeading when rtl:
      case _HighlightPainterStyle.highlightTrailing when !rtl:
        canvas.drawRect(
          Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height),
          paint,
        );
      case _HighlightPainterStyle.highlightLeading:
      case _HighlightPainterStyle.highlightTrailing:
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width / 2, size.height),
          paint,
        );
      case _HighlightPainterStyle.highlightAll:
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      case _HighlightPainterStyle.none:
        break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _MonthItemGridDelegate extends SliverGridDelegate {
  const _MonthItemGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double tileWidth =
        (constraints.crossAxisExtent - 2 * _horizontalPadding) /
        DateTime.daysPerWeek;
    return _MonthSliverGridLayout(
      crossAxisCount: DateTime.daysPerWeek + 2,
      dayChildWidth: tileWidth,
      edgeChildWidth: _horizontalPadding,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_MonthItemGridDelegate oldDelegate) => false;
}

const _MonthItemGridDelegate _monthItemGridDelegate = _MonthItemGridDelegate();

class _MonthSliverGridLayout extends SliverGridLayout {
  /// Creates a layout that uses equally sized and spaced tiles for each day of
  /// the week and an additional edge tile for padding at the start and end of
  /// each row.
  ///
  /// This is necessary to facilitate the painting of the range highlight
  /// correctly.
  const _MonthSliverGridLayout({
    required this.crossAxisCount,
    required this.dayChildWidth,
    required this.edgeChildWidth,
    required this.reverseCrossAxis,
  }) : assert(crossAxisCount > 0),
       assert(dayChildWidth >= 0),
       assert(edgeChildWidth >= 0);

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The width in logical pixels of the day child widgets.
  final double dayChildWidth;

  /// The width in logical pixels of the edge child widgets.
  final double edgeChildWidth;

  /// Whether the children should be placed in the opposite order of increasing
  /// coordinates in the cross axis.
  ///
  /// For example, if the cross axis is horizontal, the children are placed from
  /// left to right when [reverseCrossAxis] is false and from right to left when
  /// [reverseCrossAxis] is true.
  ///
  /// Typically set to the return value of [axisDirectionIsReversed] applied to
  /// the [SliverConstraints.crossAxisDirection].
  final bool reverseCrossAxis;

  /// The number of logical pixels from the leading edge of one row to the
  /// leading edge of the next row.
  double get _rowHeight {
    return _monthItemRowHeight + _monthItemSpaceBetweenRows;
  }

  /// The height in logical pixels of the children widgets.
  double get _childHeight {
    return _monthItemRowHeight;
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    return crossAxisCount * (scrollOffset ~/ _rowHeight);
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    final int mainAxisCount = (scrollOffset / _rowHeight).ceil();
    return math.max(0, crossAxisCount * mainAxisCount - 1);
  }

  double _getCrossAxisOffset(double crossAxisStart, bool isPadding) {
    if (reverseCrossAxis) {
      return ((crossAxisCount - 2) * dayChildWidth + 2 * edgeChildWidth) -
          crossAxisStart -
          (isPadding ? edgeChildWidth : dayChildWidth);
    }
    return crossAxisStart;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final int adjustedIndex = index % crossAxisCount;
    final bool isEdge =
        adjustedIndex == 0 || adjustedIndex == crossAxisCount - 1;
    final double crossAxisStart = math.max(
      0,
      (adjustedIndex - 1) * dayChildWidth + edgeChildWidth,
    );

    return SliverGridGeometry(
      scrollOffset: (index ~/ crossAxisCount) * _rowHeight,
      crossAxisOffset: _getCrossAxisOffset(crossAxisStart, isEdge),
      mainAxisExtent: _childHeight,
      crossAxisExtent: isEdge ? edgeChildWidth : dayChildWidth,
    );
  }

  @override
  double computeMaxScrollOffset(int childCount) {
    assert(childCount >= 0);
    final int mainAxisCount = ((childCount - 1) ~/ crossAxisCount) + 1;
    final double mainAxisSpacing = _rowHeight - _childHeight;
    return _rowHeight * mainAxisCount - mainAxisSpacing;
  }
}

class _DayHeaders extends StatelessWidget {
  const _DayHeaders();

  /// Builds widgets showing abbreviated days of week. The first widget in the
  /// returned list corresponds to the first day of week for the current locale.
  ///
  /// Examples:
  ///
  ///     ┌ Sunday is the first day of week in the US (en_US)
  ///     |
  ///     S M T W T F S  ← the returned list contains these widgets
  ///     _ _ _ _ _ 1 2
  ///     3 4 5 6 7 8 9
  ///
  ///     ┌ But it's Monday in the UK (en_GB)
  ///     |
  ///     M T W T F S S  ← the returned list contains these widgets
  ///     _ _ _ _ 1 2 3
  ///     4 5 6 7 8 9 10
  ///
  List<Widget> _getDayHeaders(
    TextStyle headerStyle,
    MaterialLocalizations localizations,
  ) {
    final result = <Widget>[];
    for (
      var i = localizations.firstDayOfWeekIndex;
      result.length < DateTime.daysPerWeek;
      i = (i + 1) % DateTime.daysPerWeek
    ) {
      final weekday = localizations.narrowWeekdays[i];
      result.add(
        ExcludeSemantics(
          child: Center(child: Text(weekday, style: headerStyle)),
        ),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final TextStyle textStyle = themeData.textTheme.titleSmall!.apply(
      color: colorScheme.onSurface,
    );
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final List<Widget> labels = _getDayHeaders(textStyle, localizations);

    // Add leading and trailing boxes for edges of the custom grid layout.
    labels.insert(0, const SizedBox.shrink());
    labels.add(const SizedBox.shrink());

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.orientationOf(context) == Orientation.landscape
            ? _maxCalendarWidthLandscape
            : _maxCalendarWidthPortrait,
        maxHeight: _monthItemRowHeight,
      ),
      child: GridView.custom(
        shrinkWrap: true,
        gridDelegate: _monthItemGridDelegate,
        childrenDelegate: SliverChildListDelegate(
          labels,
          addRepaintBoundaries: false,
        ),
      ),
    );
  }
}
