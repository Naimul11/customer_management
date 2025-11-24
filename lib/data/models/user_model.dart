class UserModel {
  final String username;
  final int comId;
  final bool success;
  final String? message;
  final String? token;

  UserModel({
    required this.username,
    required this.comId,
    required this.success,
    this.message,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['UserName'] ?? json['username'] ?? '',
      comId: json['ComId'] ?? json['comId'] ?? 1,
      success: json['Success'] ?? json['success'] ?? false,
      message: json['Message'] ?? json['message'],
      token: json['Token'] ?? json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'comId': comId,
      'success': success,
      'message': message,
    };
  }
}
