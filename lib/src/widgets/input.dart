import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:another_intl_phone_number_input/src/widgets/country_select.dart';
import 'package:another_intl_phone_number_input/src/models/country.dart';
import 'package:another_intl_phone_number_input/src/providers/country_provider.dart';
import 'package:another_intl_phone_number_input/src/utils/utils.dart';
import 'package:another_intl_phone_number_input/src/utils/phone_number.dart';
import 'package:another_intl_phone_number_input/src/utils/phone_number_util.dart';
import 'package:another_intl_phone_number_input/src/utils/formatters/phone_formatter.dart';
import 'package:another_intl_phone_number_input/src/utils/formatters/dial_formatter.dart';
import 'package:another_intl_phone_number_input/src/utils/widget_view.dart';

class AnotherInternationalPhoneNumberInput extends StatefulWidget {
  final ValueChanged<PhoneNumber>? onInputChanged;
  final ValueChanged<bool>? onInputValidated;
  final ValueChanged<PhoneNumber>? onSaved;

  final TextInputType keyboardType;

  final PhoneNumber? initialValue;
  final bool formatInput;
  final int maxLength;
  final bool? useLocaleToSetCountry;
  final String? inititalCountry;

  final List<String>? countries;

  /// Styles
  final InputDecoration? inputDecoration;
  final TextStyle? textStyle;

  AnotherInternationalPhoneNumberInput(
      {Key? key,
      this.onInputChanged,
      this.onInputValidated,
      this.onSaved,
      this.keyboardType = TextInputType.phone,
      this.formatInput = true,
      this.countries,
      this.maxLength = 15,
      this.useLocaleToSetCountry = false,
      this.inititalCountry = 'GB',
      this.inputDecoration,
      this.textStyle,
      this.initialValue})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _InputWidgetState();
}

/// State of the widget
class _InputWidgetState extends State<AnotherInternationalPhoneNumberInput> {
  TextEditingController? controller;
  TextEditingController? dialCodeController;

  Country? country;
  List<Country> countries = [];
  bool isNotValid = true;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    dialCodeController = TextEditingController();
    setup();
    initCountries();
    Future.delayed(Duration.zero, () {
      if (widget.useLocaleToSetCountry ?? false) {
        initCountryByLocale();
      }
    });
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _InputWidgetView(
      state: this,
    );
  }

  @override
  void didUpdateWidget(AnotherInternationalPhoneNumberInput oldWidget) {
    initCountries(previouslySelectedCountry: country);
    if (oldWidget.initialValue?.hash != widget.initialValue?.hash) {
      if (country!.alpha2Code != widget.initialValue?.isoCode) {
        initCountries();
      }
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  /// Intitialization of the widget
  void setup() async {
    if (widget.initialValue != null) {
      if (widget.initialValue!.phoneNumber != null &&
          widget.initialValue!.phoneNumber!.isNotEmpty &&
          (await PhoneNumberUtil.isValidNumber(
              phoneNumber: widget.initialValue!.phoneNumber!,
              isoCode: widget.initialValue!.isoCode!))!) {
        String phoneNumber =
            await PhoneNumber.getParsableNumber(widget.initialValue!);

        controller!.text = widget.formatInput
            ? phoneNumber
            : phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

        phoneNumberControllerListener();
      }
    }
  }

  void initCountries({
    Country? previouslySelectedCountry,
  }) {
    if (this.mounted) {
      List<Country> countries =
          CountryProvider.getCountriesData(countries: widget.countries);

      Country? initialCountry = this
          .countries
          .firstWhereOrNull((el) => el.alpha2Code == widget.inititalCountry);

      Country country = previouslySelectedCountry ??
          (initialCountry ??
              Utils.getInitialSelectedCountry(
                countries,
                widget.initialValue?.isoCode ?? '',
              ));

      // Remove potential duplicates
      countries = countries.toSet().toList();

      setState(() {
        this.countries = countries;
        this.country = country;
        this.dialCodeController!.value = TextEditingValue(
          text: country.dialCode.toString(),
          selection: TextSelection.fromPosition(
            TextPosition(offset: country.dialCode.toString().length),
          ),
        );
      });
    }
  }

  void initCountryByLocale() {
    Locale myLocale = Localizations.localeOf(context);
    Country? localeCountry = this.countries.firstWhereOrNull(
        (el) => el.alpha2Code == myLocale.countryCode.toString());
    if (localeCountry != null) {
      setState(() {
        this.country = localeCountry;
        this.dialCodeController!.value = TextEditingValue(
          text: localeCountry.dialCode.toString(),
          selection: TextSelection.fromPosition(
            TextPosition(offset: localeCountry.dialCode.toString().length),
          ),
        );
      });
    }
  }

  void onCountryChanged(Country? country) {
    setState(() {
      this.country = country;
    });
    String _newValue = (country?.dialCode ?? '');
    this.dialCodeController!.value = TextEditingValue(
      text: _newValue,
      selection: TextSelection.fromPosition(
        TextPosition(offset: _newValue.length),
      ),
    );
    phoneNumberControllerListener();
  }

  void phoneNumberControllerListener() {
    if (this.mounted) {
      String parsedPhoneNumberString =
          controller!.text.replaceAll(RegExp(r'[^\d+]'), '');

      getParsedPhoneNumber(parsedPhoneNumberString, this.country?.alpha2Code)
          .then((phoneNumber) {
        if (phoneNumber == null) {
          String phoneNumber =
              '${this.country?.dialCode}$parsedPhoneNumberString';

          if (widget.onInputChanged != null) {
            widget.onInputChanged!(PhoneNumber(
                phoneNumber: phoneNumber,
                isoCode: this.country?.alpha2Code,
                dialCode: this.country?.dialCode));
          }

          if (widget.onInputValidated != null) {
            widget.onInputValidated!(false);
          }
          this.isNotValid = true;
        } else {
          if (widget.onInputChanged != null) {
            widget.onInputChanged!(PhoneNumber(
                phoneNumber: phoneNumber,
                isoCode: this.country?.alpha2Code,
                dialCode: this.country?.dialCode));
          }

          if (widget.onInputValidated != null) {
            widget.onInputValidated!(true);
          }
          this.isNotValid = false;
        }
      });
    }
  }

  Future<String?> getParsedPhoneNumber(
      String phoneNumber, String? isoCode) async {
    if (phoneNumber.isNotEmpty && isoCode != null) {
      try {
        bool? isValidPhoneNumber = await PhoneNumberUtil.isValidNumber(
            phoneNumber: phoneNumber, isoCode: isoCode);

        if (isValidPhoneNumber!) {
          return await PhoneNumberUtil.normalizePhoneNumber(
              phoneNumber: phoneNumber, isoCode: isoCode);
        }
      } on Exception {
        return null;
      }
    }
    return null;
  }

  void onChanged(String value) {
    phoneNumberControllerListener();
  }

  void _phoneNumberSaved() {
    if (this.mounted) {
      String parsedPhoneNumberString =
          controller!.text.replaceAll(RegExp(r'[^\d+]'), '');

      String phoneNumber =
          '${this.country?.dialCode ?? ''}' + parsedPhoneNumberString;

      widget.onSaved?.call(
        PhoneNumber(
            phoneNumber: phoneNumber,
            isoCode: this.country?.alpha2Code,
            dialCode: this.country?.dialCode),
      );
    }
  }

  void onSaved(String? value) {
    _phoneNumberSaved();
  }

  void onDialCodeChanged(String value) {
    Country? newCountry =
        this.countries.firstWhereOrNull((el) => el.dialCode == value);
    if (newCountry != null) {
      setState(() {
        this.country = newCountry;
      });
      phoneNumberControllerListener();
    }
  }
}

/// View of the widget
class _InputWidgetView extends WidgetView<AnotherInternationalPhoneNumberInput,
    _InputWidgetState> {
  final _InputWidgetState state;

  _InputWidgetView({Key? key, required this.state})
      : super(key: key, state: state);

  @override
  Widget build(BuildContext context) {
    final countryCode = state.country?.alpha2Code ?? '';
    final dialCode = state.country?.dialCode ?? '';

    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CountrySelect(
            country: state.country,
            countries: state.countries,
            onCountryChanged: state.onCountryChanged),
        SizedBox(
          // flex: 1,
          width: dialCode.length * 10,
          child: TextFormField(
              key: Key('country_code'),
              keyboardType: widget.keyboardType,
              controller: state.dialCodeController,
              decoration: widget.inputDecoration,
              style: widget.textStyle,
              onChanged: state.onDialCodeChanged,
              inputFormatters: [
                LengthLimitingTextInputFormatter(5),
                DialFormatter()
              ]),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: TextFormField(
            key: Key('phone'),
            keyboardType: widget.keyboardType,
            onChanged: state.onChanged,
            onSaved: state.onSaved,
            controller: state.controller,
            decoration: widget.inputDecoration,
            style: widget.textStyle,
            inputFormatters: [
              LengthLimitingTextInputFormatter(widget.maxLength),
              widget.formatInput
                  ? PhoneFormatter(
                      isoCode: countryCode,
                      dialCode: dialCode,
                      onInputFormatted: (TextEditingValue value) {
                        print('FORMATTED ' + value.text.toString());
                        state.controller!.value = value;
                      },
                    )
                  : FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        )
      ],
    ));
  }
}
