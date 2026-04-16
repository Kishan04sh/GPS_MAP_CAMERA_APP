
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/app_animated_loader.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../auth/viewmodel/auth_view_model.dart';
import '../viewmodal/setting_controller.dart';


class DeleteAccountTile extends ConsumerWidget {
  const DeleteAccountTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.red.withOpacity(0.15),
        highlightColor: Colors.red.withOpacity(0.05),
        onTap: () => _showDeleteDialog(context, ref),
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
              // 🔴 Icon container
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red,
                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              // 📝 Text content
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'This action is permanent and cannot be undone',
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
                color: Colors.red.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= CONFIRMATION DIALOG =================
  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔴 ICON
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.shade100,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 16),

                /// TITLE
                const Text(
                  'Delete Account?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                /// MESSAGE
                const Text(
                  'This will permanently delete your account and all associated data. '
                      'You cannot undo this action.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                /// ACTIONS
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pop(dialogContext),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await _deleteAndLogout(context, ref);
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= DELETE + LOGOUT FLOW =================
  Future<void> _deleteAndLogout(
      BuildContext context,
      WidgetRef ref,
      ) async {
    AppAnimatedLoader.show(
      context,
      message: 'Deleting your account…',
    );

    try {
      // 1️⃣ Delete user from backend
      final result = await ref.read(settingsControllerProvider.notifier).deleteUser();

      if (!result.success) {
        throw Exception(result.message);
      }

      // 2️⃣ Show success snackbar
      if (context.mounted) {
        AppSnackbar.show(
          context,
          message: 'Account deleted successfully',
          type: SnackbarType.success,
        );
      }

      // 3️⃣ Logout (clear storage & session)
      await ref.read(authViewModelProvider.notifier).logout();
      // 4️⃣ Redirect to login
      if (context.mounted) {
        context.go(RouteNames.login);
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.show(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
          type: SnackbarType.error,
        );
      }
    } finally {
      if (context.mounted) {
        AppAnimatedLoader.hide(context);
      }
    }
  }
}
