
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_map_camera/feature/form_builder/view/submit_form_data.dart';
import '../../../core/modal/field_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_error.dart';
import '../../../core/theme/app_loader.dart';
import '../../../core/theme/app_text_styles.dart';
import '../viewmodel/form_providers.dart';
import '../widgets/child_repeater.dart';
import '../widgets/field_renderer.dart';

class DynamicFormScreen extends ConsumerStatefulWidget {
  const DynamicFormScreen({super.key});

  @override
  ConsumerState<DynamicFormScreen> createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends ConsumerState<DynamicFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, bool> _expandedMap = {};

  @override
  Widget build(BuildContext context) {
    final formAsync = ref.watch(formModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 1,
        title: const Text("Profile Form", style: AppTextStyles.title),
      ),
      body: formAsync.when(
        loading: () => const AppLoader(),
        error: (err, _) => AppError(message: err.toString()),
        data: (form) {
          final Map<String, List<FieldModel>> sections = {};
          for (var f in form!.fields) {
            final key = f.sectionHeader ?? "Other";
            sections.putIfAbsent(key, () => []);
            sections[key]!.add(f);
            _expandedMap.putIfAbsent(key, () => true);
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // Sections
                ...sections.entries.map((entry) => _buildSectionCard(entry.key, entry.value)),
                // Child sections (repeaters)
                ...form.child.map((child) => _buildChildSection(child)),

                const SizedBox(height: 24),
                /// Submit button ************************************************
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final values = ref.read(formValuesNotifierProvider);
                      final formModel = ref.read(formModelProvider).value!;
                      final json = formModel.toJson();
                      json["savedValues"] = values;
                      await ref.read(formModelProvider.notifier).saveModel(json);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubmittedDataScreen(
                            savedValues: values,
                          ),
                        ),
                      );
                    }
                  },

                  child: const Text(
                    "Submit",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),

            /// ******************************************************************
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ===== Section Card with collapse =====*************************************************
  Widget _buildSectionCard(String title, List<FieldModel> fields) {
    final isExpanded = _expandedMap[title] ?? true;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expandedMap[title] = !isExpanded),
            child: Container(
              padding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  Expanded(
                      child: Text(title, style: AppTextStyles.sectionTitle.copyWith(color: Colors.white))),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                children: fields
                    .map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: FieldRenderer(field: f),
                ))
                    .toList(),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  /// ===== Child Section (Repeater) =====****************************************************
  Widget _buildChildSection(child) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    child.childHeading,
                    style: AppTextStyles.sectionTitle.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          ChildRepeater(childModel: child),
        ],
      ),
    );
  }

  /// ********************************************************************************************
}
