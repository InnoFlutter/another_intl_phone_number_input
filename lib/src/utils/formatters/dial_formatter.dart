import 'package:flutter/services.dart';

/// https://appvesto.medium.com/flutter-formatting-textfield-with-textinputformatter-c73ee2167514
class DialFormatter extends TextInputFormatter {

  DialFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 0) return newValue;
    return TextEditingValue(
        text: '+',
        selection: TextSelection.collapsed(offset: 1)
    );
  }
}