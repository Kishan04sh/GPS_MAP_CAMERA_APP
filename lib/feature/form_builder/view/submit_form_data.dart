import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SubmittedDataScreen extends StatelessWidget {
  final Map<String, dynamic> savedValues;

  const SubmittedDataScreen({super.key, required this.savedValues});

  @override
  Widget build(BuildContext context) {
    final grouped = _groupRepeaterData(savedValues);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Submitted Details",
          style: AppTextStyles.title.copyWith(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 8),
        child: ListView(
          children: [
            /// SECTION: PROFILE INFORMATION
            _buildSectionTitle("Profile Information"),

            const SizedBox(height: 8,),

            _buildNormalFields(grouped["normal"]),

            const SizedBox(height: 8,),


            /// SECTION: REPEATERS
            ...grouped["repeaters"].entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(_formatKey(entry.key)),
                  _buildRepeaterList(entry.value),
                ],
              );
            }),

            const SizedBox(height: 25),

            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, savedValues);
                },
                child: const Text(
                  "Edit Form",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // GROUPING NORMAL & REPEATER DATA
  // -------------------------------------------------------------------
  Map<String, dynamic> _groupRepeaterData(Map<String, dynamic> data) {
    final normalFields = <String, dynamic>{};
    final repeaterGroups = <String, List<Map<String, dynamic>>>{};

    data.forEach((key, value) {
      final match = RegExp(r'(.+)\[(\d+)\]\.(.+)').firstMatch(key);

      if (match != null) {
        final section = match.group(1)!;
        final index = int.parse(match.group(2)!);
        final field = match.group(3)!;

        repeaterGroups.putIfAbsent(section, () => []);
        while (repeaterGroups[section]!.length <= index) {
          repeaterGroups[section]!.add({});
        }

        repeaterGroups[section]![index][field] = value;
      } else {
        normalFields[key] = value;
      }
    });

    return {
      "normal": normalFields,
      "repeaters": repeaterGroups,
    };
  }

  // -------------------------------------------------------------------
// NORMAL FIELDS (PREMIUM UI)
// -------------------------------------------------------------------
  Widget _buildNormalFields(Map<String, dynamic> fields) {
    return Column(
      children: fields.entries.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 9,horizontal: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.black12, width: 0.6),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// LABEL
              Expanded(
                flex: 3,
                child: Text(
                  _formatKey(e.key),
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),

              /// VALUE
              Expanded(
                flex: 4,
                child: Text(
                  e.value.toString(),
                  style: AppTextStyles.input.copyWith(
                    fontSize: 15,
                    color: AppColors.textPrimary.withOpacity(0.85),
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // -------------------------------------------------------------------
  // REPEATER ROW LIST
  // -------------------------------------------------------------------
  Widget _buildRepeaterList(List<dynamic> rows) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9,horizontal: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.black12, width: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ENTRY TITLE (with colored dot)
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDark,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Entry ${index + 1}",
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// FIELDS
              ...row.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          _formatKey(e.key),
                          style: AppTextStyles.label.copyWith(
                            fontSize: 14,
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 4,
                        child: Text(
                          e.value.toString(),
                          style: AppTextStyles.input.copyWith(
                            fontSize: 14,
                            color: AppColors.textPrimary.withOpacity(0.9),
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              if (index != rows.length - 1)
                const Divider(height: 32, thickness: 0.8, color: Colors.black12),
            ],
          );
        }).toList(),
      ),
    );
  }


  // -------------------------------------------------------------------
  // TITLE
  // -------------------------------------------------------------------
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: AppTextStyles.sectionTitle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // FORMATTING KEY
  // -------------------------------------------------------------------
  String _formatKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => " ${m.group(0)}")
        .trim()
        .split(' ')
        .map((w) => "${w[0].toUpperCase()}${w.substring(1)}")
        .join(' ');
  }


}
