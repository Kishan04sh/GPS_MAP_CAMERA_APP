import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../viewmodel/form_providers.dart';
import '../../../core/modal/field_model.dart';

class FieldRenderer extends ConsumerWidget {
  final FieldModel field;
  const FieldRenderer({required this.field, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(formValuesNotifierProvider.notifier);
    final values = ref.watch(formValuesNotifierProvider);
    final current = values[field.fieldname];

    final decoration = InputDecoration(
      labelText: field.yourlabel,
      labelStyle: AppTextStyles.label,
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    );

    switch (field.controlname) {
      case "text":
        return TextFormField(
          initialValue: current?.toString(),
          keyboardType:
          field.type == "number" ? TextInputType.number : TextInputType.text,
          decoration: decoration,
          style: AppTextStyles.input,
          onChanged: (v) => notifier.setValue(field.fieldname, v),
          validator: field.isRequired
              ? (v) => (v == null || v.isEmpty) ? "Required" : null
              : null,
        );

      case "dropdown":
        return DropdownButtonFormField(
          value: current,
          decoration: decoration,
          items: field.dropDownValues
              .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
              .toList(),
          onChanged: (v) => notifier.setValue(field.fieldname, v),
          validator: field.isRequired ? (v) => v == null ? "Required" : null : null,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
