import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import '../models/customer.dart';
import '../models/window.dart';
import '../services/print_service.dart';
import 'package:intl/intl.dart';

class ShareBottomSheet extends StatelessWidget {
  final Customer customer;
  final List<Window> windows;

  const ShareBottomSheet({
    super.key,
    required this.customer,
    required this.windows,
  });

  String _generateShareText() {
    final buffer = StringBuffer();
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}-${months[now.month - 1]}-${now.year}';

    buffer.writeln('*DD UPVC WINDOWS SYSTEM*');
    buffer.writeln('================================');
    buffer.writeln();

    buffer.writeln('*Customer*   : ${customer.name}');
    buffer.writeln('*Location*   : ${customer.location}');
    buffer.writeln('*Date*       : $dateStr');
    buffer.writeln();

    buffer.writeln('*Framework*  : ${customer.framework}');
    buffer.writeln('*Glass*      : ${customer.glassType ?? "-"}');
    buffer.writeln(
      '*Finalized*  : ${customer.isFinalMeasurement ? "Yes" : "No"}',
    );
    buffer.writeln();

    buffer.writeln('================================');
    buffer.writeln('*WINDOW DETAILS*');
    buffer.writeln('================================');

    int index = 1;
    for (final window in windows) {
      if (window.isOnHold) continue;

      final wLabel = 'W$index';
      String dimen;
      if (window.width2 != null && window.width2! > 0) {
        dimen =
            '(${window.width.toStringAsFixed(0)}+${window.width2!.toStringAsFixed(0)})x${window.height.toStringAsFixed(0)}';
      } else {
        dimen =
            '${window.width.toStringAsFixed(0)}x${window.height.toStringAsFixed(0)}';
      }

      String typeCode = window.type;
      if (window.customName != null && window.customName!.isNotEmpty) {
        typeCode = window.customName!;
      }

      final sqFt = '${window.sqFt.toStringAsFixed(2)} Sq.Ft';

      buffer.write(wLabel.padRight(3));
      buffer.write('| $dimen'.padRight(14));
      buffer.write('| $typeCode'.padRight(8));
      buffer.writeln('| $sqFt');

      index++;
    }

    final activeWindows = windows.where((w) => !w.isOnHold).toList();
    final totalSqFt = activeWindows.fold(0.0, (sum, w) => sum + w.sqFt);
    final rate = customer.ratePerSqft ?? 0.0;
    final amount = totalSqFt * rate;

    final inrFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'Rs.',
      decimalDigits: 0,
    );

    buffer.writeln();
    buffer.writeln('================================');
    buffer.writeln('*Total Area* : ${totalSqFt.toStringAsFixed(2)} Sq.Ft');
    buffer.writeln('*Rate*       : Rs.${rate.toStringAsFixed(0)} / Sq.Ft');
    buffer.writeln('*Amount*     : ${inrFormat.format(amount)}');

    return buffer.toString();
  }

  Future<void> _shareText(BuildContext context, bool viaWhatsApp) async {
    final text = _generateShareText();
    if (viaWhatsApp) {
      final encodedText = Uri.encodeComponent(text);
      final url = Uri.parse('whatsapp://send?text=$encodedText');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await SharePlus.instance.share(ShareParams(text: text));
      }
    } else {
      await SharePlus.instance.share(ShareParams(text: text));
    }
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _sharePdf(BuildContext context, bool isInvoice) async {
    unawaited(
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      await PrintService.shareDocument(
        customer: customer,
        windows: windows,
        isInvoice: isInvoice,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing PDF: $e')));
      }
    } finally {
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shareText = _generateShareText();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const Text(
                'Share Measurement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                constraints: const BoxConstraints(maxHeight: 180),
                child: SingleChildScrollView(
                  child: Text(
                    shareText,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFF374151),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGlassActionBtn(
                    icon: Icons.copy_rounded,
                    label: 'Copy',
                    iconColor: Colors.blue.shade700,
                    fillColor: Colors.blue.shade50,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: shareText));
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  ),
                  _buildGlassActionBtn(
                    icon: Icons.message_rounded,
                    label: 'WhatsApp',
                    iconColor: Colors.green.shade600,
                    fillColor: Colors.green.shade50,
                    onTap: () => _shareText(context, true),
                  ),
                  _buildGlassActionBtn(
                    icon: Icons.share_rounded,
                    label: 'Share',
                    iconColor: Colors.blue.shade600,
                    fillColor: Colors.blue.shade50,
                    onTap: () => _shareText(context, false),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Or share as PDF',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildOutlineBtn(
                      icon: Icons.straighten_rounded,
                      label: 'Measurement',
                      color: Colors.blue.shade700,
                      onTap: () => _sharePdf(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOutlineBtn(
                      icon: Icons.receipt_long_rounded,
                      label: 'Invoice',
                      color: Colors.blue.shade700,
                      onTap: () => _sharePdf(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassActionBtn({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color fillColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlineBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showShareBottomSheet(
  BuildContext context,
  Customer customer,
  List<Window> windows,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        ShareBottomSheet(customer: customer, windows: windows),
  );
}
