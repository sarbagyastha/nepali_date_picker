// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:nepali_utils/nepali_utils.dart';

/// Formats month to literal form
String formattedMonth(
  int month, [
  Language? language,
]) {
  final _isEnglish = (language ?? NepaliUtils().language) == Language.english;
  switch (month) {
    case 1:
      return _isEnglish ? 'Baishakh' : 'बैशाख';
    case 2:
      return _isEnglish ? 'Jestha' : 'जेष्ठ';
    case 3:
      return _isEnglish ? 'Ashadh' : 'अषाढ';
    case 4:
      return _isEnglish ? 'Shrawan' : 'श्रावण';
    case 5:
      return _isEnglish ? 'Bhadra' : 'भाद्र';
    case 6:
      return _isEnglish ? 'Ashwin' : 'आश्विन';
    case 7:
      return _isEnglish ? 'Kartik' : 'कार्तिक';
    case 8:
      return _isEnglish ? 'Mangsir' : 'मंसिर';
    case 9:
      return _isEnglish ? 'Poush' : 'पौष';
    case 10:
      return _isEnglish ? 'Magh' : 'माघ';
    case 11:
      return _isEnglish ? 'Falgun' : 'फाल्गुन';
    case 12:
      return _isEnglish ? 'Chaitra' : 'चैत्र';
    default:
      return '';
  }
}
