import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/country_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/country_card.dart';
import '../screens/detail_screen.dart';
import '../models/country.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CountryProvider>();
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Search countries',
            border: InputBorder.none,
          ),
          onChanged: provider.setSearchQuery,
        ),
        actions: [
          IconButton(
            icon: Icon(theme.mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => theme.toggle(),
          ),
          PopupMenuButton<SortOption>(
            onSelected: provider.setSort,
            itemBuilder: (context) => const [
              PopupMenuItem(value: SortOption.nameAsc, child: Text('Name ↑')),
              PopupMenuItem(value: SortOption.nameDesc, child: Text('Name ↓')),
              PopupMenuItem(value: SortOption.populationAsc, child: Text('Population ↑')),
              PopupMenuItem(value: SortOption.populationDesc, child: Text('Population ↓')),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        child: Builder(
          builder: (context) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(child: Text(provider.error!));
            }
            final list = provider.countries;
            if (list.isEmpty) {
              return const Center(child: Text('No countries'));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final c = list[i];
                return CountryCard(
                  country: c,
                  favorite: provider.isFavorite(c),
                  onFavorite: () => provider.toggleFavorite(c),
                  onTap: () {
                    Navigator.of(context).push(_buildRoute(c));
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  PageRoute _buildRoute(Country c) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => DetailScreen(country: c),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}