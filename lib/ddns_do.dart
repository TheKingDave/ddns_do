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

    final remoteIp = request.connectionInfo.remoteAddress.address;
    final prioritize = params[config.query.prioritize] ?? config.default_prioritize;
    final domain = params[config.query.domain];
    final user = params[config.query.user];
    final password = params[config.query.password];
    var ip = params[config.query.ip] ?? remoteIp;
    
    if(domain == null || domain.isEmpty) {
      throw HttpError('Domain parameter is needed', 400);
    }
    
    final domainUser = config.domainMap[domain];
    if(domainUser == null) throw HttpError.unauthorized;
    if(domainUser.user != user) throw HttpError.unauthorized;
    if(!domainUser.checkPassword(password)) throw HttpError.unauthorized;

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
