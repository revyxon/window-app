import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/enquiry.dart';
import '../providers/app_provider.dart';
import '../providers/settings_provider.dart';
import '../ui/components/app_card.dart';
import '../ui/components/app_icon.dart';
import '../ui/design_system.dart';
import '../utils/haptics.dart';
import '../widgets/premium_toast.dart';

/// Fixed status colors
const _pendingColor = Color(0xFFF59E0B);
const _convertedColor = Color(0xFF10B981);
const _dismissedColor = Color(0xFF6B7280);

class EnquiryDetailScreen extends StatefulWidget {
  final Enquiry enquiry;

  const EnquiryDetailScreen({super.key, required this.enquiry});

  @override
  State<EnquiryDetailScreen> createState() => _EnquiryDetailScreenState();
}

class _EnquiryDetailScreenState extends State<EnquiryDetailScreen> {
  late String _currentStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.enquiry.status;
  }

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

  Future<void> _updateStatus(String newStatus) async {
    if (_currentStatus == newStatus) return;
    final settings = context.read<SettingsProvider>();
    if (settings.hapticFeedback) Haptics.medium();
    setState(() => _isUpdating = true);

    try {
      final updated = widget.enquiry.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
        syncStatus: 2,
      );
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).updateEnquiry(updated);
      if (mounted) {
        setState(() {
          _currentStatus = newStatus;
          _isUpdating = false;
        });
        ToastService.show(context, 'Status updated');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ToastService.show(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _setReminder() async {
    final settings = context.read<SettingsProvider>();

    final date = await showDatePicker(
      context: context,
      initialDate: widget.enquiry.reminderDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        widget.enquiry.reminderDate ??
            DateTime.now().add(const Duration(hours: 1)),
      ),
    );
    if (time == null || !mounted) return;

    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (settings.hapticFeedback) Haptics.medium();
    setState(() => _isUpdating = true);

    try {
      final updated = widget.enquiry.copyWith(
        reminderDate: dt,
        updatedAt: DateTime.now(),
        syncStatus: 2,
      );
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).updateEnquiry(updated);
      if (mounted) {
        setState(() => _isUpdating = false);
        ToastService.show(
          context,
          'Reminder set for ${DateFormat('MMM d, h:mm a').format(dt)}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _delete() async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Delete Enquiry?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (ok && mounted && widget.enquiry.id != null) {
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).deleteEnquiry(widget.enquiry.id!);
      if (mounted) {
        Navigator.pop(context);
        ToastService.show(context, 'Enquiry deleted');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final dateStr = DateFormat(
      'EEEE, MMMM d, y',
    ).format(widget.enquiry.createdAt);
    final timeStr = DateFormat('h:mm a').format(widget.enquiry.createdAt);
    final statusColor = _getStatusColor(_currentStatus);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: AppIcon(AppIconType.back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Enquiry Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card: Name + Status + Date
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.enquiry.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _currentStatus.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      AppIcon(
                        AppIconType.calendar,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$dateStr • $timeStr',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Quick Actions: Call + Remind
            Row(
              children: [
                if (widget.enquiry.phone != null &&
                    widget.enquiry.phone!.isNotEmpty) ...[
                  Expanded(
                    child: _ActionButton(
                      icon: AppIconType.phone,
                      label: 'Call ${widget.enquiry.phone}',
                      color: _convertedColor,
                      onTap: () => _call(widget.enquiry.phone!),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: _ActionButton(
                    icon: widget.enquiry.reminderDate != null
                        ? AppIconType.notification
                        : AppIconType.notification,
                    label: widget.enquiry.reminderDate != null
                        ? DateFormat(
                            'MMM d, h:mm a',
                          ).format(widget.enquiry.reminderDate!)
                        : 'Set Reminder',
                    color: theme.colorScheme.primary,
                    onTap: _setReminder,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // Details Section
            Text(
              'Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                children: [
                  _DetailRow(
                    icon: AppIconType.location,
                    label: 'Location',
                    value: widget.enquiry.location ?? 'Not specified',
                  ),
                  if (widget.enquiry.requirements != null) ...[
                    Divider(
                      height: 28,
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.1,
                      ),
                    ),
                    _DetailRow(
                      icon: AppIconType.file,
                      label: 'Requirements',
                      value: widget.enquiry.requirements!,
                    ),
                  ],
                  if (widget.enquiry.expectedWindows != null) ...[
                    Divider(
                      height: 28,
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.1,
                      ),
                    ),
                    _DetailRow(
                      icon: AppIconType.window,
                      label: 'Expected Windows',
                      value: widget.enquiry.expectedWindows!,
                    ),
                  ],
                  if (widget.enquiry.notes != null) ...[
                    Divider(
                      height: 28,
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.1,
                      ),
                    ),
                    _DetailRow(
                      icon: AppIconType.edit,
                      label: 'Notes',
                      value: widget.enquiry.notes!,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Status Selector
            Text(
              'Update Status',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _StatusButton(
                    label: 'Pending',
                    color: _pendingColor,
                    isSelected: _currentStatus.toLowerCase() == 'pending',
                    isUpdating: _isUpdating,
                    onTap: () => _updateStatus('pending'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatusButton(
                    label: 'Converted',
                    color: _convertedColor,
                    isSelected: _currentStatus.toLowerCase() == 'converted',
                    isUpdating: _isUpdating,
                    onTap: () => _updateStatus('converted'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatusButton(
                    label: 'Dismissed',
                    color: _dismissedColor,
                    isSelected: _currentStatus.toLowerCase() == 'dismissed',
                    isUpdating: _isUpdating,
                    onTap: () => _updateStatus('dismissed'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final AppIconType icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final AppIconType icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: AppIcon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final bool isUpdating;
  final VoidCallback onTap;

  const _StatusButton({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.isUpdating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: isUpdating ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? color : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: isUpdating && isSelected
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
      ),
    );
  }
}
