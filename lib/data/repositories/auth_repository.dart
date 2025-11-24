import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

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

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map<String, dynamic>) {
          final bool isSuccess = data['Success'] ?? 
                                 data['success'] ?? 
                                 true;
          
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
      return UserModel(
        username: username,
        comId: comId,
        success: false,
        message: e.toString(),
      );
    }
  }
}
