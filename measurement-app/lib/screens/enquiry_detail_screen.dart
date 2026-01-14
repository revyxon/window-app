import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/enquiry.dart';
import '../providers/app_provider.dart';
import '../utils/app_colors.dart';
import '../utils/haptics.dart';
import '../widgets/glass_container.dart';
import '../widgets/premium_toast.dart';

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

  Future<void> _setReminder() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.enquiry.reminderDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          widget.enquiry.reminderDate ??
              DateTime.now().add(const Duration(hours: 1)),
        ),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.primary),
              timePickerTheme: TimePickerThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        final DateTime reminderDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() => _isUpdating = true);
        Haptics.medium();

        try {
          final updatedEnquiry = widget.enquiry.copyWith(
            reminderDate: reminderDateTime,
            updatedAt: DateTime.now(),
            syncStatus: 2,
          );

          await Provider.of<AppProvider>(
            context,
            listen: false,
          ).updateEnquiry(updatedEnquiry);

          if (mounted) {
            setState(() {
              _isUpdating = false;
            });
            ToastService.show(
              context,
              'Reminder set for ${DateFormat('MMM d, h:mm a').format(reminderDateTime)}',
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isUpdating = false);
            ToastService.show(
              context,
              'Failed to set reminder: $e',
              isError: true,
            );
          }
        }
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    if (_currentStatus == newStatus) return;

    setState(() => _isUpdating = true);
    Haptics.medium();

    try {
      final updatedEnquiry = widget.enquiry.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
        syncStatus: 2, // Updated
      );

      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).updateEnquiry(updatedEnquiry);

      if (mounted) {
        setState(() {
          _currentStatus = newStatus;
          _isUpdating = false;
        });
        ToastService.show(
          context,
          'Status updated to ${newStatus.toUpperCase()}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ToastService.show(context, 'Failed to update: $e', isError: true);
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ToastService.show(context, 'Could not launch dialer', isError: true);
      }
    }
  }

  Future<void> _deleteEnquiry() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Enquiry?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed && mounted) {
      try {
        if (widget.enquiry.id != null) {
          await Provider.of<AppProvider>(
            context,
            listen: false,
          ).deleteEnquiry(widget.enquiry.id!);
          if (mounted) {
            Navigator.pop(context); // Go back to list
            ToastService.show(context, 'Enquiry deleted');
          }
        } else {
          if (mounted) {
            ToastService.show(
              context,
              'Error: Invalid Enquiry ID',
              isError: true,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ToastService.show(context, 'Failed to delete: $e', isError: true);
        }
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'MMMM d, y • h:mm a',
    ).format(widget.enquiry.createdAt);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Enquiry Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            onPressed: _deleteEnquiry,
            tooltip: 'Delete Enquiry',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            GlassContainer(
              padding: const EdgeInsets.all(20),
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
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Status Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            _currentStatus,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _currentStatus.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(_currentStatus),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _isUpdating ? null : _setReminder,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.enquiry.reminderDate != null
                                ? Icons.notifications_active_outlined
                                : Icons.notifications_none_outlined,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.enquiry.reminderDate != null
                                ? DateFormat(
                                    'MMM d, h:mm a',
                                  ).format(widget.enquiry.reminderDate!)
                                : 'Set Reminder',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateStr,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions Row (Call, Edit) - simplified for now
            if (widget.enquiry.phone != null &&
                widget.enquiry.phone!.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _makePhoneCall(widget.enquiry.phone!),
                  icon: const Icon(Icons.call_rounded),
                  label: Text('Call ${widget.enquiry.phone}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            _buildSectionTitle('Details'),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.location_on_outlined,
              'Location',
              widget.enquiry.location ?? 'N/A',
            ),
            if (widget.enquiry.requirements != null)
              _buildDetailRow(
                Icons.assignment_outlined,
                'Requirements',
                widget.enquiry.requirements!,
              ),
            if (widget.enquiry.expectedWindows != null)
              _buildDetailRow(
                Icons.grid_view_rounded,
                'Expected Windows',
                widget.enquiry.expectedWindows!,
              ),
            if (widget.enquiry.notes != null)
              _buildDetailRow(
                Icons.note_alt_outlined,
                'Notes',
                widget.enquiry.notes!,
              ),

            const SizedBox(height: 32),
            _buildSectionTitle('Update Status'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatusButton('Pending', Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatusButton('Converted', Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatusButton('Dismissed', Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.black87, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String status, Color color) {
    final isSelected = _currentStatus.toLowerCase() == status.toLowerCase();

    return GestureDetector(
      onTap: _isUpdating ? null : () => _updateStatus(status.toLowerCase()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: _isUpdating && isSelected
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                status,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}
