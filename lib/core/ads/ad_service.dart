import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});

class AdService {
  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  bool _isShowing = false;
  bool _initialized = false;
  int _retry = 0;
  final int _maxRetry = 5; // 🔥 increased

  // ================= INIT =================
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    debugPrint("🔥 AdService INIT");
    loadAd();
  }

  // ================= LOAD AD =================
  void loadAd() {
    if (_isLoading) return;
    _isLoading = true;
    debugPrint("📥 Loading Interstitial Ad...");
    InterstitialAd.load(
      adUnitId: _getAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint("✅ Interstitial Ad LOADED");
          _interstitialAd = ad;
          _isLoading = false;
          _retry = 0;
          ad.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          debugPrint("❌ Load failed: ${error.code} | ${error.message}");
          _interstitialAd = null;
          _isLoading = false;
          _retry++;
          if (_retry < _maxRetry) {
            Future.delayed(const Duration(seconds: 3), loadAd);
          } else {
            debugPrint("❌ Max retry reached");
          }
        },
      ),
    );
  }

  // ================= SHOW AD =================
  void showAd({required VoidCallback onComplete}) {
    if (_isShowing) {
      debugPrint("⚠️ Already showing ad");
      onComplete();
      return;
    }
    if (_interstitialAd == null) {
      debugPrint("⚠️ Ad NOT READY → skipping");
      onComplete();
      loadAd();
      return;
    }
    _isShowing = true;
    // 🔥 IMPORTANT: callback yahan set karo (best practice)
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint("📺 Ad showing");
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint("👋 Ad dismissed");
        ad.dispose();
        _interstitialAd = null;
        _isShowing = false;
        loadAd();
        onComplete(); // ✅ CRITICAL FIX
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint("❌ Show failed: ${error.message}");
        debugPrint("CODE: ${error.code}");
        debugPrint("MESSAGE: ${error.message}");
        debugPrint("DOMAIN: ${error.domain}");
        ad.dispose();
        _interstitialAd = null;
        _isShowing = false;
        loadAd();
        onComplete(); // ✅ CRITICAL FIX
      },
    );

    try {
      debugPrint("🚀 SHOWING AD");
      _interstitialAd!.show();
    } catch (e) {
      debugPrint("❌ Exception: $e");
      _isShowing = false;
      _interstitialAd = null;
      loadAd();
      onComplete();
    }
  }

  // ================= AD UNIT =================
  String _getAdUnitId() {
    if (kDebugMode) {
      // return "ca-app-pub-3940256099942544/1033173712"; // TEST
      return "ca-app-pub-6233828340255525/1556432930"; // TEST
    } else {
      return "ca-app-pub-6233828340255525/1556432930"; // REAL
    }
  }

  bool get isReady => _interstitialAd != null;

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}