import 'package:flutter/widgets.dart';

import 'package:another_intl_phone_number_input/src/models/country.dart';
import 'package:another_intl_phone_number_input/src/utils/utils.dart';

class CountryItem extends StatelessWidget {

  final Country? country;

  CountryItem({
    Key? key,
    this.country,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(Utils.generateFlagEmojiUnicode(country?.alpha2Code ?? ''))
    );
  }
}
