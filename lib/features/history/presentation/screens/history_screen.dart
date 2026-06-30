import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/quote_provider.dart';
import '../../../../core/models/quote_model.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quoteProvider.notifier).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(quoteProvider);

    final categories = state.history.map((q) => q.category).toSet().toList()..sort();

    final filteredHistory = state.history.where((q) {
      final matchesSearch = _searchQuery.isEmpty ||
          q.quote.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          q.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == null || q.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('HISTORY',
            style: AppTypography.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.0,
              color: isDark ? AppColors.darkOnSurface : AppColors.black,
            )),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(categories.isNotEmpty ? 116 : 64),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: SearchBar(
                  hintText: 'Search quotes...',
                  hintStyle: WidgetStatePropertyAll(AppTypography.dmSans(
                    fontSize: 12,
                    color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500,
                  )),
                  leading: Icon(Icons.search_rounded,
                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500,
                      size: 18),
                  onChanged: (val) => setState(() => _searchQuery = val),
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(
                      isDark ? AppColors.darkSurfaceVariant : AppColors.grey100),
                ),
              ),
              if (categories.isNotEmpty)
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final cat = categories[i];
                      final isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() =>
                            _selectedCategory = isSelected ? null : cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accentGold
                                : (isDark ? AppColors.darkSurfaceVariant : AppColors.grey100),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accentGold
                                  : (isDark ? AppColors.borderDark : AppColors.grey200),
                            ),
                          ),
                          child: Text(
                            cat.toUpperCase(),
                            style: AppTypography.dmSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: isSelected
                                  ? AppColors.black
                                  : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      body: state.history.isEmpty && state.isLoading
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              itemBuilder: (_, __) => const QuoteListTileSkeleton(),
            )
          : filteredHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_rounded,
                          size: 40,
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey400),
                      const SizedBox(height: 20),
                      Text(
                        _searchQuery.isEmpty && _selectedCategory == null
                            ? 'NO HISTORY YET'
                            : 'NO RESULTS FOUND',
                        style: AppTypography.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey400,
                        ),
                      ),
                      if (_selectedCategory != null) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => setState(() => _selectedCategory = null),
                          child: Text('CLEAR FILTER',
                              style: AppTypography.dmSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: AppColors.accentGold,
                              )),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: filteredHistory.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: isDark ? AppColors.borderDark : AppColors.grey200,
                  ),
                  itemBuilder: (context, index) {
                    final quote = filteredHistory[index];
                    return _HistoryTile(quote: quote, index: index, isDark: isDark);
                  },
                ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final QuoteModel quote;
  final int index;
  final bool isDark;

  const _HistoryTile({required this.quote, required this.index, required this.isDark});

  String _relativeDate(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'TODAY';
    if (diff == 1) return 'YESTERDAY';
    return '\$diff DAYS AGO';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.lightImpact();
        Clipboard.setData(ClipboardData(text: '"${quote.quote}"'));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('COPIED TO CLIPBOARD')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  quote.category.toUpperCase(),
                  style: AppTypography.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                    color: isDark ? AppColors.accentGold : AppColors.grey500,
                  ),
                ),
                Text(
                  _relativeDate(quote.date),
                  style: AppTypography.dmSans(
                    fontSize: 9,
                    letterSpacing: 1.0,
                    color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '\u201C${quote.quote}\u201D',
              style: AppTypography.playfair(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.6,
                color: isDark ? AppColors.darkOnSurface : AppColors.black,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
