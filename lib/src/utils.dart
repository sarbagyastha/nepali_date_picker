// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:nepali_utils/nepali_utils.dart';

/// Formats month to literal form
String formattedMonth(int month, [Language? language]) {
  final isEnglish = (language ?? NepaliUtils().language) == Language.english;

  switch (month) {
    case 1:
      return isEnglish ? 'Baishakh' : 'बैशाख';
    case 2:
      return isEnglish ? 'Jestha' : 'जेष्ठ';
    case 3:
      return isEnglish ? 'Ashadh' : 'आषाढ';
    case 4:
      return isEnglish ? 'Shrawan' : 'श्रावण';
    case 5:
      return isEnglish ? 'Bhadra' : 'भाद्र';
    case 6:
      return isEnglish ? 'Ashwin' : 'आश्विन';
    case 7:
      return isEnglish ? 'Kartik' : 'कार्त्तिक';
    case 8:
      return isEnglish ? 'Mangsir' : 'मङ्सिर';
    case 9:
      return isEnglish ? 'Poush' : 'पौष';
    case 10:
      return isEnglish ? 'Magh' : 'माघ';
    case 11:
      return isEnglish ? 'Falgun' : 'फाल्गुण';
    case 12:
      return isEnglish ? 'Chaitra' : 'चैत्र';
    default:
      return '';
  }
}
