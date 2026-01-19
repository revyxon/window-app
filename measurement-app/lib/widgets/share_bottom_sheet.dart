import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
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
    final dateStr = DateFormat('dd-MMM-yyyy').format(now);

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
    final theme = Theme.of(context);
    final shareText = _generateShareText();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.15,
                    ),
                  ),
                ),
                constraints: const BoxConstraints(maxHeight: 180),
                child: SingleChildScrollView(
                  child: Text(
                    shareText,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons - 2x2 grid in Enquiry style
              Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.copy_rounded,
                      label: 'Copy',
                      color: theme.colorScheme.primary,
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: shareText));
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.message_rounded,
                      label: 'WhatsApp',
                      color: const Color(0xFF10B981),
                      onTap: () => _shareText(context, true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.share_rounded,
                      label: 'Share',
                      color: theme.colorScheme.primary,
                      onTap: () => _shareText(context, false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.download_rounded,
                      label: 'Download TXT',
                      color: const Color(0xFFF59E0B),
                      onTap: () => _downloadTxt(context, shareText),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                'Or share as PDF',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.straighten_rounded,
                      label: 'Measurement PDF',
                      color: theme.colorScheme.primary,
                      onTap: () => _sharePdf(context, false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.receipt_long_rounded,
                      label: 'Invoice PDF',
                      color: theme.colorScheme.primary,
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

  // Download TXT file
  Future<void> _downloadTxt(BuildContext context, String text) async {
    try {
      final directory = await getExternalStorageDirectory();
      final fileName = '${customer.name.replaceAll(' ', '_')}_measurement.txt';
      final file = File('${directory!.path}/$fileName');
      await file.writeAsString(text);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to $fileName'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _ActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
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
