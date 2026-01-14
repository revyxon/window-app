import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../utils/app_colors.dart';
import '../utils/haptics.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 60),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // GROUP 1: Identity
                _buildHeaderIdentity(),
                const SizedBox(height: 40),

                // GROUP 2: The Core (Real Features)
                _buildSectionLabel('THE CORE ENGINE'),
                _buildFeatureTile(
                  'Quick-Entry System',
                  'Rapid "W x H" input with number pad optimized for speed.',
                  FluentIcons.keyboard_layout_float_24_regular,
                  Colors.blue,
                ),
                _buildFeatureTile(
                  'Window Type System',
                  'Native support for 3T, 2T, Open, Fixed, Partition & custom types.',
                  FluentIcons.grid_24_regular,
                  Colors.indigo,
                ),
                _buildFeatureTile(
                  'Smart "Hold" Logic',
                  'Pause specific windows to exclude them from calculations without deleting.',
                  FluentIcons.pause_circle_24_regular,
                  Colors.orange,
                ),
                _buildFeatureTile(
                  'Final Measurement Mode',
                  'Lock customer profiles with "Final" status to prevent accidental edits.',
                  FluentIcons.checkmark_lock_24_regular,
                  Colors.green,
                ),
                _buildFeatureTile(
                  'Global Search',
                  'Instantly find customers by name, location, or phone.',
                  FluentIcons.search_24_regular,
                  Colors.teal,
                ),
                const SizedBox(height: 32),

                // GROUP 3: Admin Intelligence
                _buildSectionLabel('ADMIN INTELLIGENCE'),
                _buildAdminInsightsCard(),
                const SizedBox(height: 32),

                // GROUP 4: Cloud & Data
                _buildSectionLabel('CLOUD & ARCHITECTURE'),
                _buildCloudGrid(),
                const SizedBox(height: 32),

                // GROUP 5: Workflow
                _buildSectionLabel('WORKFLOW GUIDE'),
                _buildWorkflowSteps(),
                const SizedBox(height: 32),

                // GROUP 6: Tech Stack
                _buildSectionLabel('POWERED BY'),
                _buildTechStackGrid(),
                const SizedBox(height: 32),

                // GROUP 7: Legal/Footer
                _buildLinkRow('Privacy Policy', FluentIcons.shield_24_regular),
                _buildLinkRow(
                  'Terms of Use',
                  FluentIcons.document_text_24_regular,
                ),
                const SizedBox(height: 40),

                _buildFooter(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'About',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHeaderIdentity() {
    return Column(
      children: [
        Hero(
          tag: 'app_logo_about',
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  const Color(0xFF6366F1),
                ], // Indigo accent
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(
              FluentIcons.window_24_filled,
              color: Colors.white,
              size: 44,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Window Manager Pro',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Precision Tools for Fabricators',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),

        // Developer Credit Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              children: [
                const TextSpan(text: 'Designed & Engineered by '),
                TextSpan(
                  text: 'Adarsh Tiwari',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800, // Extra bold
          color: Colors.grey.shade400,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    String title,
    String desc,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
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

  Widget _buildAdminInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E293B), const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                FluentIcons.sparkle_24_filled,
                color: Color(0xFFFBBF24),
                size: 24,
              ), // Amber star
              const SizedBox(width: 10),
              const Text(
                'Profit Engine',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDarkStatRow(
            'Bonus Calculator',
            'Analyzes 90903 vs 92903 formulas to track extra margins.',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white12, height: 1),
          ),
          _buildDarkStatRow(
            'Analytics',
            'Real-time calculation of SqFt leaks and rate benefits.',
          ),
        ],
      ),
    );
  }

  Widget _buildDarkStatRow(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFBBF24),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  Widget _buildCloudGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildSquareCard(
            'Offline First',
            'Works 100% locally with SQLite.',
            FluentIcons.wifi_off_24_regular,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSquareCard(
            'Auto Sync',
            'Background upload to Firebase.',
            FluentIcons.cloud_sync_24_regular,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSquareCard(
    String title,
    String desc,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowSteps() {
    return Column(
      children: [
        _buildStepRow('1', 'Create Profile', 'Set Rate & Location'),
        _buildStepRow('2', 'Input Specs', 'Fast WxH Entry'),
        _buildStepRow('3', 'Verify', 'Hold Duplicates'),
        _buildStepRow('4', 'Finalize', 'Lock & Sync'),
      ],
    );
  }

  Widget _buildStepRow(String num, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            alignment: Alignment.center,
            child: Text(
              num,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const Spacer(),
          Text(
            sub,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildTechStackGrid() {
    final tech = [
      {
        'n': 'Flutter',
        'c': Colors.blue,
        'i': FluentIcons.phone_laptop_24_regular,
      },
      {'n': 'Firebase', 'c': Colors.orange, 'i': FluentIcons.cloud_24_regular},
      {'n': 'SQLite', 'c': Colors.indigo, 'i': FluentIcons.database_24_regular},
      {
        'n': 'Provider',
        'c': Colors.purple,
        'i': FluentIcons.tree_deciduous_24_regular,
      },
      {'n': 'Dart', 'c': Colors.teal, 'i': FluentIcons.code_24_regular},
      {
        'n': 'Material 3',
        'c': Colors.pink,
        'i': FluentIcons.paint_brush_24_regular,
      },
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: tech
          .map(
            (t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: (t['c'] as Color).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (t['c'] as Color).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t['i'] as IconData, size: 16, color: t['c'] as Color),
                  const SizedBox(width: 8),
                  Text(
                    t['n'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: (t['c'] as Color),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildLinkRow(String title, IconData icon) {
    return InkWell(
      onTap: () => Haptics.light(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade400),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        '© 2026 Adarsh Tiwari. All Rights Reserved.',
        style: TextStyle(
          color: Colors.grey.shade300,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
