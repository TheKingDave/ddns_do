import 'package:yaml/yaml.dart';

class Config {
  final String dotenv;
  final String host;
  final int port;
  String doAuthToken;
  final String doAuthTokenEnv;
  final int ttl;
  final String ddns_file;
  final String default_prioritize;
  final _Query query;

  Config(
      {this.dotenv,
      this.host,
      this.port,
      this.doAuthToken,
      this.doAuthTokenEnv,
      this.ttl,
      this.ddns_file,
      this.default_prioritize,
      this.query});

  factory Config.fromMap(YamlMap map) {
    map = map ?? YamlMap();
    return Config(
        dotenv: map['dotenv'] ?? '.env',
        host: map['host'] ?? '127.0.0.1',
        port: map['port'] ?? 4040,
        doAuthTokenEnv: map['doAuthTokenEnv'] ?? 'DO_AUTH_TOKEN',
        ttl: map['ttl'] ?? 60,
        ddns_file: map['ddns_file'] ?? 'ddns',
        default_prioritize: map['default_prioritize'] ?? 'sent',
        query: _Query.fromMap(map['query']));
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
