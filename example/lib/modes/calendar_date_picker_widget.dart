import 'package:flutter/material.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

/// Events
final List<Event> _events = [
  Event(date: NepaliDateTime.now(), eventTitles: ['Today 1', 'Today 2']),
  Event(
      date: NepaliDateTime.now().add(Duration(days: 30)),
      eventTitles: ['Holiday 1', 'Holiday 2']),
  Event(
      date: NepaliDateTime.now().subtract(Duration(days: 5)),
      eventTitles: ['Event 1', 'Event 2']),
  Event(
      date: NepaliDateTime.now().add(Duration(days: 8)),
      eventTitles: ['Seminar 1', 'Seminar 2']),
];

/// Calendar Picker Example
class CalendarDatePickerWidget extends StatelessWidget {
  final ValueNotifier<NepaliDateTime> _selectedDate =
      ValueNotifier(NepaliDateTime.now());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CalendarDatePicker(
          initialDate: NepaliDateTime.now(),
          firstDate: NepaliDateTime(2070),
          lastDate: NepaliDateTime(2090),
          onDateChanged: (date) => _selectedDate.value = date as NepaliDateTime,
          calendarDelegate: const NepaliCalendarDelegate(),
          selectableDayPredicate: (date) {
            return _events.any(
              (event) => _dayEquals(event.date, date as NepaliDateTime),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text('Events', style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: ValueListenableBuilder<NepaliDateTime>(
            valueListenable: _selectedDate,
            builder: (context, date, _) {
              Event? event;
              try {
                event = _events.firstWhere((e) => _dayEquals(e.date, date));
              } on StateError {
                event = null;
              }

              if (event == null) {
                return Center(
                  child: Text('No Events'),
                );
              }

              return ListView.separated(
                itemCount: event.eventTitles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: TodayWidget(today: date),
                    title: Text(event!.eventTitles[index]),
                    onTap: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(event!.eventTitles[index]),
                          ),
                        );
                    },
                  );
                },
                separatorBuilder: (context, _) => Divider(height: 1),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _dayEquals(NepaliDateTime? a, NepaliDateTime? b) =>
      a != null &&
      b != null &&
      a.toIso8601String().substring(0, 10) ==
          b.toIso8601String().substring(0, 10);
}

///
class TodayWidget extends StatelessWidget {
  ///
  final NepaliDateTime today;

  ///
  const TodayWidget({required this.today, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  NepaliDateFormat.E().format(today).toUpperCase(),
                  style:
                      theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Text(
              NepaliDateFormat.d().format(today),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

///
class Event {
  ///
  final NepaliDateTime date;

  ///
  final List<String> eventTitles;

  ///
  Event({required this.date, required this.eventTitles});
}
