# Nepali Date Picker

[![Pub Package](https://img.shields.io/badge/pub-v2.0.0-green.svg)](https://pub.dev/packages/nepali_date_picker)
[![Licence](https://img.shields.io/badge/Licence-MIT-orange.svg)](https://github.com/sarbagyastha/nepali_date_picker/blob/master/LICENSE)
[![Download](https://img.shields.io/badge/Download-APK-blueviolet.svg)
](https://github.com/sarbagyastha/nepali_date_picker/raw/master/nepali_date_picker.apk)

Bikram Sambat(B.S.) Date Picker.

![Portrait Screenshot](screenshot/portrait.jpg)

Nepali Date Picker returns data in **NepaliDateTime** type, which is
included in [*nepali_utils*](https://pub.dev/packages/nepali_utils)
package.

## Usage

#### 1\. Depend

Add this to you package's `pubspec.yaml` file:

```yaml
dependencies:
  nepali_date_picker: ^2.0.0+1
```

#### 2\. Install

Run command:

```bash
$ flutter packages get
```

#### 3\. Import

Import in Dart code:

```dart
import 'package:nepali_date_picker/nepali_date_picker.dart';
```

#### 4\. Display Nepali DatePicker

```dart
import 'package:nepali_date_picker/nepali_date_picker.dart' as picker;

NepaliDateTime _selectedDateTime = await showNepaliDatePicker(
      context: context,
      initialDate: NepaliDateTime.now(),
      firstDate: NepaliDateTime(2000),
      lastDate: NepaliDateTime(2090),
      language: Language.ENGLISH,
);

print(_selectedDateTime); // 2076-02-16T00:00:00
```

***In Landscape mode***

![Landscape Screenshot](screenshot/landscape.jpg)

## Example

[Example sources](https://github.com/sarbagyastha/nepali_date_picker/tree/master/example)


## License

```
Copyright (c) 2019 Sarbagya Dhaubanjar

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```