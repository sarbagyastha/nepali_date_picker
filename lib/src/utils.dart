// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:nepali_utils/nepali_utils.dart';

final Map<Language, NepaliDateFormat> _monthFormatters =
    <Language, NepaliDateFormat>{};

NepaliDateFormat _monthFormatterFor(Language language) {
  return _monthFormatters[language] ??= NepaliDateFormat.MMMM(language);
}

/// Formats month to literal form
String formattedMonth(int month, [Language? language]) {
  final resolvedLanguage = language ?? NepaliUtils().language;
  return _monthFormatterFor(resolvedLanguage)
      .format(NepaliDateTime(1970, month));
}
