import 'dart:convert';

class LogLevel {
  final int level;
  final String name;
  
  static const error = LogLevel._internal(1, 'Error');
  static const info = LogLevel._internal(2, 'Info');
  static const verbose = LogLevel._internal(3, 'Verbose');
  static const debug = LogLevel._internal(4, 'Debug');

  const LogLevel._internal(this.level, this.name);

  factory LogLevel.fromString(String str, [fallback = LogLevel.error]) {
    str = str.toLowerCase();
    switch (str) {
      case 'error':
        return LogLevel.error;
      case 'info':
        return LogLevel.info;
      case 'verbose':
        return LogLevel.verbose;
      case 'debug':
        return LogLevel.debug;
    }
    return fallback;
  }

  bool shouldLog(LogLevel level) => level.level <= this.level;
}

class Logger {
  LogLevel logLevel = LogLevel.error;
  bool printStackTraceOnError = true;
  bool printTimestamp = false;
  bool printColors = false;

  static final colorReset = '\u001b[0m';

  static final levelColors = {
    LogLevel.error: '\u001b[31m',
    LogLevel.info: '\u001b[34m',
    LogLevel.verbose: '\u001b[36m',
    LogLevel.debug: '\u001b[35m',
  };

  static Logger _instance;

  factory Logger() {
    _instance ??= Logger._internal();
    return _instance;
  }

  Logger._internal();

  // https://github.com/leisim/logger/blob/7b495ba25b4d3411043de71373711454a186ee9d/lib/src/printers/pretty_printer.dart#L181-L188
  String stringifyMessage(dynamic message) {
    if (message is Map || message is Iterable) {
      var encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(message);
    } else {
      return message.toString();
    }
  }

  void log(dynamic message, LogLevel level) {
    if (!logLevel.shouldLog(level)) {
      return;
    }

    var msg = '';

    if (printTimestamp) msg += DateTime.now().toString() + ' ';
    if(printColors) msg += levelColors[level];
    msg += '${level.name}: ';
    if(printColors) msg += colorReset;
    msg += stringifyMessage(message);
    print(msg);

    if (level == LogLevel.error && printStackTraceOnError) {
      print(StackTrace.current);
    }
  }

  void e(dynamic message) => log(message, LogLevel.error);

  void i(dynamic message) => log(message, LogLevel.info);

  void v(dynamic message) => log(message, LogLevel.verbose);

  void d(dynamic message) => log(message, LogLevel.debug);
}
