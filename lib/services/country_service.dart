import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
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

  Future<List<Country>> _loadLocalCountries() async {
    final raw = await rootBundle.loadString('assets/countries.json');
    final data = json.decode(raw) as List;
    return data.map((e) => Country.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Country>> getAllCountries() async {
    final uri = Uri.parse('$baseUrl/countries');
    final res = await _getWithCors(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List;
      return data.map((e) => Country.fromJson(e as Map<String, dynamic>)).toList();
    }
    return _loadLocalCountries();
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
    final all = await _loadLocalCountries();
    final current = all.firstWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
      orElse: () => Country(
        name: name,
        capital: '',
        alpha2Code: '',
        alpha3Code: '',
        region: '',
        subregion: '',
        population: 0,
        flagSvg: null,
        flagPng: null,
        currencies: const [],
        languages: const [],
        borders: const [],
        cioc: '',
      ),
    );
    if (current.borders.isEmpty) return [];
    final codes = current.borders.toSet();
    return all.where((c) => codes.contains(c.alpha3Code)).toList();
  }
}