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

Locale? _lastDeviceLocale;
Language _lastDeviceLanguage = .english;

/// The [Language] of the device (phone) locale.
///
/// The result is cached per locale, since this is called for every date the
/// calendar delegate formats.
Language deviceLanguage() {
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  if (locale != _lastDeviceLocale) {
    _lastDeviceLocale = locale;
    _lastDeviceLanguage = Language.fromLocale(locale.toLanguageTag());
  }
  return _lastDeviceLanguage;
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
