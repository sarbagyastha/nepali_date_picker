// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';

import 'date_picker_common.dart' as common;
import 'date_utils.dart' as utils;

/// A [TextFormField] configured to accept and validate a date entered by the user.
///
/// The text entered into this field will be constrained to only allow digits
/// and separators. When saved or submitted, the text will be parsed into a
/// [DateTime] according to the ambient locale. If the input text doesn't parse
/// into a date, the [errorFormatText] message will be displayed under the field.
///
/// [firstDate], [lastDate], and [selectableDayPredicate] provide constraints on
/// what days are valid. If the input date isn't in the date range or doesn't pass
/// the given predicate, then the [errorInvalidText] message will be displayed
/// under the field.
///
/// See also:
///
///  * [showDatePicker], which shows a dialog that contains a material design
///    date picker which includes support for text entry of dates.
///  * [MaterialLocalizations.parseCompactDate], which is used to parse the text
///    input into a [DateTime].
///
class InputDatePickerFormField extends StatefulWidget {
  /// Creates a [TextFormField] configured to accept and validate a date.
  ///
  /// If the optional [initialDate] is provided, then it will be used to populate
  /// the text field. If the [fieldHintText] is provided, it will be shown.
  ///
  /// If [initialDate] is provided, it must not be before [firstDate] or after
  /// [lastDate]. If [selectableDayPredicate] is provided, it must return `true`
  /// for [initialDate].
  ///
  /// [firstDate] must be on or before [lastDate].
  ///
  /// [firstDate], [lastDate], and [autofocus] must be non-null.
  ///
  InputDatePickerFormField({
    Key? key,
    NepaliDateTime? initialDate,
    required NepaliDateTime firstDate,
    required NepaliDateTime lastDate,
    this.onDateSubmitted,
    this.onDateSaved,
    this.selectableDayPredicate,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
    this.autofocus = false,
  })  : initialDate = initialDate != null ? utils.dateOnly(initialDate) : null,
        firstDate = utils.dateOnly(firstDate),
        lastDate = utils.dateOnly(lastDate),
        super(key: key) {
    assert(!this.lastDate.isBefore(this.firstDate),
        'lastDate ${this.lastDate} must be on or after firstDate ${this.firstDate}.');
    assert(initialDate == null || !this.initialDate!.isBefore(this.firstDate),
        'initialDate ${this.initialDate} must be on or after firstDate ${this.firstDate}.');
    assert(initialDate == null || !this.initialDate!.isAfter(this.lastDate),
        'initialDate ${this.initialDate} must be on or before lastDate ${this.lastDate}.');
    assert(
        selectableDayPredicate == null ||
            initialDate == null ||
            selectableDayPredicate!(this.initialDate!),
        'Provided initialDate ${this.initialDate} must satisfy provided selectableDayPredicate.');
  }

  /// If provided, it will be used as the default value of the field.
  final NepaliDateTime? initialDate;

  /// The earliest allowable [DateTime] that the user can input.
  final NepaliDateTime firstDate;

  /// The latest allowable [DateTime] that the user can input.
  final NepaliDateTime lastDate;

  /// An optional method to call when the user indicates they are done editing
  /// the text in the field. Will only be called if the input represents a valid
  /// [NepaliDateTime].
  final ValueChanged<NepaliDateTime>? onDateSubmitted;

  /// An optional method to call with the final date when the form is
  /// saved via [FormState.save]. Will only be called if the input represents
  /// a valid [NepaliDateTime].
  final ValueChanged<NepaliDateTime>? onDateSaved;

  /// Function to provide full control over which [NepaliDateTime] can be selected.
  final common.SelectableDayPredicate? selectableDayPredicate;

  /// The error text displayed if the entered date is not in the correct format.
  final String? errorFormatText;

  /// The error text displayed if the date is not valid.
  ///
  /// A date is not valid if it is earlier than [firstDate], later than
  /// [lastDate], or doesn't pass the [selectableDayPredicate].
  final String? errorInvalidText;

  /// The hint text displayed in the [TextField].
  ///
  /// If this is null, it will default to the date format string. For example,
  /// 'mm/dd/yyyy' for en_US.
  final String? fieldHintText;

  /// The label text displayed in the [TextField].
  ///
  /// If this is null, it will default to the words representing the date format
  /// string. For example, 'Month, Day, Year' for en_US.
  final String? fieldLabelText;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  @override
  _InputDatePickerFormFieldState createState() =>
      _InputDatePickerFormFieldState();
}

class _InputDatePickerFormFieldState extends State<InputDatePickerFormField> {
  final TextEditingController _controller = TextEditingController();
  NepaliDateTime? _selectedDate;
  String? _inputText;
  bool _autoSelected = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateValueForSelectedDate();
  }

  @override
  void didUpdateWidget(InputDatePickerFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      // Can't update the form field in the middle of a build, so do it next frame
      WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
        setState(() {
          _selectedDate = widget.initialDate;
          _updateValueForSelectedDate();
        });
      });
    }
  }

  void _updateValueForSelectedDate() {
    if (_selectedDate != null) {
      // TODO: Support nepali input
      _inputText =
          NepaliDateFormat.yMd(Language.english).format(_selectedDate!);
      var textEditingValue = _controller.value.copyWith(text: _inputText);
      // Select the new text if we are auto focused and haven't selected the text before.
      if (widget.autofocus && !_autoSelected) {
        textEditingValue = textEditingValue.copyWith(
            selection: TextSelection(
          baseOffset: 0,
          extentOffset: _inputText!.length,
        ));
        _autoSelected = true;
      }
      _controller.value = textEditingValue;
    } else {
      _inputText = '';
      _controller.value = _controller.value.copyWith(text: _inputText);
    }
  }

  NepaliDateTime? _parseDate(String? text) {
    if (text != null &&
        RegExp(r'^2[01]\d{2}/(0[1-9]|1[0-2])/(0[1-9]|1[0-9]|2[0-9]|3[0-2])')
            .hasMatch(text)) {
      return NepaliDateTime.parse(text.replaceAll('/', '-'));
    }
    return null;
  }

  bool _isValidAcceptableDate(NepaliDateTime? date) {
    return date != null &&
        !date.isBefore(widget.firstDate) &&
        !date.isAfter(widget.lastDate) &&
        (widget.selectableDayPredicate == null ||
            widget.selectableDayPredicate!(date));
  }

  bool _isDayInMonth(NepaliDateTime? date) {
    return date != null && date.day <= date.totalDays;
  }

  String? _validateDate(String? text) {
    final date = _parseDate(text);
    if (date == null) {
      return widget.errorFormatText ??
          MaterialLocalizations.of(context).invalidDateFormatLabel;
    } else if (!_isValidAcceptableDate(date)) {
      return widget.errorInvalidText ??
          MaterialLocalizations.of(context).dateOutOfRangeLabel;
    } else if (!_isDayInMonth(date)) {
      // TODO: Localize the text.
      return 'Invalid Day.';
    }
    return null;
  }

  void _updateDate(String? text, ValueChanged<NepaliDateTime>? callback) {
    final date = _parseDate(text);
    if (_isValidAcceptableDate(date)) {
      _selectedDate = date;
      _inputText = text;
      callback?.call(_selectedDate!);
    }
  }

  void _handleSaved(String? text) {
    _updateDate(text, widget.onDateSaved);
  }

  void _handleSubmitted(String? text) {
    _updateDate(text, widget.onDateSubmitted);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final inputTheme = Theme.of(context).inputDecorationTheme;
    return TextFormField(
      decoration: InputDecoration(
        border: inputTheme.border ?? const UnderlineInputBorder(),
        filled: inputTheme.filled,
        hintText: widget.fieldHintText ?? 'yyyy/mm/dd',
        labelText: widget.fieldLabelText ?? localizations.dateInputLabel,
      ),
      validator: _validateDate,
      keyboardType: TextInputType.datetime,
      onSaved: _handleSaved,
      onFieldSubmitted: _handleSubmitted,
      autofocus: widget.autofocus,
      controller: _controller,
    );
  }
}
