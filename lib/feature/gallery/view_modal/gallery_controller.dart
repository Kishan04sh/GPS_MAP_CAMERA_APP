import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modal/gallery_state.dart';
import '../modal/media_type.dart';
import '../repository/gallery_repository.dart';
import '../../../core/widgets/app_snackbar.dart';

final galleryViewModelProvider =
StateNotifierProvider<GalleryViewModel, GalleryState>(
      (ref) => GalleryViewModel(GalleryRepository()),
);

class GalleryViewModel extends StateNotifier<GalleryState> {
  final GalleryRepository _repository;

  GalleryViewModel(this._repository) : super(GalleryState.initial()) {
    fetchGallery();
  }

  /// ================= FETCH =================
  Future<void> fetchGallery() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _repository.fetchGallery();

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          items: response.data ?? [],
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load gallery',
      );
    }
  }

  /// ================= UPLOAD =================
  Future<void> uploadMedia(
      BuildContext context, {
        required File file,
        required String latitude,
        required String longitude,
        required String location,
        required MediaType type,
      }) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await _repository.uploadMedia(
        file: file,
        latitude: latitude,
        longitude: longitude,
        location: location,
        type: type.apiValue,
      );

      if (response.success) {
        await fetchGallery();
        // AppSnackbar.show(
        //   context,
        //   message: 'Media uploaded successfully',
        //   type: SnackbarType.success,
        // );
      } else {
        AppSnackbar.show(
          context,
          message: response.message,
          type: SnackbarType.error,
        );
      }
    } catch (_) {
      AppSnackbar.show(
        context,
        message: 'Upload failed',
        type: SnackbarType.error,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// ================= DELETE =================
  Future<void> deleteMedia(
      BuildContext context, {
        required String imgVid,
      }) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await _repository.deleteByImgVid(imgVid);

      if (response.success) {
        /// ✅ REMOVE ITEM LOCALLY
        state = state.copyWith(
          items: state.items.where((e) => e.imgVid != imgVid).toList(),
          isLoading: false,
        );

        await fetchGallery();
        AppSnackbar.show(
          context,
          message: 'Media deleted successfully',
          type: SnackbarType.success,
        );
      } else {
        AppSnackbar.show(
          context,
          message: response.message,
          type: SnackbarType.error,
        );
      }
    } catch (_) {
      AppSnackbar.show(
        context,
        message: 'Delete failed',
        type: SnackbarType.error,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
