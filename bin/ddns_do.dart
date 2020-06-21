import 'dart:io';
import 'package:args/args.dart';
import 'package:ddns_do/ddns_file.dart';
import 'package:dotenv/dotenv.dart' show load, env;

import 'package:ddns_do/httpError.dart';
import 'package:ddns_do/config.dart';
import 'package:ddns_do/ddns_do.dart';
import 'package:public_suffix/public_suffix_io.dart';
import 'package:yaml/yaml.dart';

Future main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption('config-file',
      abbr: 'c',
      defaultsTo: './config.yaml',
      help: 'Defines which file to load',
      valueHelp: 'path');
  parser.addOption('ddns-file',
      abbr: 'd',
      help: 'If set overides DDNS-file specified in config',
      valueHelp: 'path');
  parser.addFlag('help',
      abbr: 'h',
      help: 'Shows usage and exists',
      negatable: false,
      defaultsTo: false);

  final parseResults = parser.parse(arguments);
  if (parseResults['help']) {
    print('DynamicDNS server for DigitalOcean\n');
    print(parser.usage);
    exit(0);
  }

  final confFile = File(parseResults['config-file']);

  if (!await confFile.exists()) {
    return print('Could not read config file ${confFile.path}');
  }

  final contents = await confFile.readAsString();
  final config = Config.fromMap(loadYaml(contents));
  if (parseResults['ddns-file'] != null) {
    config.ddns_file = parseResults['ddns-file'];
  }

  final listUri =
      Uri.parse('https://publicsuffix.org/list/public_suffix_list.dat');
  await SuffixRulesHelper.initFromUri(listUri);

  load(config.dotenv);
  config.doAuthToken = env[config.doAuthTokenEnv];
  if (config.doAuthToken == null || config.doAuthToken.isEmpty) {
    print('Could not find environment variable ${config.doAuthTokenEnv}');
    exit(1);
  }

  // Load ddns file
  try {
    config.domainMap = await DdnsFile(config.ddns_file).readFile();
  } on Exception catch (e) {
    print(e);
    exit(2);
  }

  HttpServer server;
  try {
    server = await HttpServer.bind(config.host, config.port);
  } on SocketException {
    print('Could not bind to port ${config.host}:${config.port}');
    exit(3);
  }

  final ddns = DDNS(config);

  print('Server listening on ${server.address.host}:${server.port}');

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
      request.response
        ..headers.add(HttpHeaders.contentTypeHeader, 'text/plain')
        ..statusCode = 500
        ..write('Serve error');
      await request.response.close();
    }
  }
}
