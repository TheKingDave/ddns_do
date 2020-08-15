import 'dart:io';

class HttpError implements Exception {
  final int statusCode;
  final String message;

  const HttpError(this.message, [this.statusCode = HttpStatus.badRequest]);

  static const HttpError unauthorized =
      HttpError('Unauthorized', HttpStatus.unauthorized);

  static const HttpError internalServerError =
      HttpError('Internal Server Error', HttpStatus.internalServerError);

  static const HttpError created = HttpError('Created', HttpStatus.created);
  static const HttpError ok = HttpError('Ok', HttpStatus.ok);

  @override
  String toString() {
    return 'HttpError{statusCode: $statusCode, message: $message}';
  }
}
