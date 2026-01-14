import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/settings_provider.dart';

import '../utils/app_colors.dart';
import '../utils/haptics.dart';
import '../utils/fast_page_route.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/customer_card.dart';
import 'settings_screen.dart';
import '../services/sync_service.dart';
import '../services/activity_log_service.dart';
import '../models/activity_log.dart';
import '../widgets/premium_toast.dart';

class MeasurementListScreen extends StatefulWidget {
  const MeasurementListScreen({super.key});

  @override
  State<MeasurementListScreen> createState() => _MeasurementListScreenState();
}

class _MeasurementListScreenState extends State<MeasurementListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    // Log screen view
    ActivityLogService().logScreenView(ScreenNames.home);
    Future.microtask(
      () => Provider.of<AppProvider>(context, listen: false).loadCustomers(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Manual sync trigger
  Future<void> _triggerManualSync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    Haptics.medium();

    // Log manual sync action
    ActivityLogService().logManualSync();

    try {
      final error = await SyncService().syncData();
      if (mounted) {
        if (error == null) {
          ToastService.show(context, 'Synced successfully!');
        } else {
          ToastService.show(context, 'Sync error: $error', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        ToastService.show(context, 'Sync failed: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final customers = provider.customers.where((c) {
            return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                c.location.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return CustomScrollView(
            slivers: [
              // Sticky AppBar with search
              SliverAppBar(
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                toolbarHeight: 60,
                title: Row(
                  children: [
                    const Icon(Icons.straighten_outlined, color: Colors.black),
                    const SizedBox(width: 12),
                    const Text(
                      'Measurements',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                actions: [
                  // Manual Sync Button (Cloud icon)
                  IconButton(
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black54,
                            ),
                          )
                        : const Icon(
                            Icons.cloud_sync_outlined,
                            color: Colors.black,
                          ),
                    onPressed: _triggerManualSync,
                    tooltip: 'Sync to cloud',
                  ),
                  // Theme Toggle
                  Consumer<SettingsProvider>(
                    builder: (context, settings, _) => IconButton(
                      icon: Icon(
                        settings.isDarkMode
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Haptics.light();
                        settings.toggleDarkMode();
                      },
                    ),
                  ),
                  // Settings
                  IconButton(
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Haptics.light();
                      Navigator.push(
                        context,
                        FastPageRoute(page: const SettingsScreen()),
                      );
                    },
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(70),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Search customers...',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Colors.grey.shade500,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              if (provider.isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => const SkeletonCustomerCard(),
                      childCount: 6,
                    ),
                  ),
                )
              else if (customers.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_3_outlined,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No customers yet.\nAdd one to get started!'
                              : 'No customers found.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final customer = customers[index];
                      return CustomerCard(customer: customer);
                    }, childCount: customers.length),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
