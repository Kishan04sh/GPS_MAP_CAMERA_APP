import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ad_service.dart';

final adHelperProvider = Provider<AdHelper>((ref) {
  return AdHelper(ref);
});

class AdHelper {
  final Ref ref;
  AdHelper(this.ref);
  bool _isRunning = false;

  Future<void> runWithAd(Future<void> Function() action) async {
    final ad = ref.read(adServiceProvider);

    if (_isRunning) {
      debugPrint("⚠️ [AdHelper] Already running → skip");
      return;
    }
    _isRunning = true;
    debugPrint("🟡 [AdHelper] runWithAd triggered");

    try {
      // ================= CASE 1: AD READY =================
      if (ad.isReady) {
        debugPrint("🟢 [AdHelper] Ad READY → showing ad");
        bool actionExecuted = false;
        Timer? timer;

        void runActionOnce(String source) async {
          if (actionExecuted) return;
          actionExecuted = true;
          debugPrint("📌 Action triggered by: $source");
          timer?.cancel();
          await _safeExecute(action);
          _isRunning = false;
        }

        // fallback timer
        timer = Timer(const Duration(seconds: 8), () {
          runActionOnce("timeout");
        });

        ad.showAd(
          onComplete: () {
            runActionOnce("ad_completed");
          },
        );
      }

      // ================= CASE 2: AD NOT READY =================
      else {
        debugPrint("⚠️ [AdHelper] Ad NOT READY → skipping ad");
        await _safeExecute(action);
        // preload next ad
        ad.loadAd();
        _isRunning = false;
      }
    } catch (e, st) {
      debugPrint("❌ [AdHelper] Crash: $e");
      debugPrintStack(stackTrace: st);
      await _safeExecute(action);
      _isRunning = false;
    }
  }

  // ================= SAFE EXECUTION =================
  Future<void> _safeExecute(Future<void> Function() action) async {
    try {
      await action();
      debugPrint("✅ [AdHelper] Action completed");
    } catch (e, st) {
      debugPrint("❌ [AdHelper] Action error: $e");
      debugPrintStack(stackTrace: st);
    }
  }
}