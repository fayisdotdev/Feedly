import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  String? _accessToken;
  bool _isLoading = false;

  String? get accessToken => _accessToken;
  bool get isLoading => _isLoading;

  /// with OTP
  Future<bool> loginWithOtp({
    required String countryCode,
    required String phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('https://frijo.noviindus.in/api/otp_verified');

    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['country_code'] = countryCode;
      request.fields['phone'] = phone;

      var streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);

      debugPrint('OTP Response: $data');

      if (data['status'] == true && data['token']?['access'] != null) {
        _accessToken = data['token']['access'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('Login failed. Response: $data');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Login error: $e');
      return false;
    }
  }

  /// Logout
  void logout() {
    _accessToken = null;
    notifyListeners();
  }

  /// logged in or not
  bool get isLoggedIn => _accessToken != null;
}
