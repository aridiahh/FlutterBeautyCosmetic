import 'package:PaySoon/helper/helper.dart';
import 'package:PaySoon/models/master_transaksi_response.dart';
import 'package:PaySoon/models/tabungan_response.dart';
import 'package:PaySoon/tambah_transaksi.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class TabunganPage extends StatefulWidget {
  final String? id;
  TabunganPage({super.key, this.id});

  @override
  State<TabunganPage> createState() => _TabunganPageState();
}

class _TabunganPageState extends State<TabunganPage> {
  String? _selectedValue; // This will hold the selected value
  List<String> _dropdownItems = [];
  List<dynamic> _allDataJenisTransaksi = [];
  List<dynamic>? _allTabunganUser = [];
  final _dio = Dio();
  int _saldo = 0;

  List<Jenistransaksi>? jenistransaksi;

  final _storage = GetStorage();

  final _apiURL = 'https://mobileapis.manpits.xyz/api';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMasterTabungan();
    getSaldoAnggota(widget.id);
    getListTabunganUser(widget.id);
  }

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
              String newAccessToken = await Helper.loginForRefreshToken();
              print(newAccessToken);
              e.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';

              return handler.resolve(await _dio.fetch(e.requestOptions));
            }
            return handler.next(e);
          },
        ),
      );
      final _response = await _dio.get(
        '${_apiURL}/jenistransaksi',
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

  Future<void> getListTabunganUser(id) async {
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
        '${_apiURL}/tabungan/${id}',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );

      Map<String, dynamic> responseData = _response.data;
      // print(responseData);
      setState(() {
        _allTabunganUser =
            TabunganResponse.fromJson(_response.data).data?.tabungan;
        print("INI HASIL");
        print("tes");
      });
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  String findTrxText(int trxId, List<Jenistransaksi> trxList) {
    for (var trx in trxList) {
      if (trx.id == trxId) {
        return trx.trxName.toString();
      }
    }
    return 'Unknown'; // Default value if trx_id is not found
  }

  Future<void> getSaldoAnggota(id) async {
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
        '${_apiURL}/saldo/${id}',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );

      Map<String, dynamic> responseData = _response.data;
      // print(responseData);
      setState(() {
        _saldo = responseData["data"]["saldo"];
        print(_saldo);
      });
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2C2C2C),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TambahTransaksi(
                  anggotaId: widget.id.toString(),
                ),
              ));
        },
        child: Icon(Icons.add),
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text(
                  "Saldo Anda : ${_saldo}",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            (_allTabunganUser!.isEmpty)
                ? Center(
                    child: Text(
                      "Tidak Ada Data",
                      style: TextStyle(color: Colors.white, fontSize: 14.0),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _allTabunganUser?.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            "Nominal : ${(_allTabunganUser![index] as Tabungan).trxNominal.toString()}",
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Text(
                            "${findTrxText(int.parse((_allTabunganUser![index] as Tabungan).trxId.toString()), jenistransaksi as List<Jenistransaksi>)}",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                          subtitle: Text(
                              "Tanggal : ${(_allTabunganUser![index] as Tabungan).trxTanggal.toString()}",
                              style: TextStyle(color: Colors.white)),
                        );
                      },
                    ),
                  ),
          ],
        ),
      )),
    );
  }
}
