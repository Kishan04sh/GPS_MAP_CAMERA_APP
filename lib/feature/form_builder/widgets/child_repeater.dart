import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/field_renderer.dart';
import '../../../core/modal/child_model.dart';
import '../../../core/modal/field_model.dart';

class ChildRepeater extends StatefulWidget {
  final ChildModel childModel;
  const ChildRepeater({required this.childModel, super.key});

  @override
  State<ChildRepeater> createState() => _ChildRepeaterState();
}

class _ChildRepeaterState extends State<ChildRepeater> {
  List<int> rows = [0];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...rows.map((index) {
          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                ...widget.childModel.fields.map((f) {
                  final childField = FieldModel(
                    fieldname:
                    "${widget.childModel.tableName}[$index].${f.fieldname}",
                    yourlabel: f.yourlabel,
                    controlname: f.controlname,
                    type: f.type,
                    isRequired: f.isRequired,
                    dropDownValues: f.dropDownValues,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FieldRenderer(field: childField),
                  );
                }),

                /// *****************************************************

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(() => rows.remove(index)),
                    icon: const Icon(Icons.delete, color: AppColors.danger),
                    label: const Text(
                      "Remove",
                      style: TextStyle(color: AppColors.danger),
                    ),
                  ),
                )

                /// **********************************************************

              ],
            ),
          );
        }),

/// *******************************************************************

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () =>
              setState(() => rows.add(rows.isNotEmpty ? rows.last + 1 : 0)),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add More", style: TextStyle(color: Colors.white)),
        ),

  /// **************************************************************************************

      ],
    );
  }
}
