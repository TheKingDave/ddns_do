import 'dart:io';

import 'package:ddns_do/httpError.dart';
import 'package:ddns_do/config.dart';
import 'package:ddns_do/ddns_do.dart';

Future main(List<String> arguments) async {
  final config = Config('localhost', 4040);
  
  final server = await HttpServer.bind(config.host, config.port);
  
  final ddns = DDNS(config);
  
  print('Server listening on ${config.host}:${config.port}');

  await for (var request in server) {
    try {
      ddns.handleRequest(request);
    } on HttpError catch (e) {
      request.response
          ..statusCode = e.statusCode
          ..write(e.message);
      await request.response.close();
    }
  }
}
