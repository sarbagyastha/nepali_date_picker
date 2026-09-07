# 🇳🇵 Nepali Date Picker + Calendar

[![Pub Package](https://img.shields.io/pub/v/nepali_date_picker)](https://pub.dev/packages/nepali_date_picker)
[![Licence](https://img.shields.io/badge/Licence-BSD-orange.svg)](https://github.com/sarbagyastha/nepali_date_picker/blob/main/LICENSE)
[![Demo](https://img.shields.io/badge/Demo-WEB-blueviolet.svg)](https://date.sarbagyastha.com.np)

A customizable, fully localized date picker for Flutter, built for the Nepali (Bikram Sambat) calendar.

## Features

- 🇳🇵 Full Bikram Sambat calendar support, from 1970 BS to 2250 BS
- 📅 Material, Cupertino, and adaptive picker styles
- 🎯 Single date and date range selection
- 🔄 Effortless conversion between Bikram Sambat and Gregorian dates
- 🎨 Themeable to match your app

## Getting Started

```yaml
dependencies:
  nepali_date_picker: ^<latest_version>
```

```bash
flutter pub get
```

## Usage

```dart
import 'package:nepali_date_picker/nepali_date_picker.dart';
```

### Single date

```dart
final date = await showNepaliDatePicker(
  context: context,
  initialDate: NepaliDateTime.now(),
  firstDate: NepaliDateTime(1970, 2, 5),
  lastDate: NepaliDateTime(2250, 11, 6),
);
```

### Date range

```dart
final range = await showNepaliDateRangePicker(
  context: context,
  firstDate: NepaliDateTime(1970, 2, 5),
  lastDate: NepaliDateTime(2250, 11, 6),
);
```

### Adaptive (Material on Android, Cupertino on iOS)

```dart
final date = await showAdaptiveDatePicker(
  context: context,
  initialDate: NepaliDateTime.now(),
  firstDate: NepaliDateTime(1970, 2, 5),
  lastDate: NepaliDateTime(2250, 11, 6),
);
```

See the [example app](https://github.com/sarbagyastha/nepali_date_picker/tree/main/example) for a complete integration.

## Demo

Try it live at [date.sarbagyastha.com.np](https://date.sarbagyastha.com.np).

## Related Package

Need more Nepali date/text utilities? Check out [nepali_utils](https://pub.dev/packages/nepali_utils) for date formatting, number conversion, and more — pairs well with this package.

## Contributing

Contributions are welcome! Open an issue or submit a [pull request](https://github.com/sarbagyastha/nepali_date_picker/pulls).

## License

Licensed under the [BSD-3 License](https://github.com/sarbagyastha/nepali_date_picker/blob/main/LICENSE).
