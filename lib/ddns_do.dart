import 'dart:io';

import 'digitalOcean.dart';
import 'httpError.dart';
import 'config.dart';

class DDNS {
  final Config config;
  final DigitalOcean _do;

  DDNS(this.config) : _do = DigitalOcean(config);

  void handleRequest(HttpRequest request) async {
    if (request.method != 'GET') {
      throw HttpError('Unsupported request: ${request.method}', 400);
    }

    final params = request.uri.queryParameters;

    final prioritize = params['prioritize'] ?? 'sent';
    final domain = params['domain'];
    final user = params['user'];
    final password = params['pw'];
    
    var ip = params['ip'];
    final remoteIp = request.connectionInfo.remoteAddress.address;
    
    // Check if ips are different, check prioritization
    if(ip != remoteIp) {
      if(prioritize != 'sent') {
        ip = remoteIp;
      }
    }

    final idIp = await _do.getRecord(domain);
    if(idIp == null) {
      // If no record, create one
      await _do.createRecord(domain, ip);
    } else if(idIp.ip != ip) {
      // If ip is different update record
      await _do.updateRecord(domain, idIp.copyWith(ip: ip));
    }
    
    throw HttpError('Ok', 200);
  }
}
