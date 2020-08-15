import 'package:dbcrypt/dbcrypt.dart';
import 'package:ddns_do/logger.dart';

class User {
  final String domain;
  final String user;
  final String password;

  User({this.domain, this.user, this.password});

  factory User.fromString(String text) {
    final split = text.trim().split(':');
    if (split.length != 3) {
      throw ArgumentError(
          'String must be splittable into 3 parts separated by ":"');
    }
    return User(
      domain: split[0],
      user: split[1],
      password: split[2],
    );
  }

  bool checkPassword(String password) {
    final logger = Logger();
    logger.d(password);
    logger.d(password.runtimeType);
    logger.d(this.password);
    logger.d(this.password.runtimeType);
    return DBCrypt().checkpw(password, this.password);
  }

  @override
  String toString() {
    return 'User{domain: $domain, user: $user, password: $password}';
  }
}
