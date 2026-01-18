import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../api/api_exception.dart';

class GoogleMapsApiRepository {
  static final GoogleMapsApiRepository _instance = GoogleMapsApiRepository._internal();
  factory GoogleMapsApiRepository() => _instance;

  late final Dio _dio;

  GoogleMapsApiRepository._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://maps.googleapis.com/maps/api',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {"Accept": "application/json"},
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('[GOOGLE_MAPS_API] $object'),
      ),
    );
  }

  Timer? _debounce;
  Position? _lastPosition;
  String? _lastAddress;

  /// ***************************************************************
  /// INTERNET CHECK
  /// ***************************************************************
  Future<void> _checkInternet() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      throw ApiException("No Internet Connection");
    }
  }

  /// ***************************************************************
  /// GET ADDRESS FROM GOOGLE MAPS API
  /// ***************************************************************
  Future<String> getAddress({
    required double latitude,
    required double longitude,
    required String apiKey,
    bool forceRefresh = false,
  }) async {
    await _checkInternet();

    // Skip API call if last address exists & distance < 20m & not force refresh
    if (!forceRefresh &&
        _lastPosition != null &&
        _lastAddress != null &&
        Geolocator.distanceBetween(
            latitude,
            longitude,
            _lastPosition!.latitude,
            _lastPosition!.longitude) <
            20) {
      return _lastAddress!;
    }

    // Debounce API calls for rapid location updates
    if (_debounce != null && _debounce!.isActive) {
      return Future.value(_lastAddress ?? 'Fetching address...');
    }

    final completer = Completer<String>();

    _debounce = Timer(const Duration(seconds: 1), () async {
      try {
        final url = '/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

        final response = await _dio.get(
          url,
          options: Options(extra: {"useToken": false}),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
            final address = data['results'][0]['formatted_address'] as String;

            // Correct Position creation with all required fields
            _lastPosition = Position(
              latitude: latitude,
              longitude: longitude,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
              // new required fields
              altitudeAccuracy: 0,
              headingAccuracy: 0,
            );

            _lastAddress = address;
            completer.complete(address);
            return;
          }
        }

        completer.complete('Address not found');
      } catch (e) {
        completer.complete('Error fetching address');
      }
    });

    return completer.future;
  }

  /// ***************************************************************
  /// CLEAR CACHE
  /// ***************************************************************
  void clearCache() {
    _lastAddress = null;
    _lastPosition = null;
  }

  /// ***************************************************************
  /// DISPOSE
  /// ***************************************************************
  void dispose() {
    _debounce?.cancel();
  }
}
