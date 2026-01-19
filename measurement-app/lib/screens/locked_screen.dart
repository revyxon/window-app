import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/device_id_service.dart';
import '../services/license_service.dart';
import '../widgets/animated_press_button.dart';

/// Premium Pro-Level Lock Screen
/// Features: Status Dashboard, Support Hub, Tech Details, Gradient Visuals
class LockedScreen extends StatefulWidget {
  final String? reason;
  final VoidCallback? onRetry;

  const LockedScreen({super.key, this.reason, this.onRetry});

  @override
  State<LockedScreen> createState() => _LockedScreenState();
}

class _LockedScreenState extends State<LockedScreen> {
  bool _isChecking = false;
  bool _showTechDetails = false;

  Future<void> _handleRetry() async {
    setState(() => _isChecking = true);
    await HapticFeedback.mediumImpact();
    // Min delay for effect
    await Future.delayed(const Duration(seconds: 1));
    if (widget.onRetry != null) {
      widget.onRetry!();
    }
    if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _contactSupport() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@windowapp.com', // Replace with actual
      query: 'subject=License Issue&body=My device ID is...',
    );
    if (!await launchUrl(emailLaunchUri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dark/Red Gradient Theme for "Locked" state
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Ambient Gradient
          Positioned(
            top: -100,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFDC2626).withValues(alpha: 0.15),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),

                  // Big Animated Icon
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(seconds: 1),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F1F1F),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(
                                0xFFDC2626,
                              ).withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFDC2626,
                                ).withValues(alpha: 0.2),
                                blurRadius: 40,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            FluentIcons.lock_closed_24_filled,
                            size: 64,
                            color: Color(0xFFEF4444), // Red
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Title & Message
                  const Text(
                    'Access Restricted',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1F1F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Text(
                      widget.reason ??
                          'Your license has expired or this device is not authorized.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Status Dashboard
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusCard(
                          'Grace Period',
                          LicenseService().daysUntilExpiry > 0
                              ? '${LicenseService().daysUntilExpiry} Days'
                              : 'Expired',
                          FluentIcons.timer_24_regular,
                          LicenseService().daysUntilExpiry > 0
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard(
                          'Server Status',
                          'Locked',
                          FluentIcons.server_24_regular,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Actions
                  Column(
                    children: [
                      AnimatedPressButton(
                        onPressed: _isChecking ? null : _handleRetry,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFDC2626,
                                ).withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _isChecking
                              ? const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Check Status',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _contactSupport,
                        icon: const Icon(
                          FluentIcons.mail_24_regular,
                          color: Colors.white70,
                        ),
                        label: const Text(
                          'Contact Support',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Tech Details Toggle
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showTechDetails = !_showTechDetails),
                    child: Text(
                      _showTechDetails
                          ? 'Hide Tech Details'
                          : 'Show Tech Details',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 12,
                      ),
                    ),
                  ),

                  if (_showTechDetails) ...[
                    const SizedBox(height: 16),
                    FutureBuilder<String>(
                      future: DeviceIdService.instance.getDeviceId(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            'ID: ${snapshot.data}\nVer: ${_getAppVersion()}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  String _getAppVersion() => '1.0.3'; // Placeholder or fetch real
}
