import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class Helper {
  static Future<String> loginForRefreshToken() async {
    var _dio = Dio();
      final _storage = GetStorage();
    final _apiURL = 'https://mobileapis.manpits.xyz/api';

    try {
      final _response = await _dio.post(
        '${_apiURL}/login',
        data: {
          'email': _storage.read('email'),
          'password': _storage.read('password'),
        },
      );
      print("get token");
      _storage.write('token', _response.data['data']['token']);
      return _response.data['data']['token'];
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    return "no_token";
    }
  }

  static Future<String> refreshToken() async {
  // Perform a request to the refresh token endpoint and return the new access token.
  // You can replace this with your own implementation.
  return 'your_new_access_token';
  }
}