/// Consolidated auth models. This file provides a simple `LoginResponse` model
/// used by the compact auth provider. The existing `login_response_model.dart`
/// remains untouched; this is an additive convenience file.

class LoginResponse {
  final String access;

  LoginResponse({required this.access});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(access: json['access']);
  }
}
