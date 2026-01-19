import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'dart:math' as math;

import '../ui/components/app_navigation_bar.dart';
import '../ui/design_system.dart';
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

  static const List<Widget> _screens = [
    MeasurementListScreen(),
    EnquiryListScreen(),
    WorkAgreementScreen(),
    SettingsScreen(),
  ];

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
      _closeFab();
      setState(() => _selectedIndex = index);
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
    Navigator.push(context, FastPageRoute(page: const CreateEnquiryScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: AppNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _buildExpandableFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildExpandableFab(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Create Enquiry Button
        ScaleTransition(
          scale: _fabAnimation,
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'New Enquiry',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                FloatingActionButton.small(
                  heroTag: 'create_enquiry',
                  onPressed: _navigateToCreateEnquiry,
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.assignment_add),
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
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Measurement',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                FloatingActionButton.small(
                  heroTag: 'create_measurement',
                  onPressed: _navigateToCreateMeasurement,
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add_box_rounded),
                ),
              ],
            ),
          ),
        ),

        // Main FAB
        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: _toggleFab,
          backgroundColor: _isFabExpanded ? surfaceColor : primaryColor,
          foregroundColor: _isFabExpanded ? primaryColor : Colors.white,
          elevation: _isFabExpanded ? 2 : 4,
          child: AnimatedBuilder(
            animation: _fabAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _fabAnimation.value * math.pi * 0.75,
                child: Icon(
                  Icons.add_rounded,
                  size: 32,
                  color: _isFabExpanded ? primaryColor : Colors.white,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
