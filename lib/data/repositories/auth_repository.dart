import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

/// Repository for authentication operations
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  /// Login user with username and password
  Future<UserModel> login({
    required String username,
    required String password,
    int comId = 1,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.loginEndpoint,
        queryParameters: {
          'UserName': username,
          'Password': password,
          'ComId': comId,
        },
      );

      // Check if response is successful
      if (response.statusCode == 200) {
        // Handle both direct data and nested response structures
        final data = response.data;
        
        // If API returns a success indicator
        if (data is Map<String, dynamic>) {
          // Check if login was successful based on response data
          // Some APIs might return {Success: true, Data: {...}}
          // Others might return the user data directly
          
          final bool isSuccess = data['Success'] ?? 
                                 data['success'] ?? 
                                 true; // Assume success if status code is 200
          
          if (isSuccess) {
            return UserModel(
              username: username,
              comId: comId,
              success: true,
              message: data['Message'] ?? data['message'] ?? 'Login successful',
              token: data['Token'] ?? data['token'],
            );
          } else {
            return UserModel(
              username: username,
              comId: comId,
              success: false,
              message: data['Message'] ?? data['message'] ?? 'Login failed',
            );
          }
        }
        
        // If response is just a success message or other format
        return UserModel(
          username: username,
          comId: comId,
          success: true,
          message: 'Login successful',
        );
      } else {
        throw 'Login failed with status code: ${response.statusCode}';
      }
    } catch (e) {
      // Return failed UserModel with error message
      return UserModel(
        username: username,
        comId: comId,
        success: false,
        message: e.toString(),
      );
    }
  }
}
