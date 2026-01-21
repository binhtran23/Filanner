import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service để kiểm tra trạng thái kết nối mạng
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    // On web, assume always connected to avoid hanging issues
    if (kIsWeb) {
      return true;
    }

    try {
      final result = await _connectivity.checkConnectivity().timeout(
        const Duration(seconds: 3),
      );
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      // If connectivity check fails or times out, assume connected
      return true;
    }
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
