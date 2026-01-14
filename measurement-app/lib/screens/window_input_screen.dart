import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'dart:ui';
import '../models/customer.dart';
import '../models/window.dart';
import '../providers/app_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/window_types.dart';

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
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
        );
        Future.delayed(const Duration(milliseconds: 200), () {
          _windowControllers.last.widthFocus.requestFocus();
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

    // Check for L-Corner
    if (c.selectedType == 'LC' || c.selectedType == 'L-Corner') {
      double w2 = double.tryParse(c.width2Controller.text) ?? 0;

      final settings = Provider.of<SettingsProvider>(context, listen: false);
      if (settings.lCornerFormula == 'A') {
        // Formula A: (W1 + W2) * H / 90903
        return ((w + w2) * h) / 90903.0 * c.quantity;
      } else {
        // Formula B: (W1 * H) + (W2 * H) / standard (or displayed?)
        // Assuming standard divisor for sqft calculation
        return ((w * h) + (w2 * h)) / 92903.04 * c.quantity;
      }
    }

    return (w * h) / 92903.04 * c.quantity;
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
    for (var controller in _windowControllers) {
      final w = double.tryParse(controller.widthController.text) ?? 0;
      final h = double.tryParse(controller.heightController.text) ?? 0;

      // For L-Corner, we need W2 as well? Or is it optional? Assuming mandatory if Type is LC
      // But we just check basic W/H > 0 for standard windows.

      if (w > 0 && h > 0) {
        double? w2;
        if (controller.selectedType == 'LC') {
          w2 = double.tryParse(controller.width2Controller.text);
        }

        String? customName;
        if (controller.selectedType == 'CUST') {
          customName = controller.customNameController.text;
          if (customName.isEmpty) customName = 'Custom Window';
        }

        final window = Window(
          id: controller.id,
          customerId: widget.customer.id!,
          name: controller.name,
          width: w,
          height: h,
          type: controller.selectedType,
          width2: w2,
          customName: customName,
          // Formula is stored in Settings, maybe we should store what was used at time of creation?
          // The model has 'formula' field. Let's store it so we know which one was applied.
          formula: (controller.selectedType == 'LC')
              ? Provider.of<SettingsProvider>(
                  context,
                  listen: false,
                ).lCornerFormula
              : null,
          quantity: controller.quantity,
          createdAt: DateTime.now(),
          isOnHold: controller.isOnHold, // Persist hold state
        );

        if (controller.id == null) {
          await Provider.of<AppProvider>(
            context,
            listen: false,
          ).addWindow(window);
        } else {
          await Provider.of<AppProvider>(
            context,
            listen: false,
          ).updateWindow(window);
        }
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
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
          widget.customer.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _saveAll,
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
            )
          : Column(
              children: [
                // Compact Stats Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FluentIcons.grid_20_filled,
                              color: const Color(0xFF2563EB),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$_activeWindowCount',
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Windows',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: const Color(0xFFE5E7EB),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FluentIcons.ruler_20_filled,
                              color: const Color(0xFF2563EB),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _totalSqFt.toStringAsFixed(2),
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Total Sq.Ft',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewWindow(autoFocus: true),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 4,
        child: const Icon(Icons.add, size: 26, color: Colors.white),
      ),
    );
  }

  Widget _buildWindowInputCard(int index) {
    final controller = _windowControllers[index];
    final sqFt = _calculateCardSqFt(controller);
    final isOnHold = controller.isOnHold;

    // Glassmorphic effect when on hold
    if (isOnHold) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.amber.shade50.withAlpha(230),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade400, width: 1.5),
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
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
    // Check if L-Corner or Custom to show extra fields
    final isLCorner =
        controller.selectedType == 'LC' ||
        controller.selectedType == 'L-Corner';
    final isCustom = controller.selectedType == 'CUST';

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
                    ? Colors.amber.shade200
                    : const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                controller.name,
                style: TextStyle(
                  color: isOnHold
                      ? Colors.amber.shade900
                      : const Color(0xFF2563EB),
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
                color: Colors.white,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE5E7EB)),
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
                            ? Colors.black
                            : Colors.grey.shade300,
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
                        vertical: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Text(
                      '×${controller.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => controller.quantity++),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Icon(Icons.add, size: 18, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Hold Button - Bigger icon
            GestureDetector(
              onTap: () => _toggleHold(index),
              child: Icon(
                isOnHold
                    ? FluentIcons.play_circle_24_filled
                    : FluentIcons.pause_circle_24_regular,
                color: isOnHold ? Colors.green : const Color(0xFF6B7280),
                size: 26,
              ),
            ),
            const SizedBox(width: 8),
            // Delete Button - Bigger icon
            GestureDetector(
              onTap: () => _removeWindow(index),
              child: const Icon(
                FluentIcons.delete_24_regular,
                color: Color(0xFFEF4444),
                size: 26,
              ),
            ),
          ],
        ),

        if (isOnHold)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              '⏸ On Hold - Not included in total',
              style: TextStyle(
                color: Color(0xFFB45309),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        const SizedBox(height: 12),

        // Custom Name Input (Only for Custom)
        if (isCustom)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: controller.customNameController,
              focusNode: controller.customNameFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => controller.widthFocus.requestFocus(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ), // +4px
                decoration: _inputDecoration('Width (mm)'),
                onChanged: (val) => setState(() {}),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '×',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 20),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller.heightController,
                focusNode: controller.heightFocus,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.done,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ), // +4px
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              decoration: _inputDecoration('Width 2 (mm)'),
              onChanged: (val) => setState(() {}),
            ),
          ),

        const SizedBox(height: 12),

        // Type Selection Chips
        Row(
          children: ['3T', '2T', 'LC', 'FIX', 'More'].map((type) {
            final isSelected = controller.selectedType == type;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: type != 'More' ? 8 : 0),
                child: GestureDetector(
                  onTap: () {
                    if (type == 'More') {
                      _showMoreTypesMenu(controller);
                    } else {
                      setState(() => controller.selectedType = type);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      type == 'More' ? 'More ▾' : type,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF374151),
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
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 15,
        color: Color(0xFF6B7280),
      ), // Bigger placeholder
      floatingLabelStyle: const TextStyle(
        fontSize: 14, // +8px from before (was 12, now 14)
        color: Color(0xFF2563EB),
        fontWeight: FontWeight.w600,
        backgroundColor: Colors.white,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }

  void _showMoreTypesMenu(WindowInputController controller) {
    // Main types shown as chips
    const mainTypes = ['3T', '2T', 'LC', 'FIX'];

    // Filter remaining types
    final otherTypes = WindowType.all
        .where((t) => !mainTypes.contains(t.code))
        .toList();

    showModalBottomSheet(
      context: context,
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
              const Text(
                'Select Window Type',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Text(
                        type.name, // Show full name in menu
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Hint for Custom
              const Text(
                '* Select "Custom Window" to enter a manual name.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
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
  FocusNode width2Focus;
  FocusNode customNameFocus;

  String selectedType;
  int quantity;
  bool isOnHold;

  WindowInputController({
    this.id,
    required this.name,
    String? width,
    String? height,
    String? width2,
    String? customName,
    this.selectedType = '3T',
    this.quantity = 1,
    this.isOnHold = false,
  }) : widthController = TextEditingController(text: width),
       heightController = TextEditingController(text: height),
       width2Controller = TextEditingController(text: width2),
       customNameController = TextEditingController(text: customName),
       widthFocus = FocusNode(),
       heightFocus = FocusNode(),
       width2Focus = FocusNode(),
       customNameFocus = FocusNode();

  factory WindowInputController.fromWindow(Window w) {
    return WindowInputController(
      id: w.id,
      name: w.name,
      width: w.width > 0 ? w.width.toStringAsFixed(0) : '',
      height: w.height > 0 ? w.height.toStringAsFixed(0) : '',
      width2: w.width2 != null && w.width2! > 0
          ? w.width2!.toStringAsFixed(0)
          : '',
      customName: w.customName,
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
