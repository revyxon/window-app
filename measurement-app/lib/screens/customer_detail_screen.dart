import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../models/window.dart';
import '../providers/app_provider.dart';
import 'window_input_screen.dart';
import '../utils/window_calculator.dart';
import '../widgets/share_bottom_sheet.dart';
import '../widgets/print_bottom_sheet.dart';
import '../utils/haptics.dart';
import '../utils/window_types.dart';
import '../utils/fast_page_route.dart';
import '../widgets/skeleton_loader.dart';
import '../utils/app_colors.dart';
import '../services/permission_helper.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late Customer _customer;
  final _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
  }

  String _formatINR(double amount) {
    return _inrFormat.format(amount);
  }

  void _showOptionsMenu(BuildContext context) {
    Haptics.selection();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _menuItem(FluentIcons.edit_24_regular, 'Edit Customer', () {
              Navigator.pop(context);
              // Check edit_customer permission
              if (!PermissionHelper().checkAndShowDialog(
                context,
                'edit_customer',
                'Edit Customer',
              )) {
                return;
              }
            }),
            _menuItem(FluentIcons.grid_24_regular, 'Edit Windows', () {
              Navigator.pop(context);
              // Check edit_window permission
              if (!PermissionHelper().checkAndShowDialog(
                context,
                'edit_window',
                'Edit Windows',
              )) {
                return;
              }
              Navigator.push(
                context,
                FastPageRoute(page: WindowInputScreen(customer: _customer)),
              ).then((_) => setState(() {}));
            }),
            _menuItem(FluentIcons.sparkle_24_regular, 'Admin Insights', () {
              Navigator.pop(context);
              _showAdminInsights(context);
            }),
            const Divider(),
            _menuItem(FluentIcons.delete_24_regular, 'Delete Customer', () {
              Navigator.pop(context);
              // Check delete_customer permission
              if (!PermissionHelper().checkAndShowDialog(
                context,
                'delete_customer',
                'Delete Customer',
              )) {
                return;
              }
              _showDeleteConfirmation(context);
            }, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF374151),
        size: 24,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      onTap: () {
        Haptics.light();
        onTap();
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Customer?'),
        content: Text(
          'Are you sure you want to delete ${_customer.name}? This will also delete all windows.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Haptics.medium();
              Navigator.pop(context);
              await Provider.of<AppProvider>(
                context,
                listen: false,
              ).deleteCustomer(_customer.id!);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAdminInsights(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) =>
            _buildAdminInsightsSheet(scrollController),
      ),
    );
  }

  Widget _buildAdminInsightsSheet(ScrollController scrollController) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<List<Window>>(
          future: provider.getWindows(_customer.id!),
          builder: (context, snapshot) {
            final windows = snapshot.data ?? [];
            final totalQty = windows.fold(0, (sum, w) => sum + w.quantity);

            // Displayed sqft
            final displayedSqFt = windows.fold(
              0.0,
              (sum, w) =>
                  sum +
                  WindowCalculator.calculateDisplayedSqFt(
                    width: w.width,
                    height: w.height,
                    quantity: w.quantity.toDouble(),
                    width2: w.width2 ?? 0,
                    type: w.type,
                    isFormulaA: w.formula == 'A' || w.formula == null,
                  ),
            );
            // Actual sqft
            final actualSqFt = windows.fold(
              0.0,
              (sum, w) =>
                  sum +
                  WindowCalculator.calculateActualSqFt(
                    width: w.width,
                    height: w.height,
                    quantity: w.quantity.toDouble(),
                    width2: w.width2 ?? 0,
                    type: w.type,
                    isFormulaA: w.formula == 'A' || w.formula == null,
                  ),
            );

            final avgPerWindow = windows.isNotEmpty
                ? displayedSqFt / windows.length
                : 0.0;
            final extraGiven = displayedSqFt - actualSqFt;
            final bonusPercent = actualSqFt > 0
                ? (extraGiven / actualSqFt * 100)
                : 0.0;

            final rate = _customer.ratePerSqft ?? 0;
            final chargedAmount = displayedSqFt * rate;
            final actualWorth = actualSqFt * rate;
            final customerBenefit = chargedAmount - actualWorth;

            // Additional analytics
            final avgDimension = windows.isNotEmpty
                ? windows.fold(
                        0.0,
                        (sum, w) => sum + (w.width + w.height) / 2,
                      ) /
                      windows.length
                : 0.0;
            final largestWindow = windows.isNotEmpty
                ? windows.reduce(
                    (a, b) =>
                        (a.width * a.height) > (b.width * b.height) ? a : b,
                  )
                : null;
            final smallestWindow = windows.isNotEmpty
                ? windows.reduce(
                    (a, b) =>
                        (a.width * a.height) < (b.width * b.height) ? a : b,
                  )
                : null;

            return Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          FluentIcons.sparkle_24_filled,
                          color: Color(0xFF7C3AED),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Admin Insights',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _customer.name,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick Stats Row
                  Row(
                    children: [
                      _insightStatBox(
                        FluentIcons.window_24_regular,
                        '${windows.length}',
                        'Windows',
                      ),
                      const SizedBox(width: 12),
                      _insightStatBox(
                        FluentIcons.copy_24_regular,
                        '$totalQty',
                        'Total Qty',
                      ),
                      const SizedBox(width: 12),
                      _insightStatBox(
                        FluentIcons.ruler_24_regular,
                        avgPerWindow.toStringAsFixed(2),
                        'Avg Sqft',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // SQFT Analysis Card
                  _analysisCard(
                    icon: FluentIcons.table_24_filled,
                    title: 'SQFT ANALYSIS',
                    titleColor: AppColors.primary,
                    children: [
                      _analysisRow(
                        'Displayed to Customer',
                        '${displayedSqFt.toStringAsFixed(2)} sqft',
                        AppColors.primary,
                      ),
                      _analysisRow(
                        'Actual (Real Formula)',
                        '${actualSqFt.toStringAsFixed(2)} sqft',
                        const Color(0xFFF59E0B),
                      ),
                      const Divider(height: 24),
                      _analysisRow(
                        'Extra Given',
                        '+${extraGiven.toStringAsFixed(2)} sqft',
                        AppColors.success,
                        icon: FluentIcons.add_circle_24_regular,
                      ),
                      _analysisRow(
                        'Bonus %',
                        '+${bonusPercent.toStringAsFixed(2)}%',
                        AppColors.success,
                        icon: FluentIcons.arrow_trending_24_regular,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Cost Analysis Card
                  _analysisCard(
                    icon: FluentIcons.money_24_filled,
                    title: 'COST ANALYSIS',
                    titleColor: const Color(0xFFF59E0B),
                    children: [
                      _analysisRow(
                        'Rate per Sqft',
                        _formatINR(rate),
                        Colors.black87,
                      ),
                      _analysisRow(
                        'Charged Amount',
                        _formatINR(chargedAmount),
                        AppColors.primary,
                      ),
                      _analysisRow(
                        'Actual Worth',
                        _formatINR(actualWorth),
                        const Color(0xFFF59E0B),
                      ),
                      const Divider(height: 24),
                      _analysisRow(
                        'Customer Benefit',
                        _formatINR(customerBenefit),
                        AppColors.success,
                        icon: FluentIcons.gift_24_regular,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Window Details Card
                  if (windows.isNotEmpty)
                    _analysisCard(
                      icon: FluentIcons.data_bar_vertical_24_filled,
                      title: 'WINDOW ANALYTICS',
                      titleColor: const Color(0xFF8B5CF6),
                      children: [
                        _analysisRow(
                          'Total Windows',
                          '${windows.length}',
                          Colors.black87,
                        ),
                        _analysisRow(
                          'Total Pieces (Qty)',
                          '$totalQty',
                          Colors.black87,
                        ),
                        _analysisRow(
                          'Avg Dimension',
                          '${avgDimension.toStringAsFixed(0)} mm',
                          Colors.black87,
                        ),
                        if (largestWindow != null)
                          _analysisRow(
                            'Largest Window',
                            '${largestWindow.name} (${largestWindow.width.toStringAsFixed(0)}×${largestWindow.height.toStringAsFixed(0)})',
                            AppColors.primary,
                          ),
                        if (smallestWindow != null)
                          _analysisRow(
                            'Smallest Window',
                            '${smallestWindow.name} (${smallestWindow.width.toStringAsFixed(0)}×${smallestWindow.height.toStringAsFixed(0)})',
                            const Color(0xFFF59E0B),
                          ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Formula Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              FluentIcons.info_24_regular,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'FORMULA INFO',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _formulaRow('Our Formula', 'W × H ÷ 90,903'),
                        const SizedBox(height: 10),
                        _formulaRow('Real Formula', 'W × H ÷ 92,903'),
                        const SizedBox(height: 14),
                        Text(
                          'Customer gets ~${bonusPercent.toStringAsFixed(1)}% extra sqft compared to actual measurement.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _insightStatBox(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 24),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _analysisCard({
    required IconData icon,
    required String title,
    required Color titleColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: titleColor, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _analysisRow(
    String label,
    String value,
    Color valueColor, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: valueColor),
            const SizedBox(width: 8),
          ],
          Text(label, style: const TextStyle(fontSize: 15)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formulaRow(String label, String formula) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            formula,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _customer.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              FluentIcons.share_24_regular,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () {
              Haptics.light();
              if (_customer.id != null) {
                // Fetch windows and show share sheet
                Provider.of<AppProvider>(
                  context,
                  listen: false,
                ).getWindows(_customer.id!).then((windows) {
                  if (mounted)
                    showShareBottomSheet(context, _customer, windows);
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(
              FluentIcons.print_24_regular,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () {
              Haptics.light();
              if (_customer.id != null) {
                Provider.of<AppProvider>(
                  context,
                  listen: false,
                ).getWindows(_customer.id!).then((windows) {
                  if (mounted)
                    showPrintBottomSheet(context, _customer, windows);
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(
              FluentIcons.more_vertical_24_regular,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return FutureBuilder<List<Window>>(
            future: provider.getWindows(_customer.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: List.generate(
                      3,
                      (index) => const SkeletonWindowCard(),
                    ),
                  ),
                );
              }

              final windows = snapshot.data ?? [];
              final totalSqFt = windows.fold(
                0.0,
                (sum, w) => sum + (w.width * w.height / 90903.0 * w.quantity),
              );
              final totalRate = (_customer.ratePerSqft ?? 0) * totalSqFt;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Info Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow(
                            FluentIcons.location_24_regular,
                            'Location',
                            _customer.location,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          if (_customer.phone?.isNotEmpty == true) ...[
                            _infoRow(
                              FluentIcons.call_24_regular,
                              'Phone',
                              _customer.phone!,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Divider(
                                height: 1,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ],
                          Row(
                            children: [
                              _statChip(
                                FluentIcons.wrench_24_regular,
                                _customer.framework,
                                'Framework',
                              ),
                              const SizedBox(width: 10),
                              _statChip(
                                FluentIcons.grid_24_regular,
                                '${windows.length}',
                                'Windows',
                              ),
                              const SizedBox(width: 10),
                              _statChip(
                                FluentIcons.ruler_24_regular,
                                totalSqFt.toStringAsFixed(2),
                                'Total Sqft',
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                FluentIcons.money_24_regular,
                                color: Colors.grey.shade600,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rate',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '₹${_customer.ratePerSqft?.toStringAsFixed(2) ?? "0.00"}/sqft',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  'Total: ${_formatINR(totalRate)}',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_customer.isFinalMeasurement)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 18,
                        ),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              FluentIcons.checkmark_circle_24_filled,
                              color: AppColors.success,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Final Measurement',
                              style: TextStyle(
                                color: Color(0xFF047857),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Windows',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Haptics.light();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WindowInputScreen(customer: _customer),
                              ),
                            ).then((_) => setState(() {}));
                          },
                          icon: const Icon(
                            FluentIcons.edit_24_regular,
                            size: 20,
                          ),
                          label: const Text(
                            'Edit',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (windows.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(40),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(
                              FluentIcons.window_24_regular,
                              size: 56,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No windows added yet',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...List.generate(windows.length, (index) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(
                            milliseconds: 300 + (index * 50).clamp(0, 500),
                          ),
                          curve: Curves.easeOutQuart,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: _buildWindowCard(windows[index]),
                        );
                      }),

                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Haptics.medium();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WindowInputScreen(customer: _customer),
            ),
          ).then((_) => setState(() {}));
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWindowCard(Window window) {
    final rate = _customer.ratePerSqft ?? 0;
    // Use displayed sqft formula: W × H ÷ 90,903
    final displayedSqFt =
        (window.width * window.height / 90903.0) * window.quantity;
    final cost = displayedSqFt * rate;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // Window Badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              window.name,
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (window.width2 != null && window.width2! > 0)
                      ? '(${window.width.toStringAsFixed(0)} + ${window.width2!.toStringAsFixed(0)}) × ${window.height.toStringAsFixed(0)} mm'
                      : '${window.width.toStringAsFixed(0)} × ${window.height.toStringAsFixed(0)} mm',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        window.type,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (window.quantity > 1) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E7FF),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '×${window.quantity}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4338CA),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      _getDisplayType(window),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Sqft & Cost
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${displayedSqFt.toStringAsFixed(2)} sqft',
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatINR(cost),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDisplayType(Window window) {
    String typeName = WindowType.getName(window.type);
    if (window.customName != null && window.customName!.isNotEmpty) {
      return '$typeName (${window.customName})';
    }
    return typeName;
  }
}
