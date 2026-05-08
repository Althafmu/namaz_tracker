import 'package:flutter/material.dart';

class ErrorViewWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool hasCachedData;

  const ErrorViewWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.hasCachedData = false,
  });

  String _getFriendlyMessage(String original) {
    final lower = original.toLowerCase();

    if (lower.contains('socket') || lower.contains('connection')) {
      return 'Check your internet connection';
    }
    if (lower.contains('timeout')) {
      return 'Taking too long. Try again';
    }
    if (lower.contains('401') || lower.contains('unauthorized')) {
      return 'Please log in again';
    }
    if (lower.contains('403') || lower.contains('forbidden')) {
      return "You don't have access to this group";
    }
    if (lower.contains('404') || lower.contains('not found')) {
      return 'Group not found';
    }
    if (lower.contains('500') || lower.contains('server error')) {
      return 'Server error. Try again later';
    }
    if (lower.contains('no such file') || lower.contains('not found')) {
      return 'Group not found';
    }

    return 'Unable to load dashboard';
  }

  @override
  Widget build(BuildContext context) {
    final friendlyMessage = _getFriendlyMessage(message);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasCachedData ? Icons.cloud_off_outlined : Icons.wifi_off,
              size: 64,
              color: Theme.of(context).colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              hasCachedData ? 'Offline' : "Couldn't load",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              friendlyMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (!hasCachedData) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
            if (hasCachedData) ...[
              const SizedBox(height: 16),
              Text(
                'Showing cached data from earlier',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}