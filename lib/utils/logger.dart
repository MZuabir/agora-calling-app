// ignore_for_file: avoid_print

class Logger {
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String white = '\x1B[37m';

  static void log(dynamic message,
      {bool isError = false, StackTrace? stackTrace}) {
    String logMessage = message.toString();

    if (isError) {
      print('$logMessage\n${_formatStackTrace(stackTrace)}');
    } else {
      print(logMessage);
    }
  }

  static void info(dynamic message, {String? tag, StackTrace? stackTrace}) {
    logWithColor(message,
        tag: tag,
        colorCode: _cyan,
        stackTrace: stackTrace,
        headerFooter: "⚪⚪⚪");
  }

  static void warning(dynamic message, {String? tag, StackTrace? stackTrace}) {
    logWithColor(message,
        tag: tag,
        colorCode: _yellow,
        stackTrace: stackTrace,
        headerFooter: "🟡🟡🟡");
  }

  static void error(dynamic message, {String? tag, StackTrace? stackTrace}) {
    logWithColor(message,
        tag: tag,
        colorCode: _red,
        isError: true,
        stackTrace: stackTrace,
        headerFooter: "🔴🔴🔴");
  }

  static void success(dynamic message, {String? tag, StackTrace? stackTrace}) {
    logWithColor(message,
        tag: tag,
        colorCode: _green,
        stackTrace: stackTrace,
        headerFooter: "🟢🟢🟢");
  }

  static void logWithColor(dynamic message,
      {String? tag,
      String? colorCode,
      String headerFooter = "",
      bool isError = false,
      StackTrace? stackTrace}) {
    String coloredMessage = "";
    if (tag != null) {
      coloredMessage =
          '$headerFooter\n[$tag]   $colorCode$message$_reset\n$headerFooter';
    } else {
      coloredMessage = '$headerFooter\n$colorCode$message$_reset';
    }

    log(coloredMessage, isError: isError, stackTrace: stackTrace);
  }

  static String _formatStackTrace(StackTrace? stackTrace) {
    if (stackTrace == null) return '';

    final lines = stackTrace.toString().split('\n');
    final formattedLines = lines.map((line) => '    $line').join('\n');
    return '\n$formattedLines';
  }
}
