import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/enquiry.dart';
import '../providers/settings_provider.dart';
import '../ui/components/app_card.dart';
import '../ui/components/app_icon.dart';
import '../ui/design_system.dart';
import '../utils/haptics.dart';

/// Fixed status colors - NOT theme dependent
const _pendingColor = Color(0xFFF59E0B);
const _convertedColor = Color(0xFF10B981);
const _dismissedColor = Color(0xFF6B7280);

class EnquiryCard extends StatelessWidget {
  final Enquiry enquiry;
  final VoidCallback? onTap;

  const EnquiryCard({super.key, required this.enquiry, this.onTap});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _pendingColor;
      case 'converted':
        return _convertedColor;
      case 'dismissed':
        return _dismissedColor;
      default:
        return _pendingColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final dateStr = DateFormat('MMM d, y').format(enquiry.createdAt);
    final statusColor = _getStatusColor(enquiry.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        onPressed: () {
          if (settings.hapticFeedback) Haptics.light();
          onTap?.call();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    enquiry.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusBadge(theme, statusColor),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Location
            if (enquiry.location != null && enquiry.location!.isNotEmpty)
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
                      enquiry.location!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.md),

            // Bottom Row: Date + Phone + Windows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Date info
                Row(
                  children: [
                    AppIcon(
                      AppIconType.calendar,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      dateStr,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    if (enquiry.phone != null && enquiry.phone!.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.lg),
                      AppIcon(
                        AppIconType.phone,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        enquiry.phone!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),

                // Right: Expected Windows Pill
                if (enquiry.expectedWindows != null &&
                    enquiry.expectedWindows!.isNotEmpty)
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
                      enquiry.expectedWindows!,
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

  Widget _buildStatusBadge(ThemeData theme, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        enquiry.status.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
