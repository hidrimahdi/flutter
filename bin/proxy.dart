import 'dart:io';

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8787);
  await for (final req in server) {
    if (req.method == 'OPTIONS') {
      _sendCors(req, 204, '');
      continue;
    }
    if (req.method != 'GET' && req.method != 'HEAD') {
      _sendCors(req, 405, '');
      continue;
    }
    final upstream = Uri.parse('https://www.apicountries.com${req.uri.path}${req.uri.hasQuery ? '?${req.uri.query}' : ''}');
    try {
      final client = HttpClient();
      final ureq = await client.getUrl(upstream);
      final ures = await ureq.close();
      final bytes = await ures.fold<List<int>>(<int>[], (p, e) => p..addAll(e));
      final contentType = ures.headers.contentType?.toString() ?? 'application/json';
      _sendCors(req, ures.statusCode, bytes, headers: {'content-type': contentType});
    } catch (_) {
      _sendCors(req, 502, '');
    }
  }
}

void _sendCors(HttpRequest req, int status, Object body, {Map<String, String>? headers}) {
  req.response.statusCode = status;
  req.response.headers.set('Access-Control-Allow-Origin', '*');
  req.response.headers.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
  req.response.headers.set('Access-Control-Allow-Headers', '*');
  headers?.forEach((k, v) => req.response.headers.set(k, v));
  if (body is String) {
    req.response.write(body);
  } else if (body is List<int>) {
    req.response.add(body);
  }
  req.response.close();
}