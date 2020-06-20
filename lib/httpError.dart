import 'dart:io';

class HttpError implements Exception {
  final int statusCode;
  final String message;

  const HttpError(this.message, [this.statusCode = HttpStatus.notFound]);

  static const HttpError unauthorized =
      HttpError('Unauthorized', HttpStatus.unauthorized);
}
