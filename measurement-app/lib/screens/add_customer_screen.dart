import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../providers/app_provider.dart';
import '../utils/fast_page_route.dart';
import '../widgets/premium_toast.dart';
import '../utils/constant_data.dart';
import 'window_input_screen.dart';

class AddCustomerScreen extends StatefulWidget {
  /// Pass a customer to edit, or null to create new
  final Customer? customerToEdit;

  const AddCustomerScreen({super.key, this.customerToEdit});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rateController = TextEditingController();
  final _customGlassController = TextEditingController();

  // FocusNodes for Enter key navigation
  final _nameFocus = FocusNode();
  final _locationFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _rateFocus = FocusNode();

  String _selectedFramework = ConstantData.frameworks.first;
  String? _selectedGlassType;
  bool _isFinalMeasurement = false;

  // Regex for Indian Phone Numbers (10 digits, optional +91)
  final _phoneRegex = RegExp(r'^(\+91[\-\s]?)?[0-9]{10}$');

  bool get _isEditMode => widget.customerToEdit != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if editing
    if (_isEditMode) {
      final c = widget.customerToEdit!;
      _nameController.text = c.name;
      _locationController.text = c.location;
      _phoneController.text = c.phone ?? '';
      _rateController.text = c.ratePerSqft?.toString() ?? '';
      _selectedFramework = c.framework;
      _isFinalMeasurement = c.isFinalMeasurement;
      // Handle glass type - check if it's a custom value
      if (c.glassType != null &&
          !ConstantData.glassTypes.contains(c.glassType)) {
        _selectedGlassType = 'Other';
        _customGlassController.text = c.glassType!;
      } else {
        _selectedGlassType = c.glassType;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final inputTextColor = isDark ? Colors.white : const Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Customer' : 'New Customer',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: textColor,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // Customer Name - NO SizedBox to prevent shrinking on error
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_locationFocus),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: inputTextColor,
              ),
              decoration: _buildInputDecoration(
                context,
                'Customer Name *',
                Icons.person_outline_rounded,
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter name' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _locationController,
              focusNode: _locationFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_phoneFocus),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: inputTextColor,
              ),
              decoration: _buildInputDecoration(
                context,
                'Location *',
                Icons.location_on_outlined,
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter location'
                  : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_rateFocus),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: inputTextColor,
              ),
              decoration: _buildInputDecoration(
                context,
                'Phone (Optional)',
                Icons.phone_outlined,
              ),
              validator: (val) {
                if (val != null && val.isNotEmpty) {
                  // Only validate if user entered something
                  if (!_phoneRegex.hasMatch(val)) {
                    return 'Enter valid 10-digit number';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Framework Section
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

            DropdownButtonFormField<String>(
              initialValue: _selectedGlassType,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? Colors.grey.shade400 : const Color(0xFF6B7280),
                size: 26,
              ),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: inputTextColor,
                fontSize: 18,
              ),
              decoration: _buildInputDecoration(
                context,
                'Glass Type (Optional)',
                Icons.layers_outlined,
              ),
              items: [...ConstantData.glassTypes, 'Other'].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => setState(() => _selectedGlassType = value),
            ),

            if (_selectedGlassType == 'Other')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextFormField(
                  controller: _customGlassController,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: inputTextColor,
                  ),
                  decoration: _buildInputDecoration(
                    context,
                    'Enter Custom Glass Type',
                    Icons.edit_outlined,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _rateController,
              focusNode: _rateFocus,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: inputTextColor,
              ),
              decoration: _buildInputDecoration(
                context,
                'Rate per Sq.Ft (Optional)',
                Icons.currency_rupee_rounded,
              ),
            ),
            const SizedBox(height: 24),

            // Final Measurement Card
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
                      activeTrackColor: const Color(0xFF2563EB),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFFD1D5DB),
                      trackOutlineColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      onChanged: (val) =>
                          setState(() => _isFinalMeasurement = val),
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
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saveCustomer,
              child: const Text(
                'Next → Add Windows',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.grey.shade400 : const Color(0xFF6B7280);
    final iconColor = isDark ? Colors.grey.shade400 : const Color(0xFF374151);
    final fillColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFF9FAFB);
    final borderColor = isDark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFE5E7EB);
    final floatingLabelBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: labelColor,
        fontSize: 17,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: TextStyle(
        color: const Color(0xFF2563EB),
        fontSize: 15,
        fontWeight: FontWeight.w600,
        backgroundColor: floatingLabelBg,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: Icon(icon, color: iconColor, size: 26),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 50),
      filled: true,
      fillColor: fillColor,
      isCollapsed: false,
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
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
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

  Widget _buildFrameworkButton(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedFramework == label;
    final unselectedBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final unselectedBorder = isDark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFE5E7EB);
    final unselectedText = isDark ? Colors.white70 : const Color(0xFF374151);

    return GestureDetector(
      onTap: () => setState(() => _selectedFramework = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : unselectedBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : unselectedBorder,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withAlpha(64),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : unselectedText,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AppProvider>(context, listen: false);

      if (_isEditMode) {
        // UPDATE existing customer
        final updated = widget.customerToEdit!.copyWith(
          name: _nameController.text.trim(),
          location: _locationController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          framework: _selectedFramework,
          glassType: _selectedGlassType == 'Other'
              ? _customGlassController.text.trim()
              : _selectedGlassType,
          ratePerSqft: _rateController.text.trim().isEmpty
              ? null
              : double.tryParse(_rateController.text.trim()),
          isFinalMeasurement: _isFinalMeasurement,
          updatedAt: DateTime.now(),
        );

        try {
          await provider.updateCustomer(updated);
          if (!mounted) return;
          ToastService.show(context, 'Customer updated successfully');
          Navigator.pop(context, updated); // Return updated customer
        } catch (e) {
          ToastService.show(
            context,
            'Error updating customer: $e',
            isError: true,
          );
        }
      } else {
        // CREATE new customer
        final customer = Customer(
          name: _nameController.text.trim(),
          location: _locationController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          framework: _selectedFramework,
          glassType: _selectedGlassType == 'Other'
              ? _customGlassController.text.trim()
              : _selectedGlassType,
          ratePerSqft: _rateController.text.trim().isEmpty
              ? null
              : double.tryParse(_rateController.text.trim()),
          isFinalMeasurement: _isFinalMeasurement,
          createdAt: DateTime.now(),
        );

        try {
          final savedCustomer = await provider.addCustomer(customer);
          if (!mounted) return;

          Navigator.push(
            context,
            FastPageRoute(page: WindowInputScreen(customer: savedCustomer)),
          );
        } catch (e) {
          ToastService.show(
            context,
            'Error saving customer: $e',
            isError: true,
          );
        }
      }
    }
  }
}
