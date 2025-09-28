import 'package:flutter/material.dart';

class PullToRefreshList extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final bool enabled;
  final Color? refreshIndicatorColor;
  final String? refreshMessage;

  const PullToRefreshList({
    super.key,
    required this.onRefresh,
    required this.child,
    this.enabled = true,
    this.refreshIndicatorColor,
    this.refreshMessage,
  });

  @override
  State<PullToRefreshList> createState() => _PullToRefreshListState();
}

class _PullToRefreshListState extends State<PullToRefreshList> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    if (!widget.enabled || _isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await widget.onRefresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.refreshMessage ?? 'Updated successfully'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void triggerRefresh() {
    _refreshIndicatorKey.currentState?.show();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _handleRefresh,
      color: widget.refreshIndicatorColor ?? Theme.of(context).primaryColor,
      child: widget.child,
    );
  }
}

// Enhanced List View with Pull-to-Refresh and Empty State
class SmartListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<void> Function()? onRefresh;
  final Widget? emptyState;
  final Widget? loadingState;
  final Widget? errorState;
  final bool isLoading;
  final String? error;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;
  final bool enablePullToRefresh;

  const SmartListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onRefresh,
    this.emptyState,
    this.loadingState,
    this.errorState,
    this.isLoading = false,
    this.error,
    this.scrollController,
    this.padding,
    this.enablePullToRefresh = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    // Determine what to show
    if (isLoading && items.isEmpty) {
      content = loadingState ?? _buildDefaultLoadingState();
    } else if (error != null) {
      content = errorState ?? _buildDefaultErrorState(context);
    } else if (items.isEmpty) {
      content = emptyState ?? _buildDefaultEmptyState();
    } else {
      content = ListView.builder(
        controller: scrollController,
        padding: padding,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return itemBuilder(context, items[index], index);
        },
      );
    }

    // Wrap with pull-to-refresh if enabled
    if (enablePullToRefresh && onRefresh != null) {
      return PullToRefreshList(
        onRefresh: onRefresh!,
        enabled: !isLoading,
        child: content,
      );
    }

    return content;
  }

  Widget _buildDefaultLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'An error occurred while loading data',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRefresh,
                child: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No items found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'There are no items to display at the moment',
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
