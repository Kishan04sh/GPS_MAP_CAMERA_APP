import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/app_animated_loader.dart';
import '../../auth/viewmodel/auth_view_model.dart';


class LogoutTile extends ConsumerWidget {
  const LogoutTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.red.withOpacity(0.15),
        highlightColor: Colors.red.withOpacity(0.05),
        onTap: () async {
          AppAnimatedLoader.show(
            context,
            message: 'Signing you out…',
          );

          try {
            await ref.read(authViewModelProvider.notifier).logout();

            if (context.mounted) {
              context.go(RouteNames.login);
            }
          } finally {
            if (context.mounted) {
              AppAnimatedLoader.hide(context);
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red.withOpacity(0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // 🔴 Icon container (lighter than delete)
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              // 📝 Text
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sign out from this device',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // ➡️ Chevron
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: Colors.red.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
