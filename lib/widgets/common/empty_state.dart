import 'package:flutter/material.dart';

enum EmptyStateType { noProjects, noBids, noMessages, noResults, noInternet }

class EmptyState extends StatelessWidget {
  final EmptyStateType type;
  final String? customTitle;
  final String? customMessage;
  final String? customActionText;
  final VoidCallback? onAction;
  final Widget? customIcon;

  const EmptyState({
    super.key,
    required this.type,
    this.customTitle,
    this.customMessage,
    this.customActionText,
    this.onAction,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getEmptyStateConfig();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: config.iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  customIcon ??
                  Icon(config.icon, size: 64, color: config.iconColor),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              customTitle ?? config.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              customMessage ?? config.message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            // Action Button
            if (onAction != null || config.hasDefaultAction) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction ?? config.defaultAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: config.iconColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  customActionText ?? config.actionText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  EmptyStateConfig _getEmptyStateConfig() {
    switch (type) {
      case EmptyStateType.noProjects:
        return EmptyStateConfig(
          icon: Icons.work_outline,
          iconColor: Colors.blue,
          title: "No Projects Yet",
          message:
              "You haven't posted any projects yet.\nStart by posting your first project to connect with contractors.",
          actionText: "Post Project",
          hasDefaultAction: false,
        );

      case EmptyStateType.noBids:
        return EmptyStateConfig(
          icon: Icons.gavel_outlined,
          iconColor: Colors.orange,
          title: "No Bids Yet",
          message:
              "You haven't placed any bids yet.\nBrowse available projects and place your first bid.",
          actionText: "Browse Projects",
          hasDefaultAction: false,
        );

      case EmptyStateType.noMessages:
        return EmptyStateConfig(
          icon: Icons.chat_bubble_outline,
          iconColor: Colors.green,
          title: "No Messages",
          message:
              "No conversations yet.\nStart chatting with clients or contractors to discuss projects.",
          actionText: "Start Conversation",
          hasDefaultAction: false,
        );

      case EmptyStateType.noResults:
        return EmptyStateConfig(
          icon: Icons.search_off,
          iconColor: Colors.grey,
          title: "No Results Found",
          message:
              "We couldn't find any results matching your search.\nTry adjusting your search terms or filters.",
          actionText: "Clear Filters",
          hasDefaultAction: false,
        );

      case EmptyStateType.noInternet:
        return EmptyStateConfig(
          icon: Icons.wifi_off,
          iconColor: Colors.red,
          title: "No Internet Connection",
          message:
              "Please check your internet connection and try again.\nMake sure you're connected to WiFi or mobile data.",
          actionText: "Try Again",
          hasDefaultAction: false,
        );
    }
  }
}

class EmptyStateConfig {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String actionText;
  final bool hasDefaultAction;
  final VoidCallback? defaultAction;

  EmptyStateConfig({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.actionText,
    this.hasDefaultAction = false,
    this.defaultAction,
  });
}

// Specialized Empty States for Common Use Cases
class NoProjectsEmptyState extends StatelessWidget {
  final VoidCallback? onPostProject;

  const NoProjectsEmptyState({super.key, this.onPostProject});

  @override
  Widget build(BuildContext context) {
    return EmptyState(type: EmptyStateType.noProjects, onAction: onPostProject);
  }
}

class NoBidsEmptyState extends StatelessWidget {
  final VoidCallback? onBrowseProjects;

  const NoBidsEmptyState({super.key, this.onBrowseProjects});

  @override
  Widget build(BuildContext context) {
    return EmptyState(type: EmptyStateType.noBids, onAction: onBrowseProjects);
  }
}

class NoSearchResultsEmptyState extends StatelessWidget {
  final VoidCallback? onClearFilters;
  final String? searchTerm;

  const NoSearchResultsEmptyState({
    super.key,
    this.onClearFilters,
    this.searchTerm,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      type: EmptyStateType.noResults,
      customMessage: searchTerm != null
          ? "No results found for '$searchTerm'.\nTry searching with different keywords."
          : null,
      onAction: onClearFilters,
    );
  }
}
