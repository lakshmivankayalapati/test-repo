import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    // The result can be a list if the device is connected to multiple networks.
    // We just need to know if at least one connection is active and not none.
    return !result.contains(ConnectivityResult.none);
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
}); 