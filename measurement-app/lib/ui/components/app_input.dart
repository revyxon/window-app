import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/spacing.dart';

/// A standardized text input with consistent styling.
///
/// Features:
/// - Clear focus states
/// - Error handling
/// - Suffix/prefix support
/// - 48dp minimum touch target
class AppInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const AppInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefix,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: Spacing.sm),
        ],
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          enabled: enabled,
          autofocus: autofocus,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          onTap: onTap,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefix,
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

/// A compact number input optimized for measurements.
class AppNumberInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? suffix;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;

  const AppNumberInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.suffix,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppInput(
      controller: controller,
      label: label,
      hint: hint,
      suffix: suffix != null
          ? Padding(
              padding: const EdgeInsets.only(right: Spacing.md),
              child: Text(
                suffix!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : null,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      onChanged: onChanged,
      focusNode: focusNode,
      autofocus: autofocus,
    );
  }
}
