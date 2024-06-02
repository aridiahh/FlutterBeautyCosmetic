import 'package:PaySoon/HomePage.dart';
import 'package:PaySoon/TabunganPage.dart';
import 'package:PaySoon/helper/helper.dart';
import 'package:PaySoon/models/master_transaksi_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class TambahTransaksi extends StatefulWidget {
  final String anggotaId;
  TambahTransaksi({required this.anggotaId});

  @override
  _TambahTransaksiState createState() => _TambahTransaksiState();
}

DateTime? _tglLahir;

class _TambahTransaksiState extends State<TambahTransaksi> {
  final _formKey = GlobalKey<FormState>();
  final _dio = Dio();
  List<Jenistransaksi>? jenistransaksi;
  final _storage = GetStorage();
  List<dynamic> _allDataJenisTransaksi = [];
  List<dynamic> _allTabunganUser = [];

  final _apiUrl = 'https://mobileapis.manpits.xyz/api';
  int? _selectedValue; // This will hold the selected value
  List<String> _dropdownItems = [];
  final _nominalController = TextEditingController();

  Future<void> getMasterTabungan() async {
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
        '${_apiUrl}/jenistransaksi',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );

      Map<String, dynamic> responseData = _response.data;
      // print(responseData);
      jenistransaksi =
          MasterTransaksiResponse.fromJson(_response.data).data?.jenistransaksi;
      setState(() {
        _allDataJenisTransaksi = responseData["data"]["jenistransaksi"];
        for (var i = 0; i < _allDataJenisTransaksi.length; i++) {
          _dropdownItems.add(_allDataJenisTransaksi[i]["trx_name"]);
        }
      });
      print(_allDataJenisTransaksi[0]["id"].toString());
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  void goTambahTransaksi(anggotaId, trxId, nominal) async {
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
        '${_apiUrl}/tabungan',
        data: {
          'anggota_id': anggotaId,
          'trx_id': trxId,
          'trx_nominal': nominal,
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
                title: Text("Tambah Transaksi"),
                content: Text('Transaksi Berhasil Ditambahkan.'),
                actions: <Widget>[
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => TabunganPage(
                                  id: widget.anggotaId,
                                )),
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
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
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
              content: Text('UNKNOWN ERROR FROM SERVER'),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TabunganPage(
                                id: widget.anggotaId,
                              )),
                    );
                  },
                ),
              ],
            );
          });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMasterTabungan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text('Tambah Anggota',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          const SizedBox(height: 10),
          Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: DropdownButton<int>(
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        hint: Text(
                          'Pilih jenis tabungan',
                          style: TextStyle(color: Colors.black),
                        ),
                        value: _selectedValue,
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedValue = newValue!;
                          });
                        },
                        items: jenistransaksi?.map((jenis) {
                          return DropdownMenuItem(
                            value: jenis.id,
                            child: Text("${jenis.trxName}"),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    TextFormField(
                      controller: _nominalController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value == '') {
                          return "Masukkan nominal dengan benar";
                        } else {
                          if (int.parse(value) <= 0) {
                            return "Anda tidak dapat memasukkan nominal di bawah 0";
                          }
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Masukkan Nominal',
                        hintText: 'Masukkan Nominal',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState?.save();
                                  goTambahTransaksi(widget.anggotaId,
                                      _selectedValue, _nominalController.text);
                                  print("masuk");
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Silakan masukkan data dengan benar")));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 10)),
                              child: Text('Tambah Transaksi',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white))),
                        ),
                      ],
                    ),
                  ]))
        ]),
      ),
    );
  }
}
