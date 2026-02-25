class BaseResponse<T> {
  final bool success;
  final String code;
  final String message;
  final T? data;

  const BaseResponse({
    required this.success,
    required this.code,
    required this.message,
    this.data,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return BaseResponse<T>(
      success: json['success'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'success': success,
      'code': code,
      'message': message,
      'data': data != null ? toJsonT(data as T) : null,
    };
  }
}
