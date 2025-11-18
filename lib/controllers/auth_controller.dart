import 'package:get/get.dart';
import '../data/repositories/auth_repository.dart';
import '../core/utils/storage_utils.dart';
import '../core/network/api_client.dart';

/// Controller for authentication operations
class AuthController extends GetxController {
  late final AuthRepository _authRepository;

  // Observable states
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _authRepository = AuthRepository(ApiClient());
    _checkLoginStatus();
  }

  /// Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    isLoggedIn.value = await StorageUtils.isLoggedIn();
  }

  /// Login method
  Future<bool> login({
    required String username,
    required String password,
    int comId = 1,
  }) async {
    // Clear previous error
    errorMessage.value = '';

    // Validate inputs
    if (username.trim().isEmpty) {
      errorMessage.value = 'Please enter your username';
      return false;
    }

    if (password.trim().isEmpty) {
      errorMessage.value = 'Please enter your password';
      return false;
    }

    isLoading.value = true;

    try {
      final result = await _authRepository.login(
        username: username,
        password: password,
        comId: comId,
      );

      if (result.success) {
        print('[Auth] Login successful!');
        print('[Auth] Token: ${result.token != null ? "${result.token!.substring(0, 30)}..." : "null"}');
        
        // Save login state with token
        await StorageUtils.saveLoginState(
          isLoggedIn: true,
          username: username,
          comId: comId,
          token: result.token,
        );
        
        print('[Auth] Login state saved to storage');

        isLoggedIn.value = true;
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = result.message ?? 'Login failed';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return false;
    }
  }

  /// Logout method
  Future<void> logout() async {
    await StorageUtils.clearAll();
    isLoggedIn.value = false;
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }
}
