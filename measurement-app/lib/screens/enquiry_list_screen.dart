import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../providers/app_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/enquiry_card.dart';
import 'enquiry_detail_screen.dart';
import '../services/activity_log_service.dart';
import '../models/activity_log.dart';
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
    ActivityLogService().logScreenView(ScreenNames.home); // Using home for now

    Future.microtask(
      () => Provider.of<AppProvider>(context, listen: false).loadEnquiries(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _activeFilter == value;
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
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                toolbarHeight: 60,
                title: Row(
                  children: [
                    const Icon(Icons.assignment_outlined, color: Colors.black),
                    const SizedBox(width: 12),
                    const Text(
                      'Enquiries',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(120),
                  child: Column(
                    children: [
                      // Search
                      Padding(
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
                              hintText: 'Search enquiries...',
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
                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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

              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (enquiries.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty && _activeFilter == 'all'
                              ? 'No enquiries yet'
                              : 'No enquiries found',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final enquiry = enquiries[index];
                      return EnquiryCard(
                        enquiry: enquiry,
                        onTap: () {
                          Navigator.push(
                            context,
                            FastPageRoute(
                              page: EnquiryDetailScreen(enquiry: enquiry),
                            ),
                          );
                        },
                      );
                    }, childCount: enquiries.length),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
