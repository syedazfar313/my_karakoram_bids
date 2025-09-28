import 'package:flutter/material.dart';
import 'dart:async';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String) onSearch;
  final Function(String)? onChanged;
  final VoidCallback? onFilterTap;
  final String? initialValue;
  final bool showFilterButton;
  final Duration debounceTime;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;

  const CustomSearchBar({
    super.key,
    required this.hintText,
    required this.onSearch,
    this.onChanged,
    this.onFilterTap,
    this.initialValue,
    this.showFilterButton = true,
    this.debounceTime = const Duration(milliseconds: 500),
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  Timer? _debounceTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _hasText = widget.initialValue?.isNotEmpty ?? false;

    _controller.addListener(() {
      final hasText = _controller.text.isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }

      // Call onChanged immediately
      widget.onChanged?.call(_controller.text);

      // Debounced search
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.debounceTime, () {
        widget.onSearch(_controller.text);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                  prefixIcon:
                      widget.prefixIcon ??
                      Icon(Icons.search, color: Colors.grey.shade600, size: 22),
                  suffixIcon: _hasText
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: widget.enabled ? _clearSearch : null,
                        )
                      : widget.suffixIcon,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 16),
                textInputAction: TextInputAction.search,
                onSubmitted: widget.enabled ? widget.onSearch : null,
              ),
            ),
          ),

          // Filter button
          if (widget.showFilterButton) ...[
            const SizedBox(width: 12),
            Material(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(25),
              child: InkWell(
                onTap: widget.enabled ? widget.onFilterTap : null,
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  child: const Icon(Icons.tune, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Quick Search Suggestions
class SearchSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTap;
  final String currentQuery;

  const SearchSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
    required this.currentQuery,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            dense: true,
            leading: const Icon(Icons.search, color: Colors.grey, size: 20),
            title: _buildHighlightedText(suggestion, currentQuery),
            trailing: const Icon(
              Icons.north_west,
              color: Colors.grey,
              size: 16,
            ),
            onTap: () => onSuggestionTap(suggestion),
          );
        },
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(text);
    }

    final matches = query.toLowerCase();
    final textLower = text.toLowerCase();
    final startIndex = textLower.indexOf(matches);

    if (startIndex == -1) {
      return Text(text);
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87),
        children: [
          TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, startIndex + query.length),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          TextSpan(text: text.substring(startIndex + query.length)),
        ],
      ),
    );
  }
}

// Recent Searches Widget
class RecentSearches extends StatelessWidget {
  final List<String> recentSearches;
  final Function(String) onRecentSearchTap;
  final VoidCallback? onClearAll;

  const RecentSearches({
    super.key,
    required this.recentSearches,
    required this.onRecentSearchTap,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              if (onClearAll != null)
                TextButton(
                  onPressed: onClearAll,
                  child: const Text(
                    'Clear All',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recentSearches.length,
            itemBuilder: (context, index) {
              final search = recentSearches[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(search),
                  onPressed: () => onRecentSearchTap(search),
                  backgroundColor: Colors.grey.shade100,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
