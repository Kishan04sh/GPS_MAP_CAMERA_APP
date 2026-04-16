import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../widgets/home_action_card.dart';
import 'home_screen.dart';


class HomeTab extends ConsumerWidget  {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              ref.read(bottomNavIndexProvider.notifier).state = 1;
            },
          ),

          HomeActionCard(
            title: 'Map',
            icon: Icons.map_rounded,
            onTap: () {
              ref.read(bottomNavIndexProvider.notifier).state = 2;
            },
          ),


          HomeActionCard(
            title: 'Settings',
            icon: Icons.settings_rounded,
            onTap: () {
              ref.read(bottomNavIndexProvider.notifier).state =3;
            },
          ),

          HomeActionCard(
            title: 'capture Both',
            icon: Icons.catching_pokemon,
            onTap: () {
              context.push(RouteNames.captureBoth);
            },
          ),
        ],
      ),
    );
  }
}



