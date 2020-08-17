import 'dart:io';

import 'logger.dart';

import 'digitalOcean.dart';
import 'httpError.dart';
import 'config.dart';
import 'mapExt.dart';

class DDNS {
  final Logger logger = Logger();
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
      throw HttpError(
          'Unsupported method: ${request.method}', HttpStatus.methodNotAllowed);
    }

    logger.d(request.headers);

    if (config.ipHeader != null && request.headers[config.ipHeader] == null) {
      logger.e('IpHeader "${config.ipHeader}" was not set on request');
      throw HttpError.internalServerError;
    }

    final params = request.uri.queryParameters;

    if (!params.containsAllKeys(requiredFields)) {
      throw HttpError(
          'Not all required GET parameters set. Required fields: ${requiredFields}');
    }

    final remoteIp = config.ipHeader == null
        ? request.connectionInfo.remoteAddress.address
        : request.headers[config.ipHeader].first;

    final prioritize =
        params[config.query.prioritize] ?? config.defaultPrioritization;
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
      if (prioritize == 'error') {
        throw HttpError('Sent ip and remote ip do not match', 400);
      }
      if (prioritize == 'remote') {
        ip = remoteIp;
      }
    }

    var status;

    final idIp = await _do.getRecord(domain);
    if (idIp == null) {
      // If no record, create one
      await _do.createRecord(domain, ip);
      status = HttpError('Created $ip', 200);
    } else if (idIp.ip != ip) {
      // If ip is different update record
      await _do.updateRecord(domain, idIp.copyWith(ip: ip));
      status = HttpError('Updated $ip', 200);
    } else {
      // If ip is present and is equal don't change
      status = HttpError('Unchanged $ip', 200);
    }

    throw status;
  }
}
