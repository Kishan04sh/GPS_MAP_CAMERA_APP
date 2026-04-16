
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';


class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04), // responsive padding
      decoration: BoxDecoration(
        gradient: AppColors.blueActionGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // ================= AVATAR =================
          CircleAvatar(
            radius: screenWidth * 0.08, // responsive size
            backgroundColor: Colors.white,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),

          SizedBox(width: screenWidth * 0.04),

          // ================= TEXT =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}