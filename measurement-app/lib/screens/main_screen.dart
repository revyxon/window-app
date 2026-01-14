import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:animations/animations.dart';
import 'dart:math' as math;

import '../utils/app_colors.dart';
import '../utils/haptics.dart';
import '../utils/fast_page_route.dart';
import 'measurement_list_screen.dart';
import 'enquiry_list_screen.dart';
import 'work_agreement_screen.dart';
import 'settings_screen.dart';
import 'add_customer_screen.dart';
import 'create_enquiry_screen.dart';
import '../services/permission_helper.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isFabExpanded = false;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      Haptics.light();
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _toggleFab() {
    Haptics.medium();
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  void _closeFab() {
    if (_isFabExpanded) {
      setState(() {
        _isFabExpanded = false;
        _fabController.reverse();
      });
    }
  }

  void _navigateToCreateMeasurement() {
    _closeFab();
    if (!PermissionHelper().checkAndShowDialog(
      context,
      'create_customer',
      'Customer Creation',
    )) {
      return;
    }
    Navigator.push(context, FastPageRoute(page: const AddCustomerScreen()));
  }

  void _navigateToCreateEnquiry() {
    _closeFab();
    // Assuming permission check is similar or same
    Navigator.push(context, FastPageRoute(page: const CreateEnquiryScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const MeasurementListScreen(),
      const EnquiryListScreen(),
      const WorkAgreementScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        reverse: false,
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: screens[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        surfaceTintColor: Colors.white,
        indicatorColor: AppColors.primary.withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(FluentIcons.square_multiple_24_regular),
            selectedIcon: Icon(
              FluentIcons.square_multiple_24_filled,
              color: AppColors.primary,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(FluentIcons.clipboard_letter_24_regular),
            selectedIcon: Icon(
              FluentIcons.clipboard_letter_24_filled,
              color: AppColors.primary,
            ),
            label: 'Enquiry',
          ),
          NavigationDestination(
            icon: Icon(FluentIcons.briefcase_24_regular),
            selectedIcon: Icon(
              FluentIcons.briefcase_24_filled,
              color: AppColors.primary,
            ),
            label: 'Agreement',
          ),
          NavigationDestination(
            icon: Icon(FluentIcons.settings_24_regular),
            selectedIcon: Icon(
              FluentIcons.settings_24_filled,
              color: AppColors.primary,
            ),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _buildExpandableFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildExpandableFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Create Enquiry Button
        ScaleTransition(
          scale: _fabAnimation,
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'New Enquiry',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  heroTag: 'create_enquiry',
                  onPressed: _navigateToCreateEnquiry,
                  backgroundColor: AppColors.primary,
                  child: const Icon(
                    FluentIcons.clipboard_letter_24_regular,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Create Measurement Button
        ScaleTransition(
          scale: _fabAnimation,
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Measurement',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  heroTag: 'create_measurement',
                  onPressed: _navigateToCreateMeasurement,
                  backgroundColor: AppColors.primary,
                  child: const Icon(
                    FluentIcons.add_square_24_regular,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Main FAB
        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: _toggleFab,
          backgroundColor: _isFabExpanded ? Colors.white : AppColors.primary,
          child: AnimatedBuilder(
            animation: _fabAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _fabAnimation.value * math.pi * 0.75, // Rotate to X
                child: Icon(
                  Icons.add,
                  size: 28,
                  color: _isFabExpanded ? AppColors.primary : Colors.white,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
