import 'package:PaySoon/CoverPage.dart';
import 'package:PaySoon/EditUser.dart';
import 'package:PaySoon/ListUser.dart';
import 'package:PaySoon/TabunganPage.dart';
import 'package:PaySoon/AddBunga.dart';
import 'package:PaySoon/helper/helper.dart';
import 'package:PaySoon/listBunga.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_storage/get_storage.dart';
import 'package:PaySoon/AddUser.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dio = Dio();

  final _storage = GetStorage();

  final _apiURL = 'https://mobileapis.manpits.xyz/api';

  AnggotaDatas? anggotaDatas;

  Future<bool> goLogout() async {
    try {
      final _response = await _dio.get(
        '${_apiURL}/logout',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );

      print(_response.data);
      return true;
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
      return false;
    }
  }

  Future<void> userInfo() async {
    try {
      final _response = await _dio.get(
        '${_apiURL}/user',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );

      print(_response.data);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Detail Informasi User"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Nama : ${_response.data["data"]["user"]["name"]}'),
                  Text('Email : ${_response.data["data"]["user"]["email"]}'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  Future<void> detailUserAnggota(int id) async {
    try {
      final _response = await _dio.get(
        '${_apiURL}/anggota/${id}',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );

      print(_response.data);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Detail Informasi Anggota"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Nomor Induk : ${_response.data["data"]["anggota"]["nomor_induk"]}'),
                  Text('Nama : ${_response.data["data"]["anggota"]["nama"]}'),
                  Text(
                      'Alamat : ${_response.data["data"]["anggota"]["alamat"]}'),
                  Text(
                      'Tanggal Lahir : ${_response.data["data"]["anggota"]["tgl_lahir"]}'),
                  Text(
                      'Telepon : ${_response.data["data"]["anggota"]["telepon"]}'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("Lihat Tabungan Anggota"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TabunganPage(
                            id: _response.data["data"]["anggota"]["id"]
                                .toString(),
                          ),
                        ));
                  },
                ),
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  Future<void> delAnggota(int id) async {
    try {
      final _response = await _dio.delete(
        '${_apiURL}/anggota/${id}',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Hapus Data"),
              content: Text('Anggota telah dihapus.'),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
      getAnggota();
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  Future<void> getAnggota() async {
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
        '${_apiURL}/anggota',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );

      Map<String, dynamic> responseData = _response.data;
      print(responseData);
      setState(() {
        anggotaDatas = AnggotaDatas.fromJson(responseData);
      });
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAnggota();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAnggota();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2C2C2C),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(right: 20, left: 15, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      userInfo();
                    },
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Row(children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListBunga(),
                            ));
                      },
                      child: Container(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.money_off_outlined,
                            size: 28,
                            color: Colors.white, // Warna ikon
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ]),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Konfirmasi Logout'),
                                content: Text('Anda yakin ingin keluar?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      goLogout().then(
                                        (value) {
                                          if (value) {
                                            _storage.erase();
                                            Navigator.of(context).pop();
                                            Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        CoverPage(),
                                              ),
                                            );
                                          } else {
                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content:
                                                        Text("Gagal Logout")));
                                          }
                                        },
                                      );
                                    },
                                    child: Text('Ya'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              HomePage(),
                                        ),
                                      );
                                    },
                                    child: Text('Batal'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.logout,
                            size: 28,
                            color: Colors.white, // Warna ikon
                          ),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selamat Datang",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Solusi Cepat, Dana Langsung",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(15),
              padding: EdgeInsets.symmetric(horizontal: 15),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.search),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    width: 250,
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: "Cari Daftar Anggota",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            (anggotaDatas == null || anggotaDatas!.anggotaDatas.isEmpty)
                ? Text(
                    "Belum ada anggota",
                    style: TextStyle(color: Colors.white),
                  )
                : Expanded(
                    child: Container(
                      // height: 400.0,
                      width: double.infinity,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: anggotaDatas!.anggotaDatas.length,
                        itemBuilder: (context, index) {
                          final Anggota anggota =
                              anggotaDatas!.anggotaDatas[index];
                          return ListTile(
                            title: Row(children: [
                              Text(
                                anggota!.nama,
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              (anggota!.status_aktif == 1)
                                  ? Text(
                                      "Aktif",
                                      style: TextStyle(
                                          color: Colors.green, fontSize: 10.0),
                                    )
                                  : Text("NonAktif",
                                      style: TextStyle(
                                          fontSize: 10.0, color: Colors.red))
                            ]),
                            subtitle: Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  anggota!.telepon,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      // delAnggota(anggota.id);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => EditUser(
                                                    anggota: anggota,
                                                  )));
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    )),
                                IconButton(
                                    onPressed: () {
                                      delAnggota(anggota.id);
                                    },
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                    )),
                              ],
                            ),
                            leading: const CircleAvatar(
                              backgroundImage:
                                  AssetImage('asset/images/profile.png'),
                            ),
                            onTap: () {
                              // Navigator.pushNamed(context, '/anggota/detail',
                              //     arguments: anggota.id);
                              detailUserAnggota(anggota.id);
                            },
                          );
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 30.0, right: 15.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddUser()),
            );
          },
          child: Icon(Icons.add), // Ikon tambah di dalam tombol
          backgroundColor: Colors.white, // Warna latar belakang tombol
          foregroundColor: Colors.black, // Warna ikon tombol
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
