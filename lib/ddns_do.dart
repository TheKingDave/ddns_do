import 'dart:io';

import 'digitalOcean.dart';
import 'httpError.dart';
import 'config.dart';
import 'mapExt.dart';

class DDNS {
  final Config config;
  final DigitalOcean _do;
  final List<String> requiredFields;

  DDNS(this.config)
      : _do = DigitalOcean(config),
        requiredFields = [
          config.query.domain,
          config.query.user,
          config.query.password
        ];

  void handleRequest(HttpRequest request) async {
    if (request.method != 'GET') {
      throw HttpError('Unsupported method: ${request.method}',
          HttpStatus.methodNotAllowed);
    }

    final params = request.uri.queryParameters;

    if (!params.containsAllKeys(requiredFields)) {
      throw HttpError(
          'Not all required GET parameters set. Required fields: ${requiredFields}');
    }

    final remoteIp = request.connectionInfo.remoteAddress.address;
    final prioritize =
        params[config.query.prioritize] ?? config.default_prioritize;
    var ip = params[config.query.ip] ?? remoteIp;
    final domain = params[config.query.domain];
    final user = params[config.query.user];
    final password = params[config.query.password];

    if (domain == null || domain.isEmpty) {
      throw HttpError('Domain parameter is needed');
    }

    // Check authentication
    final domainUser = config.domainMap[domain];
    if (domainUser == null ||
        domainUser.user != user ||
        !domainUser.checkPassword(password)) {
      throw HttpError.unauthorized;
    }

    // Check if ips are different, check prioritization
    if (ip != remoteIp) {
      if(prioritize == 'error') {
        throw HttpError('Sent ip and remote ip do not match', 400);
      }
      if (prioritize == 'remote') {
        ip = remoteIp;
      }
    }

    var status = HttpError.ok;
    
    final idIp = await _do.getRecord(domain);
    if (idIp == null) {
      // If no record, create one
      await _do.createRecord(domain, ip);
      status = HttpError.created;
    } else if (idIp.ip != ip) {
      // If ip is different update record
      await _do.updateRecord(domain, idIp.copyWith(ip: ip));
      status = HttpError('Updated', 208);
    }
    // If ip is present and is equal don't change

    throw status;
  }
}
