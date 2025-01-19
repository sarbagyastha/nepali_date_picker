import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';

///
class _LocaleModel extends ChangeNotifier {
  ///
  _LocaleModel(Locale locale) : _locale = locale {
    _updateLanguage();
  }

  Locale _locale;

  ///
  void toggleLocale() {
    _locale =
        _locale.languageCode == 'ne' ? Locale('en', 'US') : Locale('ne', 'NP');
    _updateLanguage();
    notifyListeners();
  }

  ///
  bool get isNepali => _locale.languageCode == 'ne';

  void _updateLanguage() {
    NepaliUtils().language =
        _locale.languageCode == 'ne' ? Language.nepali : Language.english;
  }
}

///
class LocaleScope extends StatefulWidget {
  ///
  const LocaleScope({
    required this.builder,
    this.defaultLocale = const Locale('en', 'US'),
    super.key,
  });

  ///
  final Widget Function(BuildContext, Locale) builder;

  ///
  final Locale defaultLocale;

  ///
  static _LocaleModel of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<_LocaleScope>();
    assert(result != null, 'No LocaleScope found in context');
    return result!.model;
  }

  @override
  State<LocaleScope> createState() => _LocaleScopeState();
}

class _LocaleScopeState extends State<LocaleScope> {
  late final _LocaleModel _model;

  @override
  void initState() {
    super.initState();
    _model = _LocaleModel(widget.defaultLocale);
  }

  @override
  Widget build(BuildContext context) {
    return _LocaleScope(
      model: _model,
      child: ListenableBuilder(
        listenable: _model,
        builder: (ctx, _) => widget.builder(ctx, _model._locale),
      ),
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
}

class _LocaleScope extends InheritedWidget {
  const _LocaleScope({
    required this.model,
    required super.child,
  });

  final _LocaleModel model;

  @override
  bool updateShouldNotify(_LocaleScope old) {
    return model != old.model;
  }
}
