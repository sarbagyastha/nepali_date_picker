// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:nepali_utils/nepali_utils.dart';

import 'language_source.dart';

final Map<Language, NepaliDateFormat> _monthFormatters =
    <Language, NepaliDateFormat>{};

NepaliDateFormat _monthFormatterFor(Language language) {
  return _monthFormatters[language] ??= NepaliDateFormat.MMMM(language);
}

/// Formats month to literal form
String formattedMonth(int month, [Language? language]) {
  final resolvedLanguage = language ?? NepaliUtils.currentLanguage;
  return _monthFormatterFor(resolvedLanguage)
      .format(NepaliDateTime.utc(1970, month));
}

/// The [Language] of the device (phone) locale.
Language deviceLanguage() {
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  return Language.fromLocale(locale.toLanguageTag());
}

/// The [Language] to use for [context] according to [source].
Language languageOf(BuildContext context, LanguageSource source) {
  switch (source) {
    case .app:
      final locale = Localizations.maybeLocaleOf(context);
      if (locale == null) return deviceLanguage();
      return Language.fromLocale(locale.toLanguageTag());
    case .device:
      return deviceLanguage();
  }
}
