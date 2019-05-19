# Nepali Date Picker Example

```dart
Scaffold(
      appBar: AppBar(
        title: Text("Nepali Date Picker"),
        centerTitle: true,
      ),
      body: Center(
        child: MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              color: Colors.pink,
              onPressed: () async {
                _selectedDateTime = await picker.showDatePicker(
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
      ),
    );
```
