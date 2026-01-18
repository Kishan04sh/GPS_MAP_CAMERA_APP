import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/app_animated_loader.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../widgets/home_action_card.dart';


class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.blueActionGradient.colors
              .map((c) => c.withOpacity(0.08))
              .toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          HomeActionCard(
            title: 'Camera',
            icon: Icons.camera_alt_rounded,
            // isPrimary: true,
            onTap: () {
              context.push(RouteNames.camera);
            },
          ),
          HomeActionCard(
            title: 'Gallery',
            icon: Icons.photo_library_rounded,
            onTap: () async {
              AppAnimatedLoader.show(context, message: "Preparing your location image...");
              await Future.delayed(const Duration(milliseconds: 1000));
              AppAnimatedLoader.hide(context);
              AppSnackbar.show(
                context,
                message: 'Gallery opened',
                type: SnackbarType.success,
              );
            },
          ),
          HomeActionCard(
            title: 'Map',
            icon: Icons.map_rounded,
            onTap: () {
              AppSnackbar.show(
                context,
                message: 'Map opened',
                type: SnackbarType.success,
              );
            },
          ),
          HomeActionCard(
            title: 'Settings',
            icon: Icons.settings_rounded,
            onTap: () {
              AppSnackbar.show(
                context,
                message: 'Settings opened',
                type: SnackbarType.success,
              );
            },
          ),
        ],
      ),
    );
  }
}



