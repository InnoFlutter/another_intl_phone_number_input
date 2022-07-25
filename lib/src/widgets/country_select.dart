import 'package:another_intl_phone_number_input/src/models/country_list.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:another_intl_phone_number_input/src/widgets/country_item.dart';
import 'package:another_intl_phone_number_input/src/models/country.dart';

import 'package:country_picker/country_picker.dart' as countryPicker;

class CountrySelect extends StatelessWidget {
  final Country? country;
  final List<Country> countries;

  final ValueChanged<Country?> onCountryChanged;

  const CountrySelect(
      {Key? key,
      this.country,
      required this.countries,
      required this.onCountryChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 40.0,
      minWidth: 10.0,
      // padding: EdgeInsets.only(right: 5, left: 5, top: 0, bottom: 0),
      onPressed: () async {
        countryPicker.showCountryPicker(
          context: context,
          showPhoneCode: true,
          onSelect: (countryPicker.Country country) {
            Country? selected = countries.firstWhereOrNull((el) => el.alpha2Code == country.countryCode);
            onCountryChanged(selected);
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: CountryItem(country: country),
      ),
    );
  }
}
