import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/country.dart';
import '../services/country_service.dart';

enum SortOption { nameAsc, nameDesc, populationAsc, populationDesc }

class CountryProvider extends ChangeNotifier {
  final CountryService _service = CountryService();
  List<Country> _countries = [];
  List<Country> _filtered = [];
  Set<String> _favorites = {};
  bool _loading = false;
  String? _error;
  String _query = '';
  SortOption _sort = SortOption.nameAsc;

  List<Country> get countries => _filtered;
  bool get isLoading => _loading;
  String? get error => _error;
  Set<String> get favorites => _favorites;
  SortOption get sort => _sort;

  Future<void> init() async {
    await _loadFavorites();
    await fetchCountries();
  }

  Future<void> fetchCountries() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _countries = await _service.getAllCountries();
      _applyQueryAndSort();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchCountries();
  }

  void setSearchQuery(String q) {
    _query = q;
    _applyQueryAndSort();
    notifyListeners();
  }

  void setSort(SortOption option) {
    _sort = option;
    _applyQueryAndSort();
    notifyListeners();
  }

  void _applyQueryAndSort() {
    _filtered = _countries.where((c) {
      if (_query.isEmpty) return true;
      return c.name.toLowerCase().contains(_query.toLowerCase()) ||
          (c.capital ?? '').toLowerCase().contains(_query.toLowerCase());
    }).toList();
    switch (_sort) {
      case SortOption.nameAsc:
        _filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        _filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.populationAsc:
        _filtered.sort((a, b) => (a.population ?? 0).compareTo(b.population ?? 0));
        break;
      case SortOption.populationDesc:
        _filtered.sort((a, b) => (b.population ?? 0).compareTo(a.population ?? 0));
        break;
    }
  }

  bool isFavorite(Country c) => _favorites.contains(c.alpha3Code);

  Future<void> toggleFavorite(Country c) async {
    if (isFavorite(c)) {
      _favorites.remove(c.alpha3Code);
    } else {
      _favorites.add(c.alpha3Code);
    }
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('favorites') ?? [];
    _favorites = list.toSet();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites.toList());
  }
}