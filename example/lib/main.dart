import 'package:flutter/material.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      title: "Nepali Date Picker",
      home: NepaliDatePickerExample(),
    );
  }
}

class NepaliDatePickerExample extends StatefulWidget {
  @override
  _NepaliDatePickerExampleState createState() =>
      _NepaliDatePickerExampleState();
}

class _NepaliDatePickerExampleState extends State<NepaliDatePickerExample> {
  NepaliDateTime _selectedDateTime = NepaliDateTime.now();
  Language _language = Language.ENGLISH;
  String _design = 'm';
  DateOrder _dateOrder = DateOrder.mdy;
  bool _showTimerPicker = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nepali Date Picker"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              if (_selectedDateTime != null)
                Text(
                  'Selected Date: ${NepaliDateFormat("EEE, MMMM d, y hh:mm aa", language: _language).format(_selectedDateTime)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 18.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.0),
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  color: Colors.pink,
                  onPressed: () async {
                    if (_design == 'm') {
                      _selectedDateTime = await showMaterialDatePicker(
                        context: context,
                        initialDate: _selectedDateTime ?? NepaliDateTime.now(),
                        firstDate: NepaliDateTime(2000),
                        lastDate: NepaliDateTime(2099, 12),
                        language: _language,
                        initialDatePickerMode: DatePickerMode.day,
                      );
                      if (_showTimerPicker) {
                        var timeOfDay = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            _selectedDateTime?.toDateTime(),
                          ),
                        );
                        _selectedDateTime = _selectedDateTime.mergeTime(
                          timeOfDay.hour,
                          timeOfDay.minute,
                          0,
                        );
                      }
                      setState(() {});
                    } else {
                      showCupertinoDatePicker(
                        context: context,
                        initialDate: _selectedDateTime ?? NepaliDateTime.now(),
                        firstDate: NepaliDateTime(2000),
                        lastDate: NepaliDateTime(2099, 12),
                        language: _language,
                        dateOrder: _dateOrder,
                        onDateChanged: (newDate) {
                          setState(() {
                            _selectedDateTime = newDate;
                          });
                        },
                      );
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'SELECT DATE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(width: 10.0),
                  Text(
                    'Language: ',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  _radio<Language>('English', Language.ENGLISH, _language,
                      (value) => setState(() => _language = value)),
                  _radio<Language>('Nepali', Language.NEPALI, _language,
                      (value) => setState(() => _language = value)),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(width: 10.0),
                  Text(
                    'Design: ',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  _radio<String>('Material', 'm', _design,
                      (value) => setState(() => _design = value)),
                  _radio<String>('Cupertino', 'c', _design,
                      (value) => setState(() => _design = value)),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 15.0),
                      Text(
                        'Order: ',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      Text(
                        '(only for Cupertino)',
                        style: TextStyle(fontSize: 8.0),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _radio<DateOrder>('D M Y', DateOrder.dmy, _dateOrder,
                            (value) => setState(() => _dateOrder = value)),
                        _radio<DateOrder>('M D Y', DateOrder.mdy, _dateOrder,
                            (value) => setState(() => _dateOrder = value)),
                        _radio<DateOrder>('Y D M', DateOrder.ydm, _dateOrder,
                            (value) => setState(() => _dateOrder = value)),
                        _radio<DateOrder>('Y M D', DateOrder.ymd, _dateOrder,
                            (value) => setState(() => _dateOrder = value)),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 15.0),
                      Text(
                        'Show Time Picker: ',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      Text(
                        '(only for Material)',
                        style: TextStyle(fontSize: 8.0),
                      ),
                    ],
                  ),
                  Switch(
                    value: _showTimerPicker,
                    onChanged: (v) => setState(() => _showTimerPicker = v),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _radio<T>(
    String title,
    T value,
    T groupValue,
    ValueChanged<T> onChanged,
  ) {
    return Flexible(
      child: RadioListTile<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        title: Text(title),
      ),
    );
  }
}
