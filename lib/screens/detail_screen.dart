import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/country.dart';
import '../providers/country_provider.dart';
import '../services/country_service.dart';

class DetailScreen extends StatefulWidget {
  final Country country;
  const DetailScreen({super.key, required this.country});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final CountryService _service = CountryService();
  List<Country> _borders = [];
  bool _loadingBorders = true;

  @override
  void initState() {
    super.initState();
    _loadBorders();
  }

  Future<void> _loadBorders() async {
    final list = await _service.getBorders(widget.country.name);
    setState(() {
      _borders = list;
      _loadingBorders = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CountryProvider>();
    final c = widget.country;
    return Scaffold(
      appBar: AppBar(
        title: Text(c.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'flag_${c.alpha3Code}',
              child: c.flagPng != null
                  ? Image.network(c.flagPng!, height: 160)
                  : c.flagSvg != null
                      ? Image.network(c.flagSvg!, height: 160)
                      : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Capital: ${c.capital ?? ''}'),
                      Text('Region: ${c.region ?? ''}'),
                      Text('Subregion: ${c.subregion ?? ''}'),
                      Text('Population: ${c.population ?? 0}'),
                      Text('Languages: ${c.languages.join(', ')}'),
                      Text('Currencies: ${c.currencies.join(', ')}'),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(provider.isFavorite(c) ? Icons.favorite : Icons.favorite_border),
                  color: provider.isFavorite(c) ? Colors.red : null,
                  onPressed: () => provider.toggleFavorite(c),
                )
              ],
            ),
            const SizedBox(height: 16),
            Text('Borders'),
            const SizedBox(height: 8),
            if (_loadingBorders)
              const Center(child: CircularProgressIndicator())
            else if (_borders.isEmpty)
              const Text('No borders')
            else
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _borders.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final b = _borders[i];
                    return Column(
                      children: [
                        Expanded(
                          child: b.flagPng != null
                              ? Image.network(b.flagPng!, width: 120)
                              : b.flagSvg != null
                                  ? Image.network(b.flagSvg!, width: 120)
                                  : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 8),
                        Text(b.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}