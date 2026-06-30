import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/providers/quote_provider.dart';
import '../../../../core/models/quote_model.dart';
import '../../../../core/widgets/skeleton_loader.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quoteProvider.notifier).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final state = ref.watch(quoteProvider);

    // Collect unique categories for filter chips
    final categories = ['All', ...{...state.favorites.map((f) => f.category)}];

    final filteredFavorites = _selectedFilter == 'All'
        ? state.favorites
        : state.favorites.where((f) => f.category == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: Text('${state.favorites.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              avatar: Icon(Icons.favorite_rounded,
                  size: 16, color: cs.error),
              visualDensity: VisualDensity.compact,
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category filter chips
          if (state.favorites.isNotEmpty)
            SizedBox(
              height: 52,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = categories[i];
                  final isSelected = _selectedFilter == cat;
                  return FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = cat),
                    showCheckmark: false,
                  );
                },
              ),
            ),

          Expanded(
            child: state.favorites.isEmpty && state.isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 4,
                    itemBuilder: (_, __) => const QuoteListTileSkeleton(),
                  )
                : filteredFavorites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite_border_rounded,
                                size: 64, color: cs.outline),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFilter == 'All'
                                  ? 'No favorites yet'
                                  : 'None in "$_selectedFilter"',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(color: cs.outline),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredFavorites.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final quote = filteredFavorites[index];
                          return _FavoriteCard(quote: quote);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteCard extends ConsumerWidget {
  final QuoteModel quote;

  const _FavoriteCard({required this.quote});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category chip
            Chip(
              label: Text(quote.category),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              labelStyle: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: 12),
            Text(
              '"${quote.quote}"',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Share.share(
                      '"${quote.quote}"\n\n#QuoteOfTheDay'),
                ),
                IconButton(
                  icon: Icon(Icons.favorite_rounded, color: cs.error),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => ref
                      .read(quoteProvider.notifier)
                      .toggleFavorite(quote),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
