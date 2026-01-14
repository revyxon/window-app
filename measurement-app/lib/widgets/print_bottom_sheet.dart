import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../models/customer.dart';
import '../models/window.dart';
import '../services/print_service.dart';

class PrintBottomSheet extends StatelessWidget {
  final Customer customer;
  final List<Window> windows;

  const PrintBottomSheet({
    super.key,
    required this.customer,
    required this.windows,
  });

  Future<void> _print(BuildContext context, bool isInvoice) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await PrintService.printDocument(
        customer: customer,
        windows: windows,
        isInvoice: isInvoice,
      );
    } finally {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // Close loading
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FluentIcons.print_24_regular,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Print Document',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Measurement Card
            _buildOptionCard(
              context,
              icon: FluentIcons.ruler_24_filled,
              iconBgColor: Colors.blue.shade50,
              iconColor: Colors.blue.shade600,
              title: 'Measurement Details',
              subtitle: 'Window dimensions and area',
              onTap: () => _print(context, false), // Measurement
            ),

            const SizedBox(height: 16),

            // Invoice Card
            _buildOptionCard(
              context,
              icon: FluentIcons.receipt_24_filled,
              iconBgColor: Colors.blue.shade50,
              iconColor: Colors.blue.shade600,
              title: 'Proforma Invoice',
              subtitle: 'Professional invoice with bank details',
              onTap: () => _print(context, true), // Invoice
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

void showPrintBottomSheet(
  BuildContext context,
  Customer customer,
  List<Window> windows,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        PrintBottomSheet(customer: customer, windows: windows),
  );
}
