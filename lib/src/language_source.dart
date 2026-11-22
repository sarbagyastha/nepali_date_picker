// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Where a picker reads its default `Language` from when none is passed
/// explicitly.
enum LanguageSource {
  /// The app's resolved locale (`Localizations.localeOf`), falling back to
  /// the device locale when there is no `Localizations` ancestor.
  ///
  /// By default Flutter resolves the app locale from the device locale, so
  /// this follows the phone's language while staying consistent with the
  /// rest of the app's UI.
  app,

  /// The device (phone) locale, regardless of the app's locale.
  device,
}
