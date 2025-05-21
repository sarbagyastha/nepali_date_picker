# 🇳🇵 Nepali Date Picker + Calendar 📅

[![Pub Package](https://img.shields.io/pub/v/nepali_date_picker)](https://pub.dev/packages/nepali_date_picker)
[![Licence](https://img.shields.io/badge/Licence-BSD-orange.svg)](https://github.com/sarbagyastha/nepali_date_picker/blob/main/LICENSE)
[![Demo](https://img.shields.io/badge/Demo-WEB-blueviolet.svg)](https://date.sarbagyastha.com.np)
[![effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://dart.dev/guides/language/effective-dart)

A beautiful, customizable date picker widget for Flutter, fully localized for the Nepali (Bikram Sambat) calendar. This package allows users to select dates in the Nepali/Indian calendar system, making it perfect for apps targeting Nepali-speaking audiences or integrating regional calendar functionality.


## 🚀 Features
- 🇳🇵 Bikram Sambat (Nepali) Calendar support
  
- 🎨 Customizable UI to match your app’s theme
  
- ⚡ Easy Integration into any Flutter project
  
- ✅ Date Validation for valid Nepali dates only
  
- 📆 Supports date from 1970 BS to 2250 BS
  
- 🔄 Effortlessly convert between Bikram Sambat and Gregorian dates. 


## 🛠️ Getting Started
Add this to your pubspec.yaml:
```yaml
dependencies:
  nepali_date_picker: ^<latest_version>
```

Then run:
```bash
flutter pub get
```

## 💡 Usage
Import the package:
```dart
import 'package:nepali_date_picker/nepali_date_picker.dart';
```

Example usage:
```dart
final selectedDateTime = await showNepaliDatePicker(
  context: context,
  initialDate: _selectedDateTime ?? NepaliDateTime.now(),
  firstDate: NepaliDateTime(1970, 2, 5),
  lastDate: NepaliDateTime(2250, 11, 6),
  initialDatePickerMode: DatePickerMode.day,
);

print(selectedDateTime); // Outputs the selected date in NepaliDateTime type.
```

For a complete example, check out the [example](https://github.com/sarbagyastha/nepali_date_picker/tree/main/example).

## 🔗 Related Package
If you need additional Nepali date and text utilities, check out the [nepali_utils](https://pub.dev/packages/nepali_utils) package!
It offers handy helpers for Nepali date formatting, number conversion, and more.
Perfect to use alongside nepali_date_picker!

## 🤝 Contributing
Contributions are welcome! Feel free to open issues or submit [pull requests](https://github.com/sarbagyastha/nepali_date_picker/pulls).

## 📄 License
Licensed under the [BSD-3 License](https://github.com/sarbagyastha/nepali_date_picker/blob/main/LICENSE).