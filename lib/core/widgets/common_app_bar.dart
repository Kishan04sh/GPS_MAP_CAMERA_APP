import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showDate;
  final List<Widget>? actions;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showDate = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy').format(now);
    final weekDay = DateFormat('EEEE').format(now);

    return AppBar(
      elevation: 3,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.blueActionGradient,
        ),
      ),
      title: Row(
        children: [
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          /// Right Side (Date / Custom Actions)
          if (showDate)
            Row(
              children: [
                const Icon(
                  Icons.wb_sunny_outlined,
                  color: Color(0xFFFFD54F),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      weekDay,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
            ),

          if (actions != null) ...actions!,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
