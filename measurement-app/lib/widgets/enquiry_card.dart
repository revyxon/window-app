import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:intl/intl.dart';
import '../models/enquiry.dart';
import '../utils/app_colors.dart';
import '../utils/haptics.dart';
import 'glass_container.dart';

class EnquiryCard extends StatelessWidget {
  final Enquiry enquiry;
  final VoidCallback? onTap;

  const EnquiryCard({super.key, required this.enquiry, this.onTap});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'converted':
        return Colors.green;
      case 'dismissed':
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.withValues(alpha: 0.1);
      case 'converted':
        return Colors.green.withValues(alpha: 0.1);
      case 'dismissed':
        return Colors.grey.withValues(alpha: 0.1);
      default:
        return AppColors.primary.withValues(alpha: 0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, y').format(enquiry.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        onTap: () {
          Haptics.light();
          onTap?.call();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name + Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    enquiry.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusBgColor(enquiry.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        enquiry.status.toLowerCase() == 'converted'
                            ? FluentIcons.checkmark_circle_24_filled
                            : FluentIcons.clock_24_regular,
                        size: 14,
                        color: _getStatusColor(enquiry.status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        enquiry.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(enquiry.status),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Location & Date Row
            Row(
              children: [
                if (enquiry.location != null &&
                    enquiry.location!.isNotEmpty) ...[
                  const Icon(
                    FluentIcons.location_24_regular,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      enquiry.location!,
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                Text(
                  dateStr,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),

            // Requirements Preview (if available)
            if (enquiry.requirements != null &&
                enquiry.requirements!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                enquiry.requirements!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
            ],

            // Phone (if available)
            if (enquiry.phone != null && enquiry.phone!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    FluentIcons.phone_24_regular,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    enquiry.phone!,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
