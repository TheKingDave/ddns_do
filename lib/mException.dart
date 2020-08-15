class MException implements Exception {
  final String message;

  MException(this.message);

  @override
  String toString() {
    return 'MException{message: $message}';
  }
}