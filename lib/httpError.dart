class HttpError implements Exception {
  final int statusCode;
  final String message;

  HttpError(this.message, [this.statusCode=400]);
}