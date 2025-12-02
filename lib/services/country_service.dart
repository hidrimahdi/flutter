import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import '../models/country.dart';

class CountryService {
  static const String baseUrl = 'https://www.apicountries.com';

  Future<http.Response> _get(Uri uri) {
    return http.get(uri).timeout(const Duration(seconds: 20));
  }

  String _webBase() => 'http://localhost:8787';

  Future<List<Country>> _loadLocalCountries() async {
    final raw = await rootBundle.loadString('assets/countries.json');
    final data = json.decode(raw) as List;
    return data.map((e) => Country.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Country>> getAllCountries() async {
    final uri = kIsWeb ? Uri.parse('${_webBase()}/countries') : Uri.parse('$baseUrl/countries');
    try {
      final res = await _get(uri);
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List;
        return data.map((e) => Country.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return _loadLocalCountries();
  }

  Future<List<Country>> searchByName(String name) async {
    final uri = kIsWeb ? Uri.parse('${_webBase()}/name/$name') : Uri.parse('$baseUrl/name/$name');
    try {
      final res = await _get(uri);
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List;
        return data.map((e) => Country.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    final all = await _loadLocalCountries();
    return all.where((c) => c.name.toLowerCase().contains(name.toLowerCase()) ||
        (c.capital ?? '').toLowerCase().contains(name.toLowerCase())).toList();
  }

  Future<List<Country>> getBorders(String name) async {
    final uri = kIsWeb ? Uri.parse('${_webBase()}/borders/$name') : Uri.parse('$baseUrl/borders/$name');
    try {
      final res = await _get(uri);
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List;
        return data.map((e) => Country.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
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