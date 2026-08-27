import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../router/app_router.dart';

class NetworkConnectivityService {
  static final NetworkConnectivityService _instance = NetworkConnectivityService._internal();
  factory NetworkConnectivityService() => _instance;
  NetworkConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isDialogOpen = false;

  void initialize() {
    // Initial check
    _checkInitialConnectivity();

    // Listen for connectivity changes safely
    try {
      _subscription = _connectivity.onConnectivityChanged.listen(
        _handleConnectivityChange,
        onError: (e) {
          debugPrint("Connectivity stream error: $e");
        },
      );
    } catch (e) {
      debugPrint("Connectivity initialization error: $e");
    }
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleConnectivityChange(results);
    } catch (e) {
      debugPrint("Connectivity check error: $e");
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    // ConnectivityResult.none means no active network connection (neither mobile nor wifi)
    final hasNoNetwork = results.contains(ConnectivityResult.none) || results.isEmpty;

    if (hasNoNetwork) {
      _showNoNetworkDialog();
    } else {
      _dismissNoNetworkDialog();
    }
  }

  void _showNoNetworkDialog() {
    if (_isDialogOpen) return;

    final context = navigatorKey.currentContext;
    if (context == null) {
      // Retry shortly if navigator context is not ready yet during splash/startup
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_isDialogOpen) {
          _checkInitialConnectivity();
        }
      });
      return;
    }

    _isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.redAccent,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  "No Internet Connection",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: const Text(
              "Please turn on your mobile network or Wi-Fi to continue using AM5 ROYAL.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        );
      },
    ).then((_) {
      _isDialogOpen = false;
    });
  }

  void _dismissNoNetworkDialog() {
    if (!_isDialogOpen) return;

    final context = navigatorKey.currentContext;
    if (context != null && Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
      _isDialogOpen = false;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
