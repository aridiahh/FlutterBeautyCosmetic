// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:PaySoon/HomePage.dart';
import 'package:PaySoon/ListUser.dart';
import 'package:PaySoon/helper/helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_storage/get_storage.dart';

class EditUser extends StatefulWidget {
  Anggota anggota;
  EditUser({
    Key? key,
    required this.anggota,
  }) : super(key: key);

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nomorIndukController = TextEditingController();
  TextEditingController _namaController = TextEditingController();
  TextEditingController _alamatController = TextEditingController();
  TextEditingController _tglLahirController = TextEditingController();
  TextEditingController _noTeleponController = TextEditingController();
  int? selectedOption = 0;

  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';
  int id = 0;
  DateTime? _tglLahir;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      _nomorIndukController.text = widget.anggota.nomor_induk.toString();
      _namaController.text = widget.anggota.nama;
      _alamatController.text = widget.anggota.alamat;
      _tglLahirController.text = widget.anggota.tgl_lahir;
      _noTeleponController.text = widget.anggota.telepon;
      List<String> parts = widget.anggota.tgl_lahir.split('-');

      if (widget.anggota.status_aktif != null) {
        selectedOption = widget.anggota.status_aktif;
      }

      String year = parts[0];
      String month = parts[1];
      String day = parts[2];
      _tglLahir = DateTime.parse(widget.anggota.tgl_lahir);
    });
  }

  void goEditUser(id) async {
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
      final _response = await _dio.put(
        '${_apiUrl}/anggota/${id}',
        data: {
          'nomor_induk': _nomorIndukController.text,
          'nama': _namaController.text,
          'alamat': _alamatController.text,
          'tgl_lahir': _tglLahirController.text,
          'telepon': _noTeleponController.text,
          'status_aktif': selectedOption
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_storage.read('token')}',
          },
        ),
      );
      print(_response.data);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Edit Anggota"),
              content: Text('Anggota berhasil diedit.'),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ));
                  },
                ),
              ],
            );
          });
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Oops!"),
              content: Text(e.response?.data['message'] ?? 'An error occurred'),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/anggota',
                    );
                  },
                ),
              ],
            );
          });
    }
  }

  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: _tglLahir ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (_picked != null) {
      setState(() {
        _tglLahir = _picked;
        _tglLahirController.text =
            "${_picked.year}-${_picked.month}-${_picked.day}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Anggota',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                    TextFormField(
                      controller: _nomorIndukController,
                      validator: (_nomorIndukController) {
                        if (_nomorIndukController == null ||
                            _nomorIndukController.isEmpty) {
                          return 'Tolong masukkan nomor induk.';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Induk',
                        hintText: 'Masukkan nomor induk',
                        prefixIcon: Icon(Icons.ac_unit),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _namaController,
                      validator: (_namaController) {
                        if (_namaController == null ||
                            _namaController.isEmpty) {
                          return 'Tolong masukkan nama.';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        hintText: 'Masukkan nama',
                        prefixIcon: Icon(Icons.perm_identity),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _alamatController,
                      validator: (_alamatController) {
                        if (_alamatController == null ||
                            _alamatController.isEmpty) {
                          return 'Tolong masukkan alamat.';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Alamat',
                        hintText: 'Masukkan alamat',
                        prefixIcon: Icon(Icons.map),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tglLahirController,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Lahir',
                        hintText: 'Masukkan tanggal lahir',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () {
                        _selectDate();
                      },
                      validator: (value) {
                        if (_tglLahir == null) {
                          return 'Tolong masukkan tanggal lahir';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noTeleponController,
                      validator: (_noTeleponController) {
                        if (_noTeleponController == null ||
                            _noTeleponController.isEmpty) {
                          return 'Tolong masukkan nomor telepon.';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        hintText: 'Masukkan nomor telepon',
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      "Status Anggota",
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Column(children: [
                      ListTile(
                        title: const Text('Aktif'),
                        leading: Radio<int>(
                          value: 1,
                          groupValue: selectedOption,
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value!;
                              print("Button value: $value");
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Tidak Aktif'),
                        leading: Radio<int>(
                          value: 2,
                          groupValue: selectedOption,
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value!;
                            });
                          },
                        ),
                      ),
                    ]),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState?.save();
                                  goEditUser(widget.anggota.id);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 10)),
                              child: Text('Edit Anggota',
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
