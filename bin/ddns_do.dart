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
    print('Could not read config file ${confFile.path}');
    exit(1);
  }

  final contents = await confFile.readAsString();
  final config = Config.fromMap(loadYaml(contents));
  
  if (parseResults['ddns-file'] != null) {
    config.ddns_file = parseResults['ddns-file'];
  }
  
  try {
    await SuffixRulesHelper.initFromUri(config.listUri);
  } catch(e) {
    config.logger.e('Could not load suffix list from ${config.listUri.toString()}', e);
    exit(2);
  }

  load(config.dotenv);
  config.doAuthToken = env[config.doAuthTokenEnv];
  if (config.doAuthToken == null || config.doAuthToken.isEmpty) {
    config.logger.e('Could not find environment variable ${config.doAuthTokenEnv}');
    config.logger.close();
    exit(3);
  }

  // Load ddns file
  try {
    config.domainMap = await DdnsFile(config.ddns_file).readFile();
  } on Exception catch (e) {
    config.logger.e(e);
    config.logger.close();
    exit(4);
  }

  HttpServer server;
  try {
    server = await HttpServer.bind(config.host, config.port);
  } on SocketException {
    config.logger.e('Could not bind to port ${config.host}:${config.port}');
    exit(5);
  }

  final ddns = DDNS(config);

  config.logger.i('Server listening on ${server.address.host}:${server.port}');

  await for (var request in server) {
    try {
      config.logger.v(Map.from(request.uri.queryParameters)..[config.query.password] = '<hidden>');
      await ddns.handleRequest(request);
    } on HttpError catch (e) {
      if(e.statusCode >= 400) {
        config.logger.e('Error on request: ${e.toString()}', e);
      } else {
        config.logger.v(e.toString());
      }
      await sendError(request, e.message, e.statusCode);
      await request.response.close();
    } catch (e) {
      config.logger.e('Error on request', e);
      await sendError(request);
      await request.response.close();
    }
  }
}

void sendError(HttpRequest request, [String message='Server Error', int statusCode=500]) async {
  request.response
    ..headers.add(HttpHeaders.contentTypeHeader, 'text/plain')
    ..statusCode = statusCode
    ..write(message);
  await request.response.close();
}