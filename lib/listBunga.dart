import 'package:PaySoon/AddBunga.dart';
import 'package:PaySoon/helper/helper.dart';
import 'package:PaySoon/models/setting_bunga.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:PaySoon/models/setting_bunga.dart' as stb;

class ListBunga extends StatefulWidget {
  const ListBunga({super.key});

  @override
  State<ListBunga> createState() => _ListBungaState();
}

class _ListBungaState extends State<ListBunga> {
  SettingBunga? bunga;
  final _dio = Dio();
  final _storage = GetStorage();

  final _apiUrl = 'https://mobileapis.manpits.xyz/api';
  Future<void> getListSettingBunga() async {
    print(_storage.read('token'));
    try {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Add the access token to the request header
            options.headers['Authorization'] =
                'Bearer ${_storage.read('token')}';
            return handler.next(options);
          },
          onError: (DioError e, handler) async {
            if (e.response?.statusCode == 406) {
              // If a 401 response is received, refresh the access token
              print("masuk");
              String newAccessToken = await Helper.loginForRefreshToken();
              print(newAccessToken);
              // Update the request header with the new access token
              e.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';

              // Repeat the request with the updated header
              return handler.resolve(await _dio.fetch(e.requestOptions));
            }
            return handler.next(e);
          },
        ),
      );
      final _response = await _dio.get(
        '${_apiUrl}/settingbunga',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );

      Map<String, dynamic> responseData = _response.data;
      // print(responseData);
      setState(() {
        bunga = stb.SettingBunga.fromJson(_response.data);
        print("INI HASIL");
        print("tes");
      });
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getListSettingBunga();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddBunga(),
              ));
        },
        child: Icon(Icons.add),
      ),
      backgroundColor: Color(0xFF2C2C2C),
      appBar: AppBar(
        title: Text("List Bunga"),
      ),
      body: SafeArea(
          child: (bunga == null)
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(children: [
                  Container(
                    margin: EdgeInsets.all(32.0),
                    padding: EdgeInsets.all(32.0),
                    width: double.infinity,
                    height: 150.0,
                    child: Column(
                      children: [
                        Text(
                          "Bunga aktif saat ini : ",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 24.0),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.money_off,
                              color: Colors.green,
                              size: 32.0,
                            ),
                            Text(
                              "${bunga!.data!.activebunga!.persen.toString()} %",
                              style: TextStyle(
                                  color: Colors.green, fontSize: 32.0),
                            ),
                          ],
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0)),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: Colors.white,
                      ),
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                                "Bunga : ${bunga!.data!.settingbungas[index].persen} %"),
                            subtitle: Text(
                              (bunga!.data!.settingbungas[index].isaktif == 0)
                                  ? "Tidak Aktif"
                                  : "Aktif",
                              style: TextStyle(
                                  color: (bunga!.data!.settingbungas[index]
                                              .isaktif ==
                                          0)
                                      ? Colors.red
                                      : Colors.green),
                            ),
                          );
                        },
                        itemCount: bunga!.data!.settingbungas.length,
                      ),
                    ),
                  ),
                ])),
    );
  }
}
