import 'dart:io';

import 'package:logger/logger.dart';

import 'user.dart';
import 'package:yaml/yaml.dart';

class Config {
  final String dotenv;
  final Uri listUri;
  final String host;
  final int port;
  final String doAuthTokenEnv;
  final int ttl;
  String ddns_file;
  final String default_prioritize;
  final _Query query;
  String doAuthToken;
  Map<String, User> domainMap;
  final Logger logger;

  Config(
      {this.dotenv,
      this.listUri,
      this.host,
      this.port,
      this.doAuthToken,
      this.doAuthTokenEnv,
      this.ttl,
      this.ddns_file,
      this.default_prioritize,
      this.query,
      this.logger});

  factory Config.fromMap(YamlMap map) {
    map = map ?? YamlMap();

    return Config(
        dotenv: map['dotenv'] ?? '.env',
        listUri: map['suffixList'] != null
            ? Uri.parse(map['suffixList'])
            : Uri.parse('https://publicsuffix.org/list/public_suffix_list.dat'),
        host: map['host'] ?? '127.0.0.1',
        port: map['port'] ?? 80,
        doAuthTokenEnv: map['doAuthTokenEnv'] ?? 'DO_AUTH_TOKEN',
        ttl: map['ttl'] ?? 60,
        ddns_file: map['ddns_file'] ?? 'ddns',
        default_prioritize:
            (map['default_prioritize']?.toString() ?? 'sent').toLowerCase(),
        query: _Query.fromMap(map['query']),
        logger: buildLogger(map['logger']));
  }
  
  static Logger buildLogger(YamlMap map) {
    map = map ?? YamlMap();
    
    Logger.level = Level.values.firstWhere((e) =>
    e.toString().toLowerCase() ==
        ('Level.' + (map['level'] ?? 'info')).toLowerCase());

    final bool stackTrace = map['stacktrace'] ?? false;
    
    final logger = Logger(
      printer: PrettyPrinter(
        colors: map['file'] == null,
        errorMethodCount: 8,
        methodCount: stackTrace ? 2 : 0,
        printTime: map['timestamp'],
      ),
      output: ConsoleOutput(),
    );
    
    return logger;
  }
  
  @override
  String toString() {
    return 'Config{dotenv: $dotenv, host: $host, port: $port, doAuthToken: $doAuthToken, doAuthTokenEnv: $doAuthTokenEnv, ttl: $ttl, ddns_file: $ddns_file, query: $query}';
  }
}

class _Query {
  final String ip;
  final String domain;
  final String user;
  final String password;
  final String prioritize;

  _Query({this.ip, this.domain, this.user, this.password, this.prioritize});

  factory _Query.fromMap(YamlMap map) {
    map = map ?? YamlMap();
    return _Query(
        ip: map['ip'] ?? 'ip',
        domain: map['domain'] ?? 'domain',
        user: map['user'] ?? 'user',
        password: map['password'] ?? 'password',
        prioritize: map['prioritize'] ?? 'prioritize');
  }

  @override
  String toString() {
    return '_Query{ip: $ip, domain: $domain, user: $user, password: $password, prioritize: $prioritize}';
  }
}
