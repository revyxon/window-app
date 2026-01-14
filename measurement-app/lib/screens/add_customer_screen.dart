import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../models/customer.dart';
import '../providers/app_provider.dart';
import '../utils/fast_page_route.dart';
import '../widgets/premium_toast.dart';
import 'window_input_screen.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

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

  String _selectedFramework = 'Inventa';
  String? _selectedGlassType;
  bool _isFinalMeasurement = false;

  final List<String> _glassTypes = [
    '5MM Clear Glass',
    '5MM Toughened Glass',
    '5MM Clear Toughened Glass',
    '5MM Frosted Glass',
    '5MM Frosted Toughened Glass',
    '5MM Reflective Glass',
  ];

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'New Customer',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18, // Bigger input text
                color: Color(0xFF1F2937),
              ),
              decoration: _buildInputDecoration(
                'Customer Name *',
                Icons.person_outline_rounded,
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter name' : null,
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              focusNode: _locationFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_phoneFocus),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Color(0xFF1F2937),
              ),
              decoration: _buildInputDecoration(
                'Location *',
                Icons.location_on_outlined,
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter location'
                  : null,
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
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Color(0xFF1F2937),
              ),
              decoration: _buildInputDecoration(
                'Phone (Optional)',
                Icons.phone_outlined,
              ),
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
              children: [
                Expanded(child: _buildFrameworkButton('Inventa')),
                const SizedBox(width: 12),
                Expanded(child: _buildFrameworkButton('Optima')),
              ],
            ),
            const SizedBox(height: 24),

            // Glass Type
            DropdownButtonFormField<String>(
              initialValue: _selectedGlassType,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF6B7280),
                size: 26,
              ),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
                fontSize: 18,
              ),
              decoration: _buildInputDecoration(
                'Glass Type (Optional)',
                Icons.layers_outlined,
              ),
              // Add 'Other' option
              items: [..._glassTypes, 'Other'].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => setState(() => _selectedGlassType = value),
            ),

            // Custom Glass Input
            if (_selectedGlassType == 'Other')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextFormField(
                  controller: _customGlassController,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Color(0xFF1F2937),
                  ),
                  decoration: _buildInputDecoration(
                    'Enter Custom Glass Type',
                    Icons.edit_outlined,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Rate
            TextFormField(
              controller: _rateController,
              focusNode: _rateFocus,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Color(0xFF1F2937),
              ),
              decoration: _buildInputDecoration(
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

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 17, // Bigger placeholder
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFF2563EB),
        fontSize: 15, // Bigger floating label - clearly visible on border
        fontWeight: FontWeight.w600,
        backgroundColor: Colors.white,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: Icon(
          icon,
          color: const Color(0xFF374151),
          size: 26,
        ), // Bigger icons
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 50),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      // Use isCollapsed false and proper padding for vertical centering
      isCollapsed: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
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

  Widget _buildFrameworkButton(String label) {
    final isSelected = _selectedFramework == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFramework = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE5E7EB),
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
            color: isSelected ? Colors.white : const Color(0xFF374151),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
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
        final savedCustomer = await Provider.of<AppProvider>(
          context,
          listen: false,
        ).addCustomer(customer);
        if (!mounted) return;

        // loadCustomers is handled inside addCustomer

        Navigator.push(
          context,
          FastPageRoute(page: WindowInputScreen(customer: savedCustomer)),
        );
      } catch (e) {
        ToastService.show(context, 'Error saving customer: $e', isError: true);
      }
    }
  }
}
