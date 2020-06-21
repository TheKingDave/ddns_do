import 'dart:io';
import 'package:ddns_do/ddns_file.dart';
import 'package:dotenv/dotenv.dart' show load, env;

import 'package:ddns_do/user.dart';
import 'package:ddns_do/httpError.dart';
import 'package:ddns_do/config.dart';
import 'package:ddns_do/ddns_do.dart';
import 'package:public_suffix/public_suffix_io.dart';
import 'package:yaml/yaml.dart';

Future main(List<String> arguments) async {
  final confFile = File('config.yaml');

  if (!await confFile.exists()) {
    return print('Could not read config file');
  }

  final contents = await confFile.readAsString();
  final config = Config.fromMap(loadYaml(contents));

  final listUri =
      Uri.parse('https://publicsuffix.org/list/public_suffix_list.dat');
  await SuffixRulesHelper.initFromUri(listUri);

  load(config.dotenv);
  config.doAuthToken = env[config.doAuthTokenEnv];
  if (config.doAuthToken == null || config.doAuthToken.isEmpty) {
    print('Could not find env variable ${config.doAuthTokenEnv}');
  }

  // Load ddns file
  config.domainMap = await DdnsFile(config.ddns_file).readFile();

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
    }
  }
}
