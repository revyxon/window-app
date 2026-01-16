import '../utils/window_types.dart';

class WindowCalculator {
  // Divisors for SqFt calculation
  static const double _divisorDisplayed = 90903.0; // User's custom formula
  static const double _divisorActual = 92903.04; // Standard Formula

  /// Calculates the SqFt displayed to the customer (using the custom divisor)
  static double calculateDisplayedSqFt({
    required double width,
    required double height,
    required double quantity,
    double width2 = 0.0,
    required String type,
    bool isFormulaA = true, // Default to Formula A for LC if not specified
  }) {
    if (type == WindowType.lCorner) {
      // L-Corner Logic
      /*
       Formula A: ((W1 + W2) * H) / Divisor
       Formula B: ((W1 * H) + (W2 * H)) / Divisor
      */
      double area;
      if (isFormulaA) {
        area = (width + width2) * height;
      } else {
        area = (width * height) + (width2 * height);
      }
      return (area / _divisorDisplayed) * quantity;
    } else {
      // Standard Logic: (W * H) / Divisor
      return ((width * height) / _divisorDisplayed) * quantity;
    }
  }

  /// Calculates the Actual SqFt (using the standard divisor)
  static double calculateActualSqFt({
    required double width,
    required double height,
    required double quantity,
    double width2 = 0.0,
    required String type,
    bool isFormulaA = true,
  }) {
    if (type == WindowType.lCorner) {
      double area;
      if (isFormulaA) {
        area = (width + width2) * height;
      } else {
        area = (width * height) + (width2 * height);
      }
      return (area / _divisorActual) * quantity;
    } else {
      return ((width * height) / _divisorActual) * quantity;
    }
  }
}
