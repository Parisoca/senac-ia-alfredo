import 'dart:collection';

import 'package:flutter/foundation.dart';

class LogEntry {
  LogEntry(this.level, this.message, {this.context, DateTime? time}) : time = time ?? DateTime.now();
  final String level; // INFO/WARN/ERROR
  final String message;
  final String? context; // optional context (screen/service)
  final DateTime time;

  @override
  String toString() => '[${time.toIso8601String()}][$level]${context != null ? '[$context]' : ''} $message';
}

class AppLogger extends ChangeNotifier {
  static final AppLogger I = AppLogger._();
  AppLogger._();

  final _logs = Queue<LogEntry>();
  int maxEntries = 500;

  UnmodifiableListView<LogEntry> get logs => UnmodifiableListView(_logs);

  void clear() {
    _logs.clear();
    notifyListeners();
  }

  void _add(String level, String message, {String? context}) {
    if (_logs.length >= maxEntries) _logs.removeFirst();
    _logs.add(LogEntry(level, message, context: context));
    if (kDebugMode) {
      // Also print in debug for convenience
      // ignore: avoid_print
      print(_logs.last.toString());
    }
    notifyListeners();
  }

  void info(String message, {String? context}) => _add('INFO', message, context: context);
  void warn(String message, {String? context}) => _add('WARN', message, context: context);
  void error(String message, {String? context}) => _add('ERROR', message, context: context);
}

void logInfo(String message, {String? context}) => AppLogger.I.info(message, context: context);
void logWarn(String message, {String? context}) => AppLogger.I.warn(message, context: context);
void logError(String message, {String? context}) => AppLogger.I.error(message, context: context);
