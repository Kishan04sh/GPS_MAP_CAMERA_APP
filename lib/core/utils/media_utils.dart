import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gps_map_camera/core/widgets/app_snackbar.dart';
import 'dart:ui';

/// ===================== REUSABLE PROGRESS DIALOG =====================

class ProgressDialog extends StatefulWidget {
  final String title;
  final String message;
  final bool showCancelButton;
  final VoidCallback? onCancel;

  const ProgressDialog({
    super.key,
    required this.title,
    required this.message,
    this.showCancelButton = false,
    this.onCancel,
  });

  @override
  State<ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async => false,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // ----------------- BLUR + SEMI-TRANSPARENT OVERLAY -----------------
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black38,
                ),
              ),
            ),

            // ----------------- CENTER CARD -----------------
            Center(
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ----------------- GRADIENT LOADER -----------------
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? Colors.tealAccent : Colors.blueAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ----------------- TITLE -----------------
                      Text(
                        widget.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // ----------------- MESSAGE -----------------
                      Text(
                        widget.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // ----------------- OPTIONAL CANCEL BUTTON -----------------
                      if (widget.showCancelButton && widget.onCancel != null)
                        ElevatedButton(
                          onPressed: widget.onCancel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text("Cancel"),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/// ===================== DELETE MEDIA ==========================================
Future<void> deleteMedia({
  required BuildContext context,
  required Future<void> Function() deleteAction,
  String successMessage = "Deleted successfully",
  String errorMessage = "Failed to delete",
}) async {
  final bool? confirm = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text("Delete Media", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("This action cannot be undone.\nDo you want to continue?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text("Cancel")),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text("Delete"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
          ),
        ],
      );
    },
  );

  if (confirm != true) return;

  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ProgressDialog(title: "Deleting Media", message: "Please wait..."),
    );

    await deleteAction();

    if (!context.mounted) return;
    Navigator.pop(context); // close loading
    AppSnackbar.show(context, message: successMessage, type: SnackbarType.success);
  } catch (_) {
    if (!context.mounted) return;
    Navigator.pop(context); // close loading
    AppSnackbar.show(context, message: errorMessage, type: SnackbarType.error);
  }
}

/// ===================== SHARE MEDIA =====================
Future<void> shareMedia({
  required BuildContext context,
  required String url,
  String text = "Shared from Gallery",
}) async {
  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ProgressDialog(title: "Sharing Media", message: "Preparing media..."),
    );

    final tempDir = await getTemporaryDirectory();
    final fileName = url.split('/').last;
    final filePath = "${tempDir.path}/$fileName";
    final file = await _downloadToFile(url, filePath);

    if (!context.mounted) return;
    Navigator.pop(context);

    await Share.shareXFiles([XFile(file.path)], text: text);
  } catch (_) {
    if (!context.mounted) return;
    Navigator.pop(context);
    AppSnackbar.show(context, message: "Failed to share media", type: SnackbarType.error);
  }
}


/// ===================== HELPER =====================
Future<File> _downloadToFile(String url, String path) async {
  final uri = Uri.parse(url);
  final bytes = await NetworkAssetBundle(uri).load(uri.path);
  final file = File(path);
  return file.writeAsBytes(bytes.buffer.asUint8List());
}


