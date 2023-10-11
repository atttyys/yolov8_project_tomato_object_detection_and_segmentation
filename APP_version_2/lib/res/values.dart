import 'package:flutter/foundation.dart';

final ValueNotifier<Map<String, dynamic>> summaryNotifier =
    ValueNotifier<Map<String, dynamic>>({});

final ValueNotifier<String> apiIpNotifier =
    ValueNotifier<String>("http://192.168.31.147:5000/");

final ValueNotifier<double> preprocessTimeNotifier = ValueNotifier<double>(0.0);
final ValueNotifier<double> inferenceTimeNotifier = ValueNotifier<double>(0.0);
final ValueNotifier<double> postprocessTimeNotifier =
    ValueNotifier<double>(0.0);
