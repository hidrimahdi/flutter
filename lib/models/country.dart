class Country {
  final String name;
  final String? capital;
  final String alpha2Code;
  final String alpha3Code;
  final String? region;
  final String? subregion;
  final int? population;
  final String? flagSvg;
  final String? flagPng;
  final List<String> currencies;
  final List<String> languages;
  final List<String> borders;
  final String? cioc;

  Country({
    required this.name,
    required this.capital,
    required this.alpha2Code,
    required this.alpha3Code,
    required this.region,
    required this.subregion,
    required this.population,
    required this.flagSvg,
    required this.flagPng,
    required this.currencies,
    required this.languages,
    required this.borders,
    required this.cioc,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    final flags = json['flags'] as Map<String, dynamic>?;
    final currenciesJson = (json['currencies'] as List?) ?? [];
    final languagesJson = (json['languages'] as List?) ?? [];
    final bordersJson = (json['borders'] as List?) ?? [];
    return Country(
      name: json['name'] ?? '',
      capital: json['capital'],
      alpha2Code: json['alpha2Code'] ?? '',
      alpha3Code: json['alpha3Code'] ?? '',
      region: json['region'],
      subregion: json['subregion'],
      population: json['population'],
      flagSvg: flags != null ? flags['svg'] as String? : json['flag'] as String?,
      flagPng: flags != null ? flags['png'] as String? : null,
      currencies: currenciesJson
          .map((e) => (e as Map<String, dynamic>)['name'] as String?)
          .whereType<String>()
          .toList(),
      languages: languagesJson
          .map((e) => (e as Map<String, dynamic>)['name'] as String?)
          .whereType<String>()
          .toList(),
      borders: bordersJson.whereType<String>().toList(),
      cioc: json['cioc'],
    );
  }
}