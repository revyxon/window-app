import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../providers/app_provider.dart';
import '../utils/fast_page_route.dart';
import '../widgets/premium_toast.dart';
import '../utils/constant_data.dart';
import '../ui/components/app_icon.dart';
import 'window_input_screen.dart';

class AddCustomerScreen extends StatefulWidget {
  final Customer? customerToEdit;

  const AddCustomerScreen({super.key, this.customerToEdit});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rateController = TextEditingController();
  final _customGlassController = TextEditingController();

  final _nameFocus = FocusNode();
  final _locationFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _rateFocus = FocusNode();

  String _selectedFramework = ConstantData.frameworks.first;
  String? _selectedGlassType;
  bool _isFinalMeasurement = false;

  bool get _isEditMode => widget.customerToEdit != null;
  final _phoneRegex = RegExp(r'^(\+91[\-\s]?)?[0-9]{10}$');

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final c = widget.customerToEdit!;
      _nameController.text = c.name;
      _locationController.text = c.location;
      _phoneController.text = c.phone ?? '';
      _selectedFramework = c.framework;
      _selectedGlassType = c.glassType;
      _rateController.text = c.ratePerSqft?.toString() ?? '';
      _isFinalMeasurement = c.isFinalMeasurement;
      if (c.glassType != null &&
          !ConstantData.glassTypes.contains(c.glassType)) {
        _selectedGlassType = 'Other';
        _customGlassController.text = c.glassType!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _rateController.dispose();
    _customGlassController.dispose();
    _nameFocus.dispose();
    _locationFocus.dispose();
    _phoneFocus.dispose();
    _rateFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Customer' : 'New Customer',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // ═══════════════════════════════════════════════════════════════
            // BASIC INFORMATION SECTION
            // ═══════════════════════════════════════════════════════════════
            _SectionHeader(
              icon: AppIconType.customer,
              title: 'Basic Information',
              theme: theme,
            ),
            const SizedBox(height: 12),

            // Customer Name
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_locationFocus),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              decoration: _buildInputDecoration(
                context,
                'Customer Name *',
                AppIconType.customer,
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Please enter name' : null,
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              focusNode: _locationFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_phoneFocus),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              decoration: _buildInputDecoration(
                context,
                'Location *',
                AppIconType.location,
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Please enter location' : null,
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_rateFocus),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              decoration: _buildInputDecoration(
                context,
                'Phone (Optional)',
                AppIconType.phone,
              ),
              validator: (v) {
                if (v != null && v.isNotEmpty && !_phoneRegex.hasMatch(v))
                  return 'Invalid phone';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // ═══════════════════════════════════════════════════════════════
            // FRAMEWORK SECTION (ORIGINAL STYLE)
            // ═══════════════════════════════════════════════════════════════
            const Text(
              'Framework',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: ConstantData.frameworks.map((f) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: f == ConstantData.frameworks.last ? 0 : 12,
                    ),
                    child: _buildFrameworkButton(context, f),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ═══════════════════════════════════════════════════════════════
            // GLASS & PRICING SECTION
            // ═══════════════════════════════════════════════════════════════
            _SectionHeader(
              icon: AppIconType.sparkle,
              title: 'Glass & Pricing',
              theme: theme,
            ),
            const SizedBox(height: 12),

            // Glass Type Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedGlassType,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? Colors.grey.shade400 : const Color(0xFF6B7280),
                size: 26,
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              decoration: _buildInputDecoration(
                context,
                'Glass Type (Optional)',
                AppIconType.sparkle,
              ),
              items: [
                ...ConstantData.glassTypes,
                'Other',
              ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _selectedGlassType = v),
            ),

            if (_selectedGlassType == 'Other') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _customGlassController,
                textInputAction: TextInputAction.next,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                decoration: _buildInputDecoration(
                  context,
                  'Custom Glass Type',
                  AppIconType.edit,
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Rate
            TextFormField(
              controller: _rateController,
              focusNode: _rateFocus,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              decoration: _buildInputDecoration(
                context,
                'Rate per Sq.Ft (Optional)',
                AppIconType.calculator,
              ),
            ),
            const SizedBox(height: 24),

            // ═══════════════════════════════════════════════════════════════
            // FINAL MEASUREMENT CARD (ORIGINAL STYLE)
            // ═══════════════════════════════════════════════════════════════
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Final Measurement',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Mark if client will not call again for re-measurement',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.9,
                    child: Switch(
                      value: _isFinalMeasurement,
                      activeThumbColor: Colors.white,
                      activeTrackColor: theme.colorScheme.primary,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: theme.colorScheme.outlineVariant,
                      trackOutlineColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      onChanged: (v) => setState(() => _isFinalMeasurement = v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saveCustomer,
              child: Text(
                _isEditMode ? 'Save Changes' : 'Next → Add Windows',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrameworkButton(BuildContext context, String label) {
    final isSelected = _selectedFramework == label;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() => _selectedFramework = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context,
    String label,
    AppIconType icon,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? const Color(0xFF374151)
        : const Color(0xFFE5E7EB);
    final fillColor = isDark
        ? const Color(0xFF1F2937)
        : const Color(0xFFF9FAFB);
    final hintColor = isDark
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF6B7280);
    final iconColor = isDark
        ? const Color(0xFFD1D5DB)
        : const Color(0xFF374151);

    return InputDecoration(
      labelText: label,
      alignLabelWithHint: true,
      labelStyle: TextStyle(
        color: hintColor,
        fontSize: 17,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: TextStyle(
        color: theme.colorScheme.primary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: AppIcon(icon, size: 26, color: iconColor),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 50),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      errorStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    );
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final glassType = _selectedGlassType == 'Other'
        ? _customGlassController.text.trim()
        : _selectedGlassType;
    final rate = double.tryParse(_rateController.text.trim());

    if (_isEditMode) {
      final updated = widget.customerToEdit!.copyWith(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        framework: _selectedFramework,
        glassType: glassType,
        ratePerSqft: rate,
        isFinalMeasurement: _isFinalMeasurement,
      );
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).updateCustomer(updated);
      if (!mounted) return;
      Navigator.pop(context, updated);
      ToastService.show(context, 'Customer updated!');
    } else {
      final customer = Customer(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        framework: _selectedFramework,
        glassType: glassType,
        ratePerSqft: rate,
        isFinalMeasurement: _isFinalMeasurement,
        createdAt: DateTime.now(),
      );
      final saved = await Provider.of<AppProvider>(
        context,
        listen: false,
      ).addCustomer(customer);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        FastPageRoute(page: WindowInputScreen(customer: saved)),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION HEADER WIDGET
// ═══════════════════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final AppIconType icon;
  final String title;
  final ThemeData theme;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIcon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
