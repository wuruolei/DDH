/// API响应数据模型
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? token;
  final dynamic user;
  final int? code;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.token,
    this.user,
    this.code,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, {T? Function(dynamic)? fromJsonT}) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      token: json['token'],
      user: json['user'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'token': token,
      'user': user,
      'code': code,
    };
  }

  // 成功响应的便捷构造函数
  factory ApiResponse.success({
    String message = 'Success',
    T? data,
    String? token,
    dynamic user,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      token: token,
      user: user,
    );
  }

  // 失败响应的便捷构造函数
  factory ApiResponse.error({
    String message = 'Error',
    int? code,
    T? data,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      code: code,
      data: data,
    );
  }
}
