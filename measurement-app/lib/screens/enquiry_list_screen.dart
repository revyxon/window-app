import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../providers/app_provider.dart';
import '../widgets/enquiry_card.dart';
import 'enquiry_detail_screen.dart';
import '../ui/components/app_header.dart';
import '../ui/components/app_icon.dart';
import '../ui/components/app_search_bar.dart';
import '../ui/dialogs/restore_dialog.dart';
import '../utils/fast_page_route.dart';

class EnquiryListScreen extends StatefulWidget {
  const EnquiryListScreen({super.key});

  @override
  State<EnquiryListScreen> createState() => _EnquiryListScreenState();
}

class _EnquiryListScreenState extends State<EnquiryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Tab Filter
  String _activeFilter = 'all'; // all, pending, converted, dismissed

  @override
  void initState() {
    super.initState();
    // Manual logScreenView removed as handled by LoggingNavigatorObserver

    Future.microtask(
      () => Provider.of<AppProvider>(context, listen: false).loadEnquiries(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final enquiries = provider.enquiries.where((e) {
            // Search filter
            final matchesSearch =
                e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (e.location?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false) ||
                (e.phone?.contains(_searchQuery) ?? false);

            if (!matchesSearch) return false;

            // Status filter
            if (_activeFilter == 'all') return true;
            return e.status.toLowerCase() == _activeFilter;
          }).toList();

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              const AppHeader(title: 'Enquiries', icon: AppIconType.enquiry),
              // Search and Filter placed below header in a non-sticky sliver for now
              // Or we can make them part of the body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      // Search
                      AppSearchBar(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        hintText: 'Search enquiries...',
                      ),
                      const SizedBox(height: 12),
                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', 'all'),
                            _buildFilterChip('Pending', 'pending'),
                            _buildFilterChip('Converted', 'converted'),
                            _buildFilterChip('Dismissed', 'dismissed'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : enquiries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty && _activeFilter == 'all'
                              ? 'No enquiries yet'
                              : 'No enquiries found',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                            fontSize: 16,
                          ),
                        ),
                        // Restore Button for Empty State
                        if (_searchQuery.isEmpty && _activeFilter == 'all') ...[
                          const SizedBox(height: 24),
                          TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const RestoreDialog(),
                              );
                            },
                            icon: const Icon(Icons.cloud_download_rounded),
                            label: const Text('Restore from Cloud'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: enquiries.length,
                    itemBuilder: (context, index) {
                      final enquiry = enquiries[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EnquiryCard(
                          enquiry: enquiry,
                          onTap: () {
                            Navigator.push(
                              context,
                              FastPageRoute(
                                page: EnquiryDetailScreen(enquiry: enquiry),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final theme = Theme.of(context);
    final isSelected = _activeFilter == value;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : isDark
                ? Colors.white.withValues(alpha: 0.1)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
