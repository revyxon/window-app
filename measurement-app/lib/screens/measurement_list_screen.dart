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
import '../services/log_service.dart';
import '../services/data_import_service.dart';
import '../models/activity_log.dart';
import '../widgets/premium_toast.dart';
import 'package:lottie/lottie.dart';
import '../utils/globals.dart';
import 'add_customer_screen.dart';

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
    // Manual logScreenView removed as handled by LoggingNavigatorObserver
    Future.microtask(() {
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.loadCustomers();

      // Check for import file from intent
      if (GlobalParams.importFilePath != null) {
        _handleImportAction(context, filePath: GlobalParams.importFilePath);
        GlobalParams.importFilePath = null; // Clear after handling
      }
    });
  }

  Future<void> _handleImportAction(
    BuildContext context, {
    String? filePath,
  }) async {
    try {
      if (filePath == null) {
        ToastService.show(
          context,
          'Please open a .json file from your File Manager',
          isError: false,
        );
        return;
      }

      final result = await DataImportService().importFromFile(filePath);

      if (result['success'] == true) {
        ToastService.show(context, result['message'], isError: false);
        // Refresh list
        if (mounted) {
          Provider.of<AppProvider>(context, listen: false).loadCustomers();
        }
      } else {
        ToastService.show(context, result['message'], isError: true);
      }
    } catch (e) {
      ToastService.show(context, 'Import failed: $e', isError: true);
    }
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
    LogService().logEvent(ActionNames.manualSync, page: ScreenNames.home);

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                surfaceTintColor: Colors.transparent,
                toolbarHeight: 60,
                title: Row(
                  children: [
                    Icon(
                      Icons.straighten_outlined,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Measurements',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge?.color,
                          ),
                    ),
                  ],
                ),
                actions: [
                  // Manual Sync Button (Cloud icon)
                  IconButton(
                    icon: _isSyncing
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(
                                context,
                              ).iconTheme.color?.withOpacity(0.7),
                            ),
                          )
                        : Icon(
                            Icons.cloud_sync_outlined,
                            color: Theme.of(context).iconTheme.color,
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
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () {
                        Haptics.light();
                        settings.toggleDarkMode();
                      },
                    ),
                  ),
                  // Settings
                  IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: Theme.of(context).iconTheme.color,
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
                        color:
                            Theme.of(context).inputDecorationTheme.fillColor ??
                            Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Search customers...',
                          hintStyle: Theme.of(
                            context,
                          ).inputDecorationTheme.hintStyle,
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Theme.of(context).hintColor,
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
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Premium Vector Illustration (Lottie)
                          Lottie.network(
                            'https://assets9.lottiefiles.com/packages/lf20_sufcnt.json',
                            height: 220,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                width: 200,
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.05,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.folder_open_rounded,
                                  size: 80,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No Measurements Yet'
                                : 'No results found',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              _searchQuery.isEmpty
                                  ? 'Create your first customer measurement or import a backup file to get started.'
                                  : 'We couldn\'t find any customers matching "$_searchQuery". Try a different name.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.7),
                                    height: 1.5,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          if (_searchQuery.isEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _handleImportAction(context),
                                  icon: const Icon(Icons.file_upload_outlined),
                                  label: const Text('Import JSON'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                    foregroundColor: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      FastPageRoute(
                                        page: const AddCustomerScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Create New'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
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
