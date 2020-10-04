// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
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
    Key key,
    NepaliDateTime initialDate,
    @required NepaliDateTime firstDate,
    @required NepaliDateTime lastDate,
    this.onDateSubmitted,
    this.onDateSaved,
    this.selectableDayPredicate,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
    this.autofocus = false,
  })  : assert(firstDate != null),
        assert(lastDate != null),
        assert(autofocus != null),
        initialDate = initialDate != null ? utils.dateOnly(initialDate) : null,
        firstDate = utils.dateOnly(firstDate),
        lastDate = utils.dateOnly(lastDate),
        super(key: key) {
    assert(!this.lastDate.isBefore(this.firstDate),
        'lastDate ${this.lastDate} must be on or after firstDate ${this.firstDate}.');
    assert(initialDate == null || !this.initialDate.isBefore(this.firstDate),
        'initialDate ${this.initialDate} must be on or after firstDate ${this.firstDate}.');
    assert(initialDate == null || !this.initialDate.isAfter(this.lastDate),
        'initialDate ${this.initialDate} must be on or before lastDate ${this.lastDate}.');
    assert(
        selectableDayPredicate == null ||
            initialDate == null ||
            selectableDayPredicate(this.initialDate),
        'Provided initialDate ${this.initialDate} must satisfy provided selectableDayPredicate.');
  }

  /// If provided, it will be used as the default value of the field.
  final NepaliDateTime initialDate;

  /// The earliest allowable [DateTime] that the user can input.
  final NepaliDateTime firstDate;

  /// The latest allowable [DateTime] that the user can input.
  final NepaliDateTime lastDate;

  /// An optional method to call when the user indicates they are done editing
  /// the text in the field. Will only be called if the input represents a valid
  /// [NepaliDateTime].
  final ValueChanged<NepaliDateTime> onDateSubmitted;

  /// An optional method to call with the final date when the form is
  /// saved via [FormState.save]. Will only be called if the input represents
  /// a valid [NepaliDateTime].
  final ValueChanged<NepaliDateTime> onDateSaved;

  /// Function to provide full control over which [NepaliDateTime] can be selected.
  final common.SelectableDayPredicate selectableDayPredicate;

  /// The error text displayed if the entered date is not in the correct format.
  final String errorFormatText;

  /// The error text displayed if the date is not valid.
  ///
  /// A date is not valid if it is earlier than [firstDate], later than
  /// [lastDate], or doesn't pass the [selectableDayPredicate].
  final String errorInvalidText;

  /// The hint text displayed in the [TextField].
  ///
  /// If this is null, it will default to the date format string. For example,
  /// 'mm/dd/yyyy' for en_US.
  final String fieldHintText;

  /// The label text displayed in the [TextField].
  ///
  /// If this is null, it will default to the words representing the date format
  /// string. For example, 'Month, Day, Year' for en_US.
  final String fieldLabelText;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  @override
  _InputDatePickerFormFieldState createState() =>
      _InputDatePickerFormFieldState();
}

class _InputDatePickerFormFieldState extends State<InputDatePickerFormField> {
  final TextEditingController _controller = TextEditingController();
  NepaliDateTime _selectedDate;
  String _inputText;
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
    if (_selectedDate != null) {
      // TODO: Support nepali input
      _inputText = NepaliDateFormat.yMd(Language.english).format(_selectedDate);
      var textEditingValue = _controller.value.copyWith(text: _inputText);
      // Select the new text if we are auto focused and haven't selected the text before.
      if (widget.autofocus && !_autoSelected) {
        textEditingValue = textEditingValue.copyWith(
            selection: TextSelection(
          baseOffset: 0,
          extentOffset: _inputText.length,
        ));
        _autoSelected = true;
      }
      _controller.value = textEditingValue;
    }
  }

  NepaliDateTime _parseDate(String text) {
    if (RegExp(r'^2[01]\d{2}/(0[1-9]|1[0-2])/(0[1-9]|1[1-9]|2[1-9]|3[0-2])')
        .hasMatch(text)) {
      return NepaliDateTime.parse(text.replaceAll('/', '-'));
    }
    return null;
  }

  bool _isValidAcceptableDate(NepaliDateTime date) {
    return date != null &&
        !date.isBefore(widget.firstDate) &&
        !date.isAfter(widget.lastDate) &&
        (widget.selectableDayPredicate == null ||
            widget.selectableDayPredicate(date));
  }

  String _validateDate(String text) {
    final date = _parseDate(text);
    if (date == null) {
      return widget.errorFormatText ?? 'Invalid format.';
    } else if (!_isValidAcceptableDate(date)) {
      return widget.errorInvalidText ?? 'Out of range.';
    }
    return null;
  }

  void _handleSaved(String text) {
    if (widget.onDateSaved != null) {
      final date = _parseDate(text);
      if (_isValidAcceptableDate(date)) {
        _selectedDate = date;
        _inputText = text;
        widget.onDateSaved(date);
      }
    }
  }

  void _handleSubmitted(String text) {
    if (widget.onDateSubmitted != null) {
      final date = _parseDate(text);
      if (_isValidAcceptableDate(date)) {
        _selectedDate = date;
        _inputText = text;
        widget.onDateSubmitted(date);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputTheme = Theme.of(context).inputDecorationTheme;
    return TextFormField(
      decoration: InputDecoration(
        border: inputTheme.border ?? const UnderlineInputBorder(),
        filled: inputTheme.filled ?? true,
        hintText: widget.fieldHintText ?? 'yyyy/mm/dd',
        labelText: widget.fieldLabelText ?? 'Enter Date',
      ),
      validator: _validateDate,
      inputFormatters: <TextInputFormatter>[
        _DateTextInputFormatter('/'),
      ],
      keyboardType: TextInputType.datetime,
      onSaved: _handleSaved,
      onFieldSubmitted: _handleSubmitted,
      autofocus: widget.autofocus,
      controller: _controller,
    );
  }
}

class _DateTextInputFormatter extends TextInputFormatter {
  _DateTextInputFormatter(this.separator);

  final String separator;

  final FilteringTextInputFormatter _filterFormatter =
      // Only allow digits and separators (slash, dot, comma, hyphen, space).
      FilteringTextInputFormatter.allow(RegExp(r'[\d\/\.,-\s]+'));

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final filteredValue = _filterFormatter.formatEditUpdate(oldValue, newValue);
    return filteredValue.copyWith(
      // Replace any separator character with the given separator
      text: filteredValue.text.replaceAll(RegExp(r'[\D]'), separator),
    );
  }
}
