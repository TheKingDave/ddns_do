import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:public_suffix/public_suffix.dart';

import 'config.dart';
import 'httpError.dart';

const String _baseUrl = 'https://api.digitalocean.com/v2/domains/';

class BearerClient extends http.BaseClient {
  final String bearerToken;
  final http.Client _inner;

  BearerClient(this.bearerToken, this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer ${bearerToken}';
    return _inner.send(request);
  }
}

class IdIp {
  final int id;
  final String ip;

  IdIp(this.id, this.ip);

  @override
  String toString() {
    return 'IdIp{id: $id, ip: $ip}';
  }

  IdIp copyWith({int id, String ip}) {
    return IdIp(id ?? this.id, ip ?? this.ip);
  }
}

class DigitalOcean {
  final Config config;
  final http.Client client;

  DigitalOcean(this.config)
      : client = BearerClient(config.doAuthToken, http.Client());

  PublicSuffix getDomain(String domain) {
    return PublicSuffix(Uri.parse('https://' + domain));
  }

  Future<IdIp> getRecord(String domain) async {
    final suffix = getDomain(domain);

    final url = Uri.parse('$_baseUrl${suffix.domain}/records')
        .replace(queryParameters: {'type': 'A', 'name': domain});

    final resp = await client.get(url);
    if (resp.statusCode != 200) {
      throw HttpError('Could not get DNS records', 500);
    }

    final _json = json.decode(resp.body);
    final total = _json['meta']['total'];
    if (total > 1) {
      throw HttpError(
          'More than one DNS A records found for domain $domain', 400);
    }
    if (total == 1) {
      final record = _json['domain_records'][0];
      return IdIp(record['id'], record['data']);
    }
    return null;
  }

  Future<bool> createRecord(String domain, String ip) async {
    final suffix = getDomain(domain);

    final url = '$_baseUrl${suffix.domain}/records';
    final body = {
      'type': 'A',
      'name': suffix.subdomain,
      'data': ip,
      'ttl': config.ttl,
    };

    final resp = await client.post(url, body: json.encode(body), headers: {
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
    });

    if (resp.statusCode != HttpStatus.created) {
      config.logger.e('Could not create DNS record', '${resp.statusCode} ${resp.body}');
      throw HttpError('Could not create DNS record', 500);
    }

    return true;
  }

  Future<bool> updateRecord(String domain, IdIp idIp) async {
    final suffix = getDomain(domain);

    final url = '$_baseUrl${suffix.domain}/records/${idIp.id}';
    final body = {'data': idIp.ip};

    final resp = await client.put(url, body: body);

    if (resp.statusCode != HttpStatus.ok) {
      throw HttpError('Could not update DNS record', 500);
    }

    return true;
  }
}
