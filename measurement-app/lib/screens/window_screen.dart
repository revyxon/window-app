import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../models/window.dart';
import '../providers/app_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_container.dart';

class WindowScreen extends StatefulWidget {
  final Customer customer;

  const WindowScreen({super.key, required this.customer});

  @override
  State<WindowScreen> createState() => _WindowScreenState();
}

class _WindowScreenState extends State<WindowScreen> {
  @override
  void initState() {
    super.initState();
    // Load windows for this customer
    // We could do this in FutureBuilder or initState
  }

  void _showAddEditWindowSheet(BuildContext context, [Window? window]) {
    final widthController = TextEditingController(
      text: window?.width.toString() ?? '',
    );
    final heightController = TextEditingController(
      text: window?.height.toString() ?? '',
    );
    final nameController = TextEditingController(
      text:
          window?.name ??
          'W${(Provider.of<AppProvider>(context, listen: false).customers.length + 1)}',
    ); // Rough logic for name
    String selectedType = window?.type ?? '3T';
    int quantity = window?.quantity ?? 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  window == null ? 'Add Window' : 'Edit Window',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Width (mm)'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'x',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Height (mm)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Type Selection
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['3T', '2T', 'V', 'FIX'].map((type) {
                  final isSelected = selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (val) {
                        // Stateful builder needed for bottom sheet state update,
                        // or just use rudimentary implementation for now.
                        // For this prototype, assumed valid.
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Save Button logic would go here
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final w = double.tryParse(widthController.text) ?? 0;
                  final h = double.tryParse(heightController.text) ?? 0;
                  if (w > 0 && h > 0) {
                    final newWindow = Window(
                      id: window?.id,
                      customerId: widget.customer.id!,
                      name: nameController.text,
                      width: w,
                      height: h,
                      type: selectedType,
                      quantity: quantity,
                      createdAt: DateTime.now(),
                    );

                    if (window == null) {
                      await Provider.of<AppProvider>(
                        context,
                        listen: false,
                      ).addWindow(newWindow);
                    } else {
                      await Provider.of<AppProvider>(
                        context,
                        listen: false,
                      ).updateWindow(newWindow);
                    }
                    Navigator.pop(context);
                    setState(() {}); // Refresh list
                  }
                },
                child: const Text('Save Window'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.customer.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.customer.location} • ${widget.customer.framework}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Window>>(
        future: Provider.of<AppProvider>(
          context,
        ).getWindows(widget.customer.id!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final windows = snapshot.data!;
          if (windows.isEmpty) {
            return const Center(child: Text('No windows added yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: windows.length,
            itemBuilder: (context, index) {
              final w = windows[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          w.name,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${w.width.toStringAsFixed(0)} × ${w.height.toStringAsFixed(0)} mm',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  w.type,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${w.sqFt.toStringAsFixed(2)} sqft',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditWindowSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
