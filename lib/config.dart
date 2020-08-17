import 'logger.dart';

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
  final ipHeader;
  final String defaultPrioritization;
  final _Query query;
  String doAuthToken;
  Map<String, User> domainMap;

  Config({
    this.dotenv,
    this.listUri,
    this.host,
    this.port,
    this.doAuthToken,
    this.doAuthTokenEnv,
    this.ttl,
    this.ddns_file,
    this.ipHeader,
    this.defaultPrioritization,
    this.query,
  });

  factory Config.fromMap(YamlMap map) {
    map = map ?? YamlMap();

    setupLogger(map['logger']);

    return Config(
        dotenv: map['dotenv'],
        listUri: map['suffixList'] != null
            ? Uri.parse(map['suffixList'])
            : Uri.parse('https://publicsuffix.org/list/public_suffix_list.dat'),
        host: map['host'] ?? '127.0.0.1',
        port: map['port'] ?? 80,
        doAuthTokenEnv: map['doAuthTokenEnv'] ?? 'DO_AUTH_TOKEN',
        ttl: map['ttl'] ?? 60,
        ddns_file: map['ddns_file'] ?? 'ddns',
        ipHeader: map['ipHeader'],
        defaultPrioritization:
            (map['defaultPrioritization']?.toString() ?? 'sent').toLowerCase(),
        query: _Query.fromMap(map['query']));
  }

  static void setupLogger(YamlMap map) {
    map = map ?? YamlMap();
    final logger = Logger();

    logger.logLevel = LogLevel.fromString(map['level'] ?? 'error');
    logger.printStackTraceOnError = map['stacktrace'] ?? false;
    logger.printTimestamp = map['timestamp'] ?? false;
    logger.printColors = map['color'] ?? false;
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
