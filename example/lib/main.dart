import 'package:flutter/material.dart';

import 'package:another_intl_phone_number_input/another_intl_phone_number_input.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          appBar: AppBar(title: Text('Demo')),
          body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController controller = TextEditingController();
  // PhoneNumber number = PhoneNumber(isoCode: 'NG');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnotherInternationalPhoneNumberInput(
                useLocaleToSetCountry: true,
                onInputChanged: (number) {
                  print('onInputChanged: ' + number.toString());
                  Locale myLocale = Localizations.localeOf(context);
                  print('COUNTRY CODE: ' + myLocale.countryCode.toString());
                },
                onInputValidated: (number) {
                  print('onInputChanged: ' + number.toString());
                }
            ),
          ],
        ),
      ),
    );
  }
}
