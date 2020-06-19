import 'dart:convert';
import 'dart:io';

import 'package:ddns_do/httpError.dart';
import 'package:ddns_do/config.dart';

class DDNS {
  final Config config;

  const DDNS(this.config);

  void handleRequest(HttpRequest request) {
    if (request.method != 'GET') {
      throw HttpError('Unsupported request: ${request.method}', 400);
    }

    final params = request.uri.queryParameters;
    // ipv4, username, password, domain
    // https://services.thekingdave.com/ddns/?ip=<ipaddr>&domain=<domain>&user=<usernam>&pw=<pass>
    final remoteIp = request.connectionInfo.remoteAddress.address;
    
    final ip = params['ip'];
    final domain = params['domain'];
    final user = params['user'];
    final password = params['pw'];

    request.response
      ..statusCode = 200
      ..headers.add(HttpHeaders.contentTypeHeader, 'text/plain')
      ..write(json.encode({
        'remoteIp': remoteIp,
        'ip': ip,
        'domain': domain,
        'user': user,
        'pw': password
      }))
      ..close();
  }
}
