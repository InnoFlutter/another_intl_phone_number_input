import 'package:flutter/material.dart';

/// More information
/// https://medium.com/gskinner-team/flutter-widgetview-a-simple-separation-of-layout-and-logic-f0be5a537b87
abstract class WidgetView<T extends StatefulWidget, S extends State<T>>
    extends StatelessWidget {
  final S state;

  T get widget => state.widget;

  const WidgetView({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context);
}