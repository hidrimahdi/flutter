import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/country.dart';

class CountryService {
  static const String baseUrl = 'https://www.apicountries.com';

  Future<http.Response> _getWithCors(Uri uri) async {
    if (!kIsWeb) {
      return http.get(uri).timeout(const Duration(seconds: 20));
    }
    final candidates = <Uri>[
      Uri.parse('https://cors.isomorphic-git.org/${uri.toString()}'),
      Uri.parse('https://api.allorigins.win/raw?url=${Uri.encodeComponent(uri.toString())}'),
    ];
    for (final u in candidates) {
      try {
        final res = await http.get(u).timeout(const Duration(seconds: 20));
        if (res.statusCode == 200) return res;
      } catch (_) {}
    }
    return http.Response('CORS proxy failed', 500);
  }

  Future<List<Country>> getAllCountries() async {
    final uri = Uri.parse('$baseUrl/countries');
    final res = await _getWithCors(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List;
      return data.map((e) => Country.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load countries');
  }

  Future<List<Country>> searchByName(String name) async {
    final uri = Uri.parse('$baseUrl/name/$name');
    final res = await _getWithCors(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List;
      return data.map((e) => Country.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Search failed');
  }

  Future<List<Country>> getBorders(String name) async {
    final uri = Uri.parse('$baseUrl/borders/$name');
    final res = await _getWithCors(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List;
      return data.map((e) => Country.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}