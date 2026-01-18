import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

enum SnackbarType { success, error, warning, info }

class AppSnackbar {
  static void show(
      BuildContext context, {
        required String message,
        SnackbarType type = SnackbarType.info,
        Duration duration = const Duration(seconds: 2),
      }) {
    Color backgroundColor;
    Icon icon;

    // Type ke hisab se color and icon select karo
    switch (type) {
      case SnackbarType.success:
        backgroundColor = AppColors.success;
        icon = const Icon(Icons.check_circle, color: AppColors.white);
        break;
      case SnackbarType.error:
        backgroundColor = AppColors.error;
        icon = const Icon(Icons.error, color: AppColors.white);
        break;
      case SnackbarType.warning:
        backgroundColor = AppColors.warning;
        icon = const Icon(Icons.warning_amber_rounded, color: AppColors.black);
        break;
      case SnackbarType.info:
      default:
        backgroundColor = AppColors.info;
        icon = const Icon(Icons.info, color: AppColors.white);
        break;
    }

    final snackBar = SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      elevation: 6,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
