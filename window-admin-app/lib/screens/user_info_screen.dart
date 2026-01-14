import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';

/// Full dedicated User Info Screen matching admin app theme
class UserInfoScreen extends StatelessWidget {
  final Map<String, dynamic> deviceData;
  final String deviceId;

  const UserInfoScreen({
    super.key,
    required this.deviceData,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    final deviceInfo = deviceData['deviceInfo'] as Map<String, dynamic>? ?? {};
    final registeredAt = deviceData['registeredAt'] != null
        ? DateTime.tryParse(deviceData['registeredAt'])
        : null;
    final lastActiveAt = deviceData['lastActiveAt'] != null
        ? DateTime.tryParse(deviceData['lastActiveAt'])
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Device Information'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          _buildHeaderCard(deviceInfo),
          const SizedBox(height: 24),

          // Section: Device Identity
          _buildSection(
            context,
            title: 'Device Identity',
            icon: FluentIcons.phone_24_regular,
            children: [
              _buildInfoRow('Brand', deviceInfo['brand']),
              _buildInfoRow('Manufacturer', deviceInfo['manufacturer']),
              _buildInfoRow('Model', deviceInfo['model']),
              _buildInfoRow('Product', deviceInfo['product']),
              _buildInfoRow('Device Name', deviceInfo['device']),
            ],
          ),

          // Section: Hardware
          _buildSection(
            context,
            title: 'Hardware Specifications',
            icon: FluentIcons.board_24_regular,
            children: [
              _buildInfoRow('Board', deviceInfo['board']),
              _buildInfoRow('Hardware', deviceInfo['hardware']),
              _buildInfoRow('Bootloader', deviceInfo['bootloader']),
              _buildInfoRow('Host', deviceInfo['host']),
              _buildInfoRow(
                'Physical Device',
                deviceInfo['isPhysicalDevice'] == true
                    ? 'Yes ✓'
                    : 'No (Emulator)',
              ),
              _buildInfoRow(
                'CPU Cores',
                deviceInfo['numberOfProcessors']?.toString(),
              ),
            ],
          ),

          // Section: Operating System
          _buildSection(
            context,
            title: 'Operating System',
            icon: FluentIcons.window_24_regular,
            children: [
              _buildInfoRow('Platform', deviceInfo['platform']),
              _buildInfoRow('Android Version', deviceInfo['androidVersion']),
              _buildInfoRow('SDK Level', 'API ${deviceInfo['sdkInt'] ?? '?'}'),
              _buildInfoRow('Security Patch', deviceInfo['securityPatch']),
              _buildInfoRow('Base OS', deviceInfo['baseOS']),
              _buildInfoRow('Codename', deviceInfo['codename']),
              _buildInfoRow('Incremental', deviceInfo['incremental']),
            ],
          ),

          // Section: Build Information
          _buildSection(
            context,
            title: 'Build Information',
            icon: FluentIcons.wrench_24_regular,
            children: [
              _buildInfoRow('Build ID', deviceInfo['buildId']),
              _buildInfoRow('Display', deviceInfo['buildDisplay']),
              _buildInfoRow('Build Type', deviceInfo['buildType']),
              _buildInfoRow('Build Tags', deviceInfo['buildTags']),
              _buildInfoRow(
                'Fingerprint',
                deviceInfo['buildFingerprint'],
                isMonospace: true,
              ),
            ],
          ),

          // Section: CPU Architecture
          _buildSection(
            context,
            title: 'CPU Architecture',
            icon: FluentIcons.code_24_regular,
            children: [
              _buildInfoRow(
                'Supported ABIs',
                (deviceInfo['supportedAbis'] as List?)?.join(', ') ?? 'N/A',
              ),
              _buildInfoRow(
                '32-bit ABIs',
                (deviceInfo['supported32BitAbis'] as List?)?.join(', ') ??
                    'N/A',
              ),
              _buildInfoRow(
                '64-bit ABIs',
                (deviceInfo['supported64BitAbis'] as List?)?.join(', ') ??
                    'N/A',
              ),
            ],
          ),

          // Section: User Environment
          _buildSection(
            context,
            title: 'User Environment',
            icon: FluentIcons.globe_24_regular,
            children: [
              _buildInfoRow('Locale', deviceInfo['localeName']),
              _buildInfoRow('Platform Version', deviceInfo['platformVersion']),
              _buildInfoRow('Data Collected', deviceInfo['collectedAt']),
            ],
          ),

          // Section: Timeline
          _buildSection(
            context,
            title: 'Timeline',
            icon: FluentIcons.history_24_regular,
            children: [
              _buildInfoRow(
                'Registered',
                registeredAt != null
                    ? DateFormat.yMMMMd().add_jm().format(registeredAt)
                    : 'Unknown',
              ),
              _buildInfoRow(
                'Last Active',
                lastActiveAt != null
                    ? DateFormat.yMMMMd().add_jm().format(lastActiveAt)
                    : 'Unknown',
              ),
              _buildInfoRow(
                'Days Active',
                registeredAt != null
                    ? '${DateTime.now().difference(registeredAt).inDays} days'
                    : 'N/A',
              ),
              _buildInfoRow('App Version', deviceData['appVersion']),
            ],
          ),

          // Device ID Card
          const SizedBox(height: 8),
          _buildDeviceIdCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Map<String, dynamic> deviceInfo) {
    final brand = deviceInfo['brand'] ?? 'Unknown';
    final model = deviceInfo['model'] ?? 'Device';
    final androidVersion = deviceInfo['androidVersion'] ?? '?';
    final sdkInt = deviceInfo['sdkInt'] ?? '?';
    final status = deviceData['status']?.toString().toUpperCase() ?? 'ACTIVE';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              FluentIcons.phone_24_filled,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$brand $model',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Android $androidVersion (API $sdkInt)',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: status == 'ACTIVE'
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: status == 'ACTIVE' ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    dynamic value, {
    bool isMonospace = false,
  }) {
    final displayValue = value?.toString() ?? 'N/A';
    final isEmpty = displayValue == 'N/A' || displayValue.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: isMonospace ? 11 : 13,
                fontFamily: isMonospace ? 'monospace' : null,
                color: isEmpty
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceIdCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Text(
            'DEVICE ID',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            deviceId,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
