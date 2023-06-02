import 'package:flutter/material.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

///
class YearPickerWidget extends StatefulWidget {
  @override
  _YearPickerWidgetState createState() => _YearPickerWidgetState();
}

class _YearPickerWidgetState extends State<YearPickerWidget> {
  NepaliDateTime? _selectedYear;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selectedYear != null)
            Text(
              'Selected Year: ${NepaliDateFormat.y().format(_selectedYear!)}',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 18.0,
              ),
              textAlign: TextAlign.center,
            ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
              ),
              onPressed: () async {
                _selectedYear = await showMaterialYearPicker(
                  context: context,
                  firstYear: NepaliDateTime(2020),
                  lastYear: NepaliDateTime(2099),
                  selectedYear: _selectedYear,
                );
                setState(() {});
              },
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'SELECT YEAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w300,
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
