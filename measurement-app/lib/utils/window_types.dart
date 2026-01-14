class WindowType {
  final String code;
  final String name;
  final bool requiresWidth2;
  final bool isCustom;

  const WindowType({
    required this.code,
    required this.name,
    this.requiresWidth2 = false,
    this.isCustom = false,
  });

  static const List<WindowType> all = [
    WindowType(code: '3T', name: '3 Track Window'),
    WindowType(code: '2T', name: '2 Track Window'),
    WindowType(code: 'V', name: 'Ventilation'),
    WindowType(code: 'FIX', name: 'Fixed'),
    WindowType(code: 'OP', name: 'Openable'),
    WindowType(code: 'LC', name: 'L-Corner', requiresWidth2: true),
    WindowType(code: 'TT', name: 'Tilt & Turn'),
    WindowType(code: 'TH', name: 'Top Hung'),
    WindowType(code: 'SD', name: 'Sliding Door'),
    WindowType(code: 'CUST', name: 'Custom Window', isCustom: true),
  ];

  static String getName(String code) {
    if (code == 'CUST') return 'Custom Window'; // Or handle dynamically if customName is stored elsewhere
    return all.firstWhere(
      (t) => t.code == code,
      orElse: () => WindowType(code: code, name: code),
    ).name;
  }
}
