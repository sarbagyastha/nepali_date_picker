import 'package:flutter/material.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';

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
  NepaliDateTime _selectedDateTime;
  Language _language = Language.ENGLISH;

  @override
  Widget build(BuildContext context) {
    print(NepaliDateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: Text("Nepali Date Picker"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (_selectedDateTime != null)
              Text(
                'Selected Date: ${NepaliDateFormatter("MMMM dd, y", language: _language).format(_selectedDateTime)}',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 18.0,
                ),
              ),
            SizedBox(height: 20),
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              color: Colors.pink,
              onPressed: () async {
                _selectedDateTime = await showNepaliDatePicker(
                  context: context,
                  initialDate: NepaliDateTime.now(),
                  firstDate: NepaliDateTime(2000),
                  lastDate: NepaliDateTime(2090),
                  language: _language,
                );
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
            SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(width: 10.0),
                Text(
                  'Language: ',
                  style: TextStyle(fontSize: 18.0),
                ),
                Flexible(
                  child: RadioListTile<Language>(
                    value: Language.ENGLISH,
                    groupValue: _language,
                    onChanged: (value) {
                      setState(() {
                        _language = value;
                      });
                    },
                    title: Text('English'),
                  ),
                ),
                Flexible(
                  child: RadioListTile<Language>(
                    value: Language.NEPALI,
                    groupValue: _language,
                    onChanged: (value) {
                      setState(() {
                        _language = value;
                      });
                    },
                    title: Text('Nepali'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
