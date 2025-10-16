class LoginResponse {
  final String access;

  LoginResponse({required this.access});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      access: json['access'],
    );
  }
}
