import 'package:PaySoon/helper/helper.dart';
import 'package:PaySoon/listBunga.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class AddBunga extends StatefulWidget {
  const AddBunga({super.key});

  @override
  State<AddBunga> createState() => _AddBungaState();
}

class _AddBungaState extends State<AddBunga> {
  String _selectedStatus = 'Aktif';
  TextEditingController _percentageController = TextEditingController();
  final _dio = Dio();
  final _storage = GetStorage();

  final _apiUrl = 'https://mobileapis.manpits.xyz/api';
  void goTambahTransaksi(percent, isActive) async {
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
      final _response = await _dio.post(
        '${_apiUrl}/addsettingbunga',
        data: {
          'persen': percent,
          'isaktif': isActive,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_storage.read('token')}',
          },
        ),
      );
      print(_response.data);
      print("error");
      if (_response.data["success"] == true) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Tambah Bunga"),
                content: Text('Tambah Bunga Berhasil ditambahkan.'),
                actions: <Widget>[
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => ListBunga()),
                      );
                    },
                  ),
                ],
              );
            });
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error!!"),
                content: Text('${_response.data["message"]}'),
                actions: <Widget>[
                  TextButton(
                      child: Text("Ok"),
                      onPressed: () => Navigator.pop(context)),
                ],
              );
            });
      }
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error!!"),
              content: Text('${e.response?.data["message"]}'),
              actions: <Widget>[
                TextButton(
                    child: Text("Ok"), onPressed: () => Navigator.pop(context)
                    //  Navigator.pushReplacement(
                    //         context,
                    //         MaterialPageRoute(builder: (_) => TabunganPage(id: widget.anggotaId,)),
                    //       );
                    ),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2C2C2C),
      appBar: AppBar(
        title: Text("Tambah Bunga"),
      ),
      body: SafeArea(
          child: Container(
        margin: EdgeInsets.all(32.0),
        padding: EdgeInsets.all(32.0),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(32.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Status Bunga",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio(
                  value: 'Aktif',
                  groupValue: _selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value.toString();
                    });
                  },
                ),
                Text('Aktif'),
                Radio(
                  value: 'Tidak Aktif',
                  groupValue: _selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value.toString();
                    });
                  },
                ),
                Text('Tidak Aktif'),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              "Persentasi Bunga",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _percentageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Masukkan persentase bunga',
              ),
            ),
            SizedBox(height: 32.0),
            Center(
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Implementasi fungsi untuk menyimpan data
                    // _saveData();
                    var status = 0;
                    if (_selectedStatus == "Aktif") {
                      status = 1;
                    } else {
                      status = 0;
                    }
                    goTambahTransaksi(_percentageController.text, status);
                  },
                  child: Text('Simpan'),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
