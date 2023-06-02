import 'package:flutter/material.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';

///
class MonthPickerWidget extends StatefulWidget {
  @override
  _MonthPickerWidgetState createState() => _MonthPickerWidgetState();
}

class _MonthPickerWidgetState extends State<MonthPickerWidget> {
  NepaliDateTime? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selectedMonth != null)
            Text(
              'Selected Month: ${NepaliDateFormat.MMMM(NepaliUtils().language).format(_selectedMonth!)}',
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
                final pickedMonth = await showMaterialMonthPicker(
                  context: context,
                  selectedMonth: _selectedMonth?.month,
                );
                _selectedMonth = pickedMonth == null
                    ? null
                    : NepaliDateTime(NepaliDateTime.now().year, pickedMonth);
                setState(() {});
              },
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'SELECT MONTH',
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
