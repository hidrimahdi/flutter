import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country.dart';

class CountryService {
  static const String baseUrl = 'https://www.apicountries.com';

  Future<List<Country>> getAllCountries() async {
    final uri = Uri.parse('$baseUrl/countries');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List;
      return data.map((e) => Country.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load countries');
  }

  Future<List<Country>> searchByName(String name) async {
    final uri = Uri.parse('$baseUrl/name/$name');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List;
      return data.map((e) => Country.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Search failed');
  }

  Future<List<Country>> getBorders(String name) async {
    final uri = Uri.parse('$baseUrl/borders/$name');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List;
      return data.map((e) => Country.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}