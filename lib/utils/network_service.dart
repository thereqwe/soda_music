import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetworkService {
  final Dio _dio = Dio(BaseOptions(
    // baseUrl: 'http://10.0.2.2:80/ww2_php/',
    //baseUrl: 'http://8.155.0.117/tiny_signal_php/',
    baseUrl: 'http://www.tinysignal.fun/soda_music/', //production
    // baseUrl: 'http://192.168.3.14/tiny_signal_php/',
    //baseUrl: 'http://172.28.31.14/tiny_signal_php/',
    // baseUrl: 'http:// 172.17.1.205/tiny_signal_php/',
    //baseUrl: 'http://www.baidu.com/',
    // baseUrl: 'http://192.168.3.121:8888/', // debug
    //baseUrl: 'http://10.0.2.2:8888/',
    connectTimeout: Duration(milliseconds: 10000),
    receiveTimeout: Duration(milliseconds: 10000),
  ));

  late SharedPreferences _prefs;
  var _userId = "";
  NetworkService() {
    init() async {
      _prefs = await SharedPreferences.getInstance();
      _userId = _prefs.getString("userId") ?? "";
    }

    init();
  }

  Future<dynamic> get(String url, Map<String, dynamic> headers,
      {needSSL = false}) async {
    print("wow api get url $url");

    //debug for net slow test
    // if (!url.contains("cityCode")) {
    //   return {};
    // }

    if (needSSL) {
      url = "https://tinysignal.fun/tiny_signal_php/$url";
    }

    try {
      _prefs = await SharedPreferences.getInstance();
      _userId = _prefs.getString("userId") ?? "";
      Response response = await _dio.get(url,
          queryParameters: {"userId": _userId ?? ""},
          options: Options(headers: headers));
      print("wow api response $response");

      return response.data;
    } catch (e) {
      print("wow $e");
      throw e;
    }
  }

  Future<dynamic> post(
      String url, dynamic data, Map<String, dynamic> headers) async {
    print("wow api post url $url");

    try {
      _prefs = await SharedPreferences.getInstance();
      _userId = _prefs.getString("userId") ?? "";
      Response response = await _dio.post(url,
          data: data,
          queryParameters: {"userId": _userId ?? ""},
          options: Options(headers: {
            ...headers,
            "Content-Type": "application/x-www-form-urlencoded",
          }));

      return response.data;
    } catch (e) {
      print("wow,$e");
      throw e;
    }
  }
}
