import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../providers/settings_provider.dart';
import '../ui/components/app_card.dart';
import '../ui/design_system.dart';
import '../ui/components/app_icon.dart';
import '../utils/haptics.dart';
import '../utils/fast_page_route.dart';
import '../screens/customer_detail_screen.dart';

/// Fixed green badge color - NOT theme dependent
const _badgeGreen = Color(0xFF10B981);

class CustomerCard extends StatelessWidget {
  final Customer customer;

  const CustomerCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        onPressed: () {
          if (settings.hapticFeedback) Haptics.light();
          Navigator.push(
            context,
            FastPageRoute(page: CustomerDetailScreen(customer: customer)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name + Final badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    customer.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (customer.isFinalMeasurement) _buildFinalBadge(theme),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Location
            Row(
              children: [
                AppIcon(
                  AppIconType.location,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    customer.location,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Windows Count with "X windows" text
                    AppIcon(
                      AppIconType.window,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${customer.windowCount} windows',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),

                    // SqFt
                    AppIcon(
                      AppIconType.measurement,
                      size: 18,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${customer.totalSqFt.toStringAsFixed(1)} sqft',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),

                // Framework Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Text(
                    customer.framework,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Fixed green badge - NOT theme dependent
  Widget _buildFinalBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _badgeGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 14, color: _badgeGreen),
          const SizedBox(width: 4),
          Text(
            'Final',
            style: theme.textTheme.labelSmall?.copyWith(
              color: _badgeGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
