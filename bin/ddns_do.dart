import 'dart:io';
import 'package:dotenv/dotenv.dart' show load, env;

import 'package:ddns_do/httpError.dart';
import 'package:ddns_do/config.dart';
import 'package:ddns_do/ddns_do.dart';
import 'package:public_suffix/public_suffix_io.dart';

Future main(List<String> arguments) async {
  load();

  final listUri =
      Uri.parse('https://publicsuffix.org/list/public_suffix_list.dat');
  await SuffixRulesHelper.initFromUri(listUri);

  final doAuthToken = env['DO_AUTH_TOKEN'];
  if (doAuthToken == null || doAuthToken.isEmpty) {
    print('Could not find DO_AUTH_TOKEN');
  }

  final config = Config('localhost', 4040, doAuthToken);

  final server = await HttpServer.bind(config.host, config.port);

  final ddns = DDNS(config);

  print('Server listening on ${config.host}:${config.port}');

  await for (var request in server) {
    try {
      await ddns.handleRequest(request);
    } on HttpError catch (e) {
      request.response
        ..headers.add(HttpHeaders.contentTypeHeader, 'text/plain')
        ..statusCode = e.statusCode
        ..write(e.message);
      await request.response.close();
    } catch (e) {
      print(e.toString());
    }
  }
}
