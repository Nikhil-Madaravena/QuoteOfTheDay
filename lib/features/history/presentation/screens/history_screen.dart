import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/quote_provider.dart';
import '../../../../core/models/quote_model.dart';
import '../../../../core/widgets/skeleton_loader.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quoteProvider.notifier).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final state = ref.watch(quoteProvider);

    final filteredHistory = state.history.where((q) {
      if (_searchQuery.isEmpty) return true;
      final lq = _searchQuery.toLowerCase();
      return q.quote.toLowerCase().contains(lq) ||
          q.author.toLowerCase().contains(lq) ||
          q.category.toLowerCase().contains(lq);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchBar(
              hintText: 'Search quotes, authors...',
              leading: const Icon(Icons.search_rounded),
              onChanged: (val) => setState(() => _searchQuery = val),
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerHighest),
            ),
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
                          size: 64, color: cs.outline),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No history yet'
                            : 'No results found',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: cs.outline),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredHistory.length,
                  itemBuilder: (context, index) {
                    final quote = filteredHistory[index];
                    return _HistoryTile(quote: quote, index: index);
                  },
                ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final QuoteModel quote;
  final int index;

  const _HistoryTile({required this.quote, required this.index});

  String _relativeDate(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AnimatedContainer(
      duration: Duration(milliseconds: 100 + index * 30),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.format_quote_rounded,
              color: cs.onPrimaryContainer),
        ),
        title: Text(
          '"${quote.quote}"',
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w500),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Chip(
                label: Text(quote.category),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                labelStyle: theme.textTheme.labelSmall,
              ),
              const SizedBox(width: 8),
              Text('— ${quote.author}',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: cs.primary)),
            ],
          ),
        ),
        trailing: Text(
          _relativeDate(quote.date),
          style: theme.textTheme.labelSmall
              ?.copyWith(color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}
