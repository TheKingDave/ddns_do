class Config {
  final String host;
  final int port;
  final String doAuthToken;
  final int ttl;

  Config(this.host, this.port, this.doAuthToken, [this.ttl = 60]);
}