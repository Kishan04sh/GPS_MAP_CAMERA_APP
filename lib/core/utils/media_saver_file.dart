import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/app_snackbar.dart';

enum SaveMediaType { image, video }

class SafeDownloader {
  static const MethodChannel _channel = MethodChannel('safe_downloader');

  /// ==========================================================
  /// DOWNLOAD FROM URL
  /// ==========================================================
  static Future<void> downloadFromUrl({
    required BuildContext context,
    required String url,
    String? fileName,
    String successMessage = "Download started",
    String errorMessage = "Download failed",
  }) async {
    try {
      if (url.isEmpty || !url.startsWith('http')) {
        throw Exception("Invalid download URL");
      }

      final name = fileName ?? url.split('/').last.split('?').first;

      // Invoke Android DownloadManager via MethodChannel
      await _channel.invokeMethod(
        'download',
        {
          'url': url,
          'fileName': name,
        },
      );

      if (!context.mounted) return;
      AppSnackbar.show(
        context,
        message: successMessage,
        type: SnackbarType.success,
      );
    } on PlatformException catch (e) {
      if (!context.mounted) return;
      AppSnackbar.show(
        context,
        message: e.message ?? errorMessage,
        type: SnackbarType.error,
      );
    } catch (e) {
      if (!context.mounted) return;
      AppSnackbar.show(
        context,
        message: errorMessage,
        type: SnackbarType.error,
      );
    }
  }

  /// ==========================================================
  /// SAVE LOCAL FILE TO GALLERY (IMAGE / VIDEO)
  /// ==========================================================
  static Future<void> saveLocalFile({
    required BuildContext context,
    required File file,
    required SaveMediaType type,
    String successMessage = "Saved to gallery",
    String errorMessage = "Failed to save file",
  }) async {
    try {
      if (!file.existsSync()) {
        throw Exception("File does not exist");
      }

      await _channel.invokeMethod(
        'saveLocal',
        {
          'path': file.path,
          'type': type.name, // image / video
        },
      );

      if (!context.mounted) return;
      AppSnackbar.show(
        context,
        message: successMessage,
        type: SnackbarType.success,
      );
    } on PlatformException catch (e) {
      if (!context.mounted) return;
      AppSnackbar.show(
        context,
        message: e.message ?? errorMessage,
        type: SnackbarType.error,
      );
    } catch (e) {
      if (!context.mounted) return;
      AppSnackbar.show(
        context,
        message: errorMessage,
        type: SnackbarType.error,
      );
    }
  }
}
