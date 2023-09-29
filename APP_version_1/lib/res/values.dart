// values.dart
import 'package:flutter/foundation.dart';

final ValueNotifier<Map<String, dynamic>> summaryNotifier =
    ValueNotifier<Map<String, dynamic>>({});

final ValueNotifier<String> apiIpNotifier =
    ValueNotifier<String>("http://192.168.31.144:5000/");
