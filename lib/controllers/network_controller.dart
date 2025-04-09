import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final RxBool _isSnackbarVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> connectivityResults) {
    bool hasInternet =
        connectivityResults.contains(ConnectivityResult.mobile) ||
        connectivityResults.contains(ConnectivityResult.wifi);

    if (!hasInternet) {
      if (!_isSnackbarVisible.value) {
        _isSnackbarVisible.value = true;
            Get.rawSnackbar(
              message: "No internet connection",
              duration: const Duration(days: 1),
              onTap: (_) => _isSnackbarVisible.value = false,
            );
      }
    } else {
      if (_isSnackbarVisible.value) {
        Get.closeCurrentSnackbar();
        _isSnackbarVisible.value = false;
      }
    }
  }
}
