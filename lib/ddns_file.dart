import 'dart:convert';
import 'dart:io';

import 'user.dart';

class DdnsFile {
  final String path;

  DdnsFile(this.path);

  Future<Map<String, User>> readFile() async {
    return Map.fromIterable(
        await File(path)
            .openRead()
            .transform(utf8.decoder)
            .transform(LineSplitter())
            .map((l) => User.fromString(l))
            .toList(),
        key: (e) => e.domain);
  }
}
