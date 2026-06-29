import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  static bool isOnlineResult(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  static Future<bool> checkConnection() async {
    final results = await Connectivity().checkConnectivity();
    return isOnlineResult(results);
  }
}
