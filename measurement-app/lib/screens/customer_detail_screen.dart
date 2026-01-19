import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../models/window.dart';
import '../providers/app_provider.dart';
import '../providers/settings_provider.dart';
import '../ui/components/app_card.dart';
import '../ui/components/app_icon.dart';
import '../ui/design_system.dart';
import 'window_input_screen.dart';
import 'add_customer_screen.dart';
import '../utils/window_calculator.dart';
import '../widgets/share_bottom_sheet.dart';
import '../widgets/print_bottom_sheet.dart';
import '../utils/haptics.dart';
import '../utils/window_types.dart';
import '../utils/fast_page_route.dart';
import '../widgets/skeleton_loader.dart';
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

  String _formatINR(double amount) => _inrFormat.format(amount);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return FutureBuilder<List<Window>>(
            future: provider.getWindows(_customer.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingSkeleton();
              }

              final windows = snapshot.data ?? [];
              final totalSqFt = windows.fold(
                0.0,
                (sum, w) => sum + (w.width * w.height / 90903.0 * w.quantity),
              );
              final totalRate = (_customer.ratePerSqft ?? 0) * totalSqFt;

              return CustomScrollView(
                slivers: [
                  // Modern App Bar
                  SliverAppBar(
                    pinned: true,
                    toolbarHeight: 56,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    surfaceTintColor: Colors.transparent,
                    leading: IconButton(
                      icon: AppIcon(
                        AppIconType.back,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      _customer.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: AppIcon(
                          AppIconType.share,
                          color: theme.colorScheme.onSurface,
                        ),
                        onPressed: () => _showShare(windows),
                      ),
                      IconButton(
                        icon: AppIcon(
                          AppIconType.print,
                          color: theme.colorScheme.onSurface,
                        ),
                        onPressed: () => _showPrint(windows),
                      ),
                      IconButton(
                        icon: AppIcon(
                          AppIconType.more,
                          color: theme.colorScheme.onSurface,
                        ),
                        onPressed: () => _showOptionsMenu(context),
                      ),
                    ],
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Customer Info Card
                        _buildInfoCard(
                          theme,
                          isDark,
                          windows,
                          totalSqFt,
                          totalRate,
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Final Measurement Badge
                        if (_customer.isFinalMeasurement)
                          _buildFinalBadge(theme),

                        // Windows Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Windows',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _editWindows(),
                              icon: AppIcon(
                                AppIconType.edit,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              label: Text(
                                'Edit',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Windows List
                        if (windows.isEmpty)
                          _buildEmptyState(theme)
                        else
                          ...windows.asMap().entries.map(
                            (e) =>
                                _buildWindowCard(theme, isDark, e.value, e.key),
                          ),

                        const SizedBox(height: 80),
                      ]),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (settings.hapticFeedback) Haptics.medium();
          Navigator.push(
            context,
            FastPageRoute(page: WindowInputScreen(customer: _customer)),
          ).then((_) => setState(() {}));
        },
        backgroundColor: theme.colorScheme.primary,
        child: const AppIcon(AppIconType.add, size: 26, color: Colors.white),
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme,
    bool isDark,
    List<Window> windows,
    double totalSqFt,
    double totalRate,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location
          _InfoRow(
            icon: AppIconType.location,
            label: 'Location',
            value: _customer.location,
          ),

          if (_customer.phone?.isNotEmpty == true) ...[
            Divider(
              height: 28,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
            ),
            _InfoRow(
              icon: AppIconType.phone,
              label: 'Phone',
              value: _customer.phone!,
            ),
          ],

          Divider(
            height: 28,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
          ),

          // Framework + Windows + Sqft Row
          Row(
            children: [
              _MiniStatChip(
                icon: AppIconType.settings,
                value: _customer.framework,
                label: 'Framework',
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              _MiniStatChip(
                icon: AppIconType.window,
                value: '${windows.length}',
                label: 'Windows',
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              _MiniStatChip(
                icon: AppIconType.measurement,
                value: totalSqFt.toStringAsFixed(1),
                label: 'Sqft',
                color: theme.colorScheme.primary,
              ),
            ],
          ),

          Divider(
            height: 28,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
          ),

          // Rate & Total
          Row(
            children: [
              AppIcon(
                AppIconType.calculator,
                size: 22,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      '₹${_customer.ratePerSqft?.toStringAsFixed(0) ?? "0"}/sqft',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  'Total: ${_formatINR(totalRate)}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinalBadge(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const AppIcon(AppIconType.check, size: 22, color: Color(0xFF10B981)),
          const SizedBox(width: AppSpacing.md),
          Text(
            'Final Measurement',
            style: TextStyle(
              color: const Color(0xFF047857),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(48),
      alignment: Alignment.center,
      child: Column(
        children: [
          AppIcon(
            AppIconType.window,
            size: 56,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No windows added yet',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWindowCard(
    ThemeData theme,
    bool isDark,
    Window window,
    int index,
  ) {
    final rate = _customer.ratePerSqft ?? 0;
    final displayedSqFt =
        (window.width * window.height / 90903.0) * window.quantity;
    final cost = displayedSqFt * rate;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 150 + (index * 30).clamp(0, 200)),
      curve: Curves.easeOut,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 12 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(
              alpha: isDark ? 0.15 : 0.08,
            ),
          ),
        ),
        child: Row(
          children: [
            // W1, W2 Badge - circular like screenshot
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(22),
              ),
              alignment: Alignment.center,
              child: Text(
                window.name,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Dimensions + Type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${window.width.toStringAsFixed(0)} × ${window.height.toStringAsFixed(0)} mm',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Type pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          window.type,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        WindowType.getName(window.type),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Sqft + Cost on right
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${displayedSqFt.toStringAsFixed(2)} sqft',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rs.${cost.toStringAsFixed(0)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showShare(List<Window> windows) {
    Haptics.light();
    showShareBottomSheet(context, _customer, windows);
  }

  void _showPrint(List<Window> windows) {
    Haptics.light();
    showPrintBottomSheet(context, _customer, windows);
  }

  void _editWindows() {
    Haptics.light();
    if (!PermissionHelper().checkAndShowDialog(
      context,
      'edit_window',
      'Edit Windows',
    ))
      return;
    Navigator.push(
      context,
      FastPageRoute(page: WindowInputScreen(customer: _customer)),
    ).then((_) => setState(() {}));
  }

  void _showOptionsMenu(BuildContext context) {
    final theme = Theme.of(context);
    Haptics.selection();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: theme.colorScheme.surface,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MenuTile(
                icon: AppIconType.edit,
                label: 'Edit Customer',
                onTap: () => _editCustomer(context),
              ),
              _MenuTile(
                icon: AppIconType.window,
                label: 'Edit Windows',
                onTap: () {
                  Navigator.pop(context);
                  _editWindows();
                },
              ),
              _MenuTile(
                icon: AppIconType.sparkle,
                label: 'Admin Insights',
                onTap: () {
                  Navigator.pop(context);
                  _showAdminInsights(context);
                },
              ),
              Divider(
                height: 24,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
              ),
              _MenuTile(
                icon: AppIconType.delete,
                label: 'Delete Customer',
                isDestructive: true,
                onTap: () => _deleteCustomer(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editCustomer(BuildContext context) async {
    Navigator.pop(context);
    if (!PermissionHelper().checkAndShowDialog(
      context,
      'edit_customer',
      'Edit Customer',
    ))
      return;
    final updated = await Navigator.push<Customer>(
      context,
      FastPageRoute(page: AddCustomerScreen(customerToEdit: _customer)),
    );
    if (updated != null && mounted) setState(() => _customer = updated);
  }

  Future<void> _deleteCustomer(BuildContext context) async {
    Navigator.pop(context);
    if (!PermissionHelper().checkAndShowDialog(
      context,
      'delete_customer',
      'Delete Customer',
    ))
      return;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Customer?'),
            content: Text('Are you sure you want to delete ${_customer.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed && mounted) {
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).deleteCustomer(_customer.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  void _showAdminInsights(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _AdminInsightsSheet(
          customer: _customer,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

// =============================================================================
// HELPER WIDGETS
// =============================================================================

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(3, (i) => const SkeletonWindowCard()),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final AppIconType icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        AppIcon(
          icon,
          size: 22,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniStatChip extends StatelessWidget {
  final AppIconType icon;
  final String value;
  final String label;
  final Color color;

  const _MiniStatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            AppIcon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final AppIconType icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive ? Colors.red : theme.colorScheme.onSurface;
    return ListTile(
      leading: AppIcon(icon, size: 24, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Haptics.light();
        onTap();
      },
    );
  }
}

class _AdminInsightsSheet extends StatelessWidget {
  final Customer customer;
  final ScrollController scrollController;

  const _AdminInsightsSheet({
    required this.customer,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return FutureBuilder<List<Window>>(
          future: provider.getWindows(customer.id!),
          builder: (context, snapshot) {
            final windows = snapshot.data ?? [];
            final totalQty = windows.fold(0, (sum, w) => sum + w.quantity);

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

            final extraGiven = displayedSqFt - actualSqFt;
            final bonusPercent = actualSqFt > 0
                ? (extraGiven / actualSqFt * 100)
                : 0.0;
            final rate = customer.ratePerSqft ?? 0;
            final chargedAmount = displayedSqFt * rate;
            final actualWorth = actualSqFt * rate;
            final customerBenefit = chargedAmount - actualWorth;

            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
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
                      child: const AppIcon(
                        AppIconType.sparkle,
                        size: 24,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Insights',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          customer.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Stats
                Row(
                  children: [
                    _InsightStat(
                      icon: AppIconType.window,
                      value: '${windows.length}',
                      label: 'Windows',
                    ),
                    const SizedBox(width: 12),
                    _InsightStat(
                      icon: AppIconType.customer,
                      value: '$totalQty',
                      label: 'Total Qty',
                    ),
                    const SizedBox(width: 12),
                    _InsightStat(
                      icon: AppIconType.measurement,
                      value: (displayedSqFt / windows.length.clamp(1, 999))
                          .toStringAsFixed(1),
                      label: 'Avg Sqft',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // SQFT Analysis
                _AnalysisCard(
                  title: 'SQFT ANALYSIS',
                  titleColor: theme.colorScheme.primary,
                  children: [
                    _AnalysisRow(
                      label: 'Displayed to Customer',
                      value: '${displayedSqFt.toStringAsFixed(2)} sqft',
                      color: theme.colorScheme.primary,
                    ),
                    _AnalysisRow(
                      label: 'Actual (Real)',
                      value: '${actualSqFt.toStringAsFixed(2)} sqft',
                      color: const Color(0xFFF59E0B),
                    ),
                    Divider(
                      height: 20,
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.1,
                      ),
                    ),
                    _AnalysisRow(
                      label: 'Extra Given',
                      value: '+${extraGiven.toStringAsFixed(2)} sqft',
                      color: const Color(0xFF10B981),
                    ),
                    _AnalysisRow(
                      label: 'Bonus %',
                      value: '+${bonusPercent.toStringAsFixed(1)}%',
                      color: const Color(0xFF10B981),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cost Analysis
                _AnalysisCard(
                  title: 'COST ANALYSIS',
                  titleColor: const Color(0xFFF59E0B),
                  children: [
                    _AnalysisRow(
                      label: 'Rate per Sqft',
                      value: '₹${rate.toStringAsFixed(0)}',
                      color: theme.colorScheme.onSurface,
                    ),
                    _AnalysisRow(
                      label: 'Charged Amount',
                      value: '₹${chargedAmount.toStringAsFixed(0)}',
                      color: theme.colorScheme.primary,
                    ),
                    _AnalysisRow(
                      label: 'Actual Worth',
                      value: '₹${actualWorth.toStringAsFixed(0)}',
                      color: const Color(0xFFF59E0B),
                    ),
                    Divider(
                      height: 20,
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.1,
                      ),
                    ),
                    _AnalysisRow(
                      label: 'Customer Benefit',
                      value: '₹${customerBenefit.toStringAsFixed(0)}',
                      color: const Color(0xFF10B981),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _InsightStat extends StatelessWidget {
  final AppIconType icon;
  final String value;
  final String label;

  const _InsightStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            AppIcon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final String title;
  final Color titleColor;
  final List<Widget> children;

  const _AnalysisCard({
    required this.title,
    required this.titleColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(
            alpha: isDark ? 0.15 : 0.08,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AnalysisRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
