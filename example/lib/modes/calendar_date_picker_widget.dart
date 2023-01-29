import 'package:flutter/material.dart' hide CalendarDatePicker;
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';

/// Calendar Picker Example
class CalendarDatePickerWidget extends StatelessWidget {
  final ValueNotifier<NepaliDateTime> _selectedDate =
      ValueNotifier(NepaliDateTime.now());

  /// Events
  final List<Event> events = [
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CalendarDatePicker(
          initialDate: NepaliDateTime.now(),
          firstDate: NepaliDateTime(2070),
          lastDate: NepaliDateTime(2090),
          onDateChanged: (date) => _selectedDate.value = date,
          dayBuilder: (dayToBuild) {
            return Stack(
              children: <Widget>[
                Center(
                  child: Text(
                    NepaliUtils().language == Language.english
                        ? '${dayToBuild.day}'
                        : NepaliUnicode.convert('${dayToBuild.day}'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                if (events.any((event) => _dayEquals(event.date, dayToBuild)))
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.purple),
                    ),
                  )
              ],
            );
          },
          selectedDayDecoration: BoxDecoration(
            color: Colors.deepOrange,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.yellow, Colors.orange]),
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<NepaliDateTime>(
            valueListenable: _selectedDate,
            builder: (context, date, _) {
              Event? event;
              try {
                event = events.firstWhere((e) => _dayEquals(e.date, date));
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
                itemBuilder: (context, index) => ListTile(
                  leading: TodayWidget(
                    today: date,
                  ),
                  title: Text(event!.eventTitles[index]),
                  onTap: () {},
                ),
                separatorBuilder: (context, _) => Divider(),
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
  const TodayWidget({
    Key? key,
    required this.today,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: 60,
        height: 60,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  NepaliDateFormat.EEEE()
                      .format(today)
                      .substring(0, 3)
                      .toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Spacer(),
            Text(
              NepaliDateFormat.d().format(today),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            Spacer(),
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
