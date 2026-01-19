import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

import '../ui/tokens/spacing.dart';
import '../ui/design_system.dart';
import '../ui/components/app_header.dart';
import '../ui/components/app_icon.dart';
import '../ui/components/app_search_bar.dart';
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
    Future.microtask(() {
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.loadCustomers();

      // Check for import file from intent
      if (GlobalParams.importFilePath != null) {
        _handleImportAction(context, filePath: GlobalParams.importFilePath);
        GlobalParams.importFilePath = null;
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

  Future<void> _triggerManualSync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    Haptics.medium();

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final customers = provider.customers.where((c) {
            return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                c.location.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return CustomScrollView(
            slivers: [
              AppHeader(
                title: 'Measurements',
                icon: AppIconType.measurement,
                actions: [
                  // Sync Button
                  IconButton(
                    icon: _isSyncing
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.sync_rounded,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.8,
                            ),
                          ),
                    onPressed: _triggerManualSync,
                    tooltip: 'Sync',
                  ),
                  // Settings
                  IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                    onPressed: () {
                      Haptics.light();
                      Navigator.push(
                        context,
                        FastPageRoute(page: const SettingsScreen()),
                      );
                    },
                    tooltip: 'Settings',
                  ),
                  const SizedBox(width: Spacing.xs),
                ],
              ),

              // Search Bar (Non-sticky, scrolls with content)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: AppSearchBar(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    hintText: 'Search customers...',
                  ),
                ),
              ),

              // Content
              if (provider.isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => const SkeletonCustomerCard(),
                      childCount: 6,
                    ),
                  ),
                )
              else if (customers.isEmpty)
                SliverFillRemaining(child: _buildEmptyState(context))
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.lg,
                    vertical: Spacing.sm,
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

  /// Premium empty state - no external dependencies
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isSearch = _searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container with subtle background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearch ? Icons.search_off_rounded : Icons.folder_open_rounded,
                size: 48,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: Spacing.xl),

            // Title
            Text(
              isSearch ? 'No results found' : 'No Measurements Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: Spacing.sm),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
              child: Text(
                isSearch
                    ? 'Try a different search term'
                    : 'Create your first customer to get started',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),
            ),

            if (!isSearch) ...[
              const SizedBox(height: Spacing.xl),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _handleImportAction(context),
                    icon: const Icon(Icons.file_upload_outlined, size: 18),
                    label: const Text('Import'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.lg,
                        vertical: Spacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        FastPageRoute(page: const AddCustomerScreen()),
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('New Customer'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.lg,
                        vertical: Spacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
