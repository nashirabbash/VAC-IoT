import 'package:flutter/foundation.dart';

class LogService {
  static final ValueNotifier<List<String>> logsNotifier = ValueNotifier<List<String>>([]);

  static void log(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final formatted = '[$timestamp] $message';
    debugPrint(formatted);
    logsNotifier.value = [...logsNotifier.value, formatted];
  }

  static void clear() {
    logsNotifier.value = [];
  }
}
