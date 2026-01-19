import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// import 'package:fluentui_system_icons/fluentui_system_icons.dart'; // Removed as we use AppIcon
import 'dart:ui';
import '../models/customer.dart';
import '../models/window.dart';
import '../providers/app_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/window_types.dart';
import '../utils/window_calculator.dart';
import '../ui/components/app_icon.dart';

class WindowInputScreen extends StatefulWidget {
  final Customer customer;

  const WindowInputScreen({super.key, required this.customer});

  @override
  State<WindowInputScreen> createState() => _WindowInputScreenState();
}

class _WindowInputScreenState extends State<WindowInputScreen> {
  List<WindowInputController> _windowControllers = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadWindows();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var c in _windowControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadWindows() async {
    final windows = await Provider.of<AppProvider>(
      context,
      listen: false,
    ).getWindows(widget.customer.id!);
    if (!mounted) return;
    setState(() {
      _windowControllers = windows
          .map((w) => WindowInputController.fromWindow(w))
          .toList();
      if (_windowControllers.isEmpty) {
        _addNewWindow(autoFocus: false);
      }
      _isLoading = false;
    });
  }

  void _addNewWindow({bool autoFocus = true}) {
    setState(() {
      int nextNum = _windowControllers.length + 1;
      _windowControllers.add(WindowInputController(name: 'W$nextNum'));
    });

    if (autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
          );
        }
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && _windowControllers.isNotEmpty) {
            _windowControllers.last.widthFocus.requestFocus();
          }
        });
      });
    }
  }

  void _removeWindow(int index) async {
    final controller = _windowControllers[index];
    if (controller.id != null) {
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).deleteWindow(controller.id!);
    }
    if (!mounted) return;
    setState(() {
      _windowControllers[index].dispose();
      _windowControllers.removeAt(index);
      for (int i = 0; i < _windowControllers.length; i++) {
        _windowControllers[i].name = 'W${i + 1}';
      }
    });
  }

  void _toggleHold(int index) {
    setState(() {
      _windowControllers[index].isOnHold = !_windowControllers[index].isOnHold;
    });
  }

  double _calculateCardSqFt(WindowInputController c) {
    double w = double.tryParse(c.widthController.text) ?? 0;
    double h = double.tryParse(c.heightController.text) ?? 0;
    double w2 = 0;

    if (c.selectedType == WindowType.lCorner) {
      w2 = double.tryParse(c.width2Controller.text) ?? 0;
    }

    final settings = Provider.of<SettingsProvider>(context, listen: false);

    return WindowCalculator.calculateDisplayedSqFt(
      width: w,
      height: h,
      quantity: c.quantity.toDouble(),
      width2: w2,
      type: c.selectedType,
      isFormulaA: settings.lCornerFormula == 'A',
    );
  }

  double get _totalSqFt {
    double total = 0;
    for (var c in _windowControllers) {
      if (!c.isOnHold) {
        total += _calculateCardSqFt(c);
      }
    }
    return total;
  }

  int get _activeWindowCount {
    return _windowControllers.where((c) => !c.isOnHold).length;
  }

  Future<void> _saveAll() async {
    // Validate current inputs before saving? User didn't ask for validation changes.
    // Preserving logic.

    final List<Window> windowsToSave = [];

    for (var controller in _windowControllers) {
      final w = double.tryParse(controller.widthController.text) ?? 0;
      final h = double.tryParse(controller.heightController.text) ?? 0;

      if (w > 0 && h > 0) {
        double? w2;
        if (controller.selectedType == WindowType.lCorner) {
          w2 = double.tryParse(controller.width2Controller.text);
        }

        String? customName;
        if (controller.selectedType == WindowType.custom) {
          customName = controller.customNameController.text;
          if (customName.isEmpty) customName = 'Custom Window';
        }

        windowsToSave.add(
          Window(
            id: controller.id,
            customerId: widget.customer.id!,
            name: controller.name,
            width: w,
            height: h,
            type: controller.selectedType,
            width2: w2,
            customName: customName,
            formula: (controller.selectedType == WindowType.lCorner)
                ? Provider.of<SettingsProvider>(
                    context,
                    listen: false,
                  ).lCornerFormula
                : null,
            quantity: controller.quantity,
            createdAt: DateTime.now(),
            isOnHold: controller.isOnHold,
          ),
        );
      }
    }

    if (windowsToSave.isNotEmpty) {
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).saveWindows(widget.customer.id!, windowsToSave);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: AppIcon(AppIconType.back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.customer.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _saveAll,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  // Compact Stats Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      border: Border(
                        bottom: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppIcon(
                                AppIconType.icons,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$_activeWindowCount',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Windows',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: theme.dividerColor,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppIcon(
                                AppIconType.measurement,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _totalSqFt.toStringAsFixed(2),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Total Sq.Ft',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Window Cards List
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _windowControllers.length,
                      itemBuilder: (context, index) =>
                          _buildWindowInputCard(index),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewWindow(autoFocus: true),
        backgroundColor: theme.colorScheme.primary,
        elevation: 4,
        child: const AppIcon(AppIconType.add, size: 26, color: Colors.white),
      ),
    );
  }

  Widget _buildWindowInputCard(int index) {
    final controller = _windowControllers[index];
    final sqFt = _calculateCardSqFt(controller);
    final isOnHold = controller.isOnHold;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Glassmorphic effect when on hold
    if (isOnHold) {
      // Keep original amber style but adapting for dark mode readability if needed
      // Or keeping it consistent with light mode if that was the design
      // Let's use amber containers with alpha to make it look nicer
      final holdBg = isDark
          ? Colors.amber.shade900.withValues(alpha: 0.3)
          : Colors.amber.shade50.withValues(alpha: 0.9);
      final holdBorder = isDark ? Colors.amber.shade700 : Colors.amber.shade400;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              decoration: BoxDecoration(
                color: holdBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: holdBorder, width: 1.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: _buildCardContent(index, controller, sqFt, isOnHold),
            ),
          ),
        ),
      );
    }

    // Normal card
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outlineVariant
              : const Color(0xFFE5E7EB),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: _buildCardContent(index, controller, sqFt, isOnHold),
    );
  }

  Widget _buildCardContent(
    int index,
    WindowInputController controller,
    double sqFt,
    bool isOnHold,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check if L-Corner or Custom to show extra fields
    final isLCorner =
        controller.selectedType == WindowType.lCorner ||
        controller.selectedType == 'L-Corner';
    final isCustom = controller.selectedType == WindowType.custom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: W1 | sqft badge | spacer | qty | hold | delete
        Row(
          children: [
            // Window Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isOnHold
                    ? (isDark
                          ? Colors.amber.shade900.withValues(alpha: 0.5)
                          : Colors.amber.shade200)
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                controller.name,
                style: TextStyle(
                  color: isOnHold
                      ? (isDark ? Colors.amber.shade100 : Colors.amber.shade900)
                      : theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Sq.Ft Badge with outline border
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF10B981), width: 1),
              ),
              child: Text(
                '${sqFt.toStringAsFixed(2)} sqft',
                style: const TextStyle(
                  color: Color(0xFF059669),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const Spacer(),
            // Quantity Controls
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark
                      ? theme.colorScheme.outlineVariant
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: controller.quantity > 1
                        ? () => setState(() => controller.quantity--)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Icon(
                        Icons.remove,
                        size: 18,
                        color: controller.quantity > 1
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        vertical: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                    child: Text(
                      '×${controller.quantity}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => controller.quantity++),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Icon(
                        Icons.add,
                        size: 18,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Hold Button
            GestureDetector(
              onTap: () => _toggleHold(index),
              child: Icon(
                isOnHold
                    ? Icons.play_circle_filled
                    : Icons.pause_circle_outline,
                color: isOnHold
                    ? Colors.green
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 26,
              ),
            ),

            const SizedBox(width: 8),
            // Delete Button
            GestureDetector(
              onTap: () => _removeWindow(index),
              child: AppIcon(
                AppIconType.delete,
                color: theme.colorScheme.error,
                size: 26,
              ),
            ),
          ],
        ),

        if (isOnHold)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '⏸ On Hold - Not included in total',
              style: TextStyle(
                color: isDark ? Colors.amber.shade200 : const Color(0xFFB45309),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        const SizedBox(height: 12),

        // Custom Name Input
        if (isCustom)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: controller.customNameController,
              focusNode: controller.customNameFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => controller.widthFocus.requestFocus(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
              decoration: _inputDecoration('Window Name (e.g. Kitchen)'),
              onChanged: (val) => setState(() {}),
            ),
          ),

        // Width × Height Inputs
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.widthController,
                focusNode: controller.widthFocus,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  if (isLCorner) {
                    controller.width2Focus.requestFocus();
                  } else {
                    controller.heightFocus.requestFocus();
                  }
                },
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: _inputDecoration('Width (mm)'),
                onChanged: (val) => setState(() {}),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '×',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 20,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller.heightController,
                focusNode: controller.heightFocus,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.done,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: _inputDecoration('Height (mm)'),
                onChanged: (val) => setState(() {}),
              ),
            ),
          ],
        ),

        // Width 2 for L-Corner
        if (isLCorner)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextField(
              controller: controller.width2Controller,
              focusNode: controller.width2Focus,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => controller.heightFocus.requestFocus(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
              decoration: _inputDecoration('Width 2 (mm)'),
              onChanged: (val) => setState(() {}),
            ),
          ),

        const SizedBox(height: 12),

        // Type Selection Chips
        Row(
          children: ['3T', '2T', 'FIX', 'V', 'More'].map((typeCode) {
            final isSelected = controller.selectedType == typeCode;
            final unselectedBg = theme.colorScheme.surfaceContainerHighest;
            final unselectedBorder = isDark
                ? theme.colorScheme.outlineVariant
                : const Color(0xFFE5E7EB);
            final unselectedText = theme.colorScheme.onSurface;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    if (typeCode == 'More') {
                      _showMoreTypesMenu(controller);
                    } else {
                      setState(() {
                        controller.selectedType = typeCode;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : unselectedBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : unselectedBorder,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      typeCode == 'More' ? 'More ▾' : typeCode,
                      style: TextStyle(
                        color: isSelected ? Colors.white : unselectedText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hintColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    // Use surface color for fill, or slight variation
    final fillColor = isDark ? theme.colorScheme.surface : Colors.white;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 15, color: hintColor),
      floatingLabelStyle: TextStyle(
        fontSize: 14,
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
        backgroundColor: theme
            .scaffoldBackgroundColor, // Ensure label background matches scaffold to hide line
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark
              ? theme.colorScheme.outlineVariant
              : const Color(0xFFE5E7EB),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark
              ? theme.colorScheme.outlineVariant
              : const Color(0xFFE5E7EB),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
    );
  }

  void _showMoreTypesMenu(WindowInputController controller) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Main types shown as chips
    const mainTypes = ['3T', '2T', 'LC', 'FIX'];

    // Filter remaining types
    final otherTypes = WindowType.all
        .where((t) => !mainTypes.contains(t.code))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Window Type',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: otherTypes.map((type) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => controller.selectedType = type.code);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? theme.colorScheme.outlineVariant
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        type.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Hint for Custom
              Text(
                '* Select "Custom Window" to enter a manual name.',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

class WindowInputController {
  final String? id;
  String name;
  TextEditingController widthController;
  TextEditingController heightController;
  TextEditingController width2Controller; // New for LC
  TextEditingController customNameController; // New for CUST

  FocusNode widthFocus;
  FocusNode heightFocus;
  FocusNode width2Focus; // New
  FocusNode customNameFocus; // New

  String selectedType;
  int quantity;
  bool isOnHold;

  WindowInputController({
    this.id,
    required this.name,
    String? initialWidth,
    String? initialHeight,
    String? initialWidth2,
    String? initialCustomName,
    this.selectedType = '3T',
    this.quantity = 1,
    this.isOnHold = false,
  }) : widthController = TextEditingController(text: initialWidth),
       heightController = TextEditingController(text: initialHeight),
       width2Controller = TextEditingController(text: initialWidth2),
       customNameController = TextEditingController(text: initialCustomName),
       widthFocus = FocusNode(),
       heightFocus = FocusNode(),
       width2Focus = FocusNode(),
       customNameFocus = FocusNode();

  factory WindowInputController.fromWindow(Window w) {
    return WindowInputController(
      id: w.id,
      name: w.name,
      initialWidth: w.width.toString(),
      initialHeight: w.height.toString(),
      initialWidth2: w.width2?.toString(),
      initialCustomName: w.customName,
      selectedType: w.type,
      quantity: w.quantity,
      isOnHold: w.isOnHold,
    );
  }

  void dispose() {
    widthController.dispose();
    heightController.dispose();
    width2Controller.dispose();
    customNameController.dispose();
    widthFocus.dispose();
    heightFocus.dispose();
    width2Focus.dispose();
    customNameFocus.dispose();
  }
}
