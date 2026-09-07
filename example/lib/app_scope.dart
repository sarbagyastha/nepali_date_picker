// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';
import 'package:nepali_utils/nepali_utils.dart';

///
class _AppModel(
  var Locale _locale,
  var Brightness _brightness,
  var Color _color,
) extends ChangeNotifier {
  this {
    _updateLanguage();
  }

  ///
  void toggleLocale() {
    _locale = _locale.languageCode == 'ne'
        ? Locale('en', 'US')
        : Locale('ne', 'NP');
    _updateLanguage();
    notifyListeners();
  }

  ///
  void toggleBrightness() {
    _brightness = _brightness == Brightness.light
        ? Brightness.dark
        : Brightness.light;
    notifyListeners();
  }

  ///
  void updateColor(Color color) {
    _color = color;
    notifyListeners();
  }

  ///
  bool get isNepali => _locale.languageCode == 'ne';

  ///
  Brightness get brightness => _brightness;

  ///
  Color get color => _color;

  void _updateLanguage() {
    NepaliUtils().language = _locale.languageCode == 'ne' ? .nepali : .english;
  }
}

///
class const AppScope({
  ///
  required final Widget Function(BuildContext, Locale, Brightness, Color)
  builder,

  ///
  final Locale defaultLocale = const Locale('en', 'US'),

  ///
  final Brightness defaultBrightness = .light,

  ///
  final Color defaultColor = Colors.orange,
  super.key,
}) extends StatefulWidget {
  ///
  // ignore: library_private_types_in_public_api
  static _AppModel of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<_LocaleScope>();
    assert(result != null, 'No AppScope found in context');
    return result!.model;
  }

  @override
  State<AppScope> createState() => _AppScopeState();
}

class _AppScopeState extends State<AppScope> {
  late final _AppModel _model;

  @override
  void initState() {
    super.initState();
    _model = _AppModel(
      widget.defaultLocale,
      widget.defaultBrightness,
      widget.defaultColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _LocaleScope(
      model: _model,
      child: ListenableBuilder(
        listenable: _model,
        builder: (ctx, _) {
          return widget.builder(
            ctx,
            _model._locale,
            _model._brightness,
            _model._color,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
}

class const _LocaleScope({required final _AppModel model, required super.child})
    extends InheritedWidget {
  @override
  bool updateShouldNotify(_LocaleScope old) {
    return model._locale != old.model._locale ||
        model._brightness != old.model._brightness ||
        model._color != old.model._color;
  }
}
