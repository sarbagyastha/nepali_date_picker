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
  String _text = "Click Here";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nepali Date Picker"),
        centerTitle: true,
      ),
      body: Center(
        child: RaisedButton(
          color: Colors.pink,
          onPressed: () {
            NepaliDatePicker.showPicker(
                context: context,
                startYear: 2052,
                endYear: 2085,
                color: Colors.pink,
                barrierDismissible: false,
                onPicked: (DateTime date) {
                  setState(() {
                    ///Iso8601String Format: 2018-12-23T00:00:00
                    _text = date.toIso8601String().split("T").first;
                  });
                });
          },
          child: Text(
            _text,
            style: TextStyle(color: Colors.white, fontSize: 40.0),
          ),
        ),
      ),
    );
  }
}
