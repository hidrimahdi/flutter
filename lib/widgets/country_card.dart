import 'package:flutter/material.dart';
import '../models/country.dart';

class CountryCard extends StatelessWidget {
  final Country country;
  final bool favorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const CountryCard({
    super.key,
    required this.country,
    required this.favorite,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Hero(
                  tag: 'flag_${country.alpha3Code}',
                  child: country.flagPng != null
                      ? Image.network(country.flagPng!, fit: BoxFit.cover)
                      : country.flagSvg != null
                          ? Image.network(country.flagSvg!, fit: BoxFit.cover)
                          : const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 8),
              Text(country.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(country.capital ?? ''),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
                    color: favorite ? Colors.red : null,
                    onPressed: onFavorite,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}