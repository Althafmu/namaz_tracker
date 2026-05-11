import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_button.dart';

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
    final c = AppColors.of(context);
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
              color: c.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              hasCachedData ? 'Offline' : "Couldn't load",
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              friendlyMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: c.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (!hasCachedData) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 160,
                child: NeoButton(
                  text: 'TRY AGAIN',
                  onPressed: onRetry,
                ),
              ),
            ],
            if (hasCachedData) ...[
              const SizedBox(height: 16),
              Text(
                'Showing cached data from earlier',
                style: AppTextStyles.bodySmall.copyWith(
                  color: c.textSecondary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 160,
                child: NeoButton(
                  text: 'REFRESH',
                  onPressed: onRetry,
                  color: c.surface,
                  textColor: c.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}