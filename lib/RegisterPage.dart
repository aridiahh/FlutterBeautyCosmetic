import 'package:PaySoon/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'HomePage.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _dio = Dio();
  final _storage = GetStorage();
  final _apiURL = 'https://mobileapis.manpits.xyz/api';

  Future<void> _register() async {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String phone = _phoneController.text;
    final String password = _passwordController.text;

    _storage.write('name', name);
    _storage.write('email', email);
    _storage.write('phone', phone);
    _storage.write('password', password);

    try {
      final _response = await _dio.post(
        '${_apiURL}/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_storage.read('token')}',
            // 'Content-Type': 'application/json', // Jika diperlukan oleh server
          },
        ),
      );
      print(_response.data);
      Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
    } catch (e) {
      print('Error registering: $e');
      // Tindakan jika terjadi kesalahan
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password atau Email Anda Salah")));
    }
  }

  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final String name = _storage.read('name') ?? '';
    final String email = _storage.read('email') ?? '';
    final String phone = _storage.read('phone') ?? '';
    final String password = _storage.read('password') ?? '';

    setState(() {
      _nameController.text = name;
      _emailController.text = email;
      _phoneController.text = phone;
      _passwordController.text = password;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 45.0),
                          Text(
                            "Daftar",
                            style: TextStyle(
                                fontSize: 40.0,
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            "Buat akun baru",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "untuk memulai.",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Nama',
                                  hintText: 'Masukkan nama'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 40.0, right: 40.0, top: 15, bottom: 0),
                            child: TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Email',
                                  hintText: 'Masukkan email'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 40.0, right: 40.0, top: 15, bottom: 0),
                            child: TextField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Telepon',
                                  hintText: 'Masukkan nomor telepon'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 40.0, right: 40.0, top: 15, bottom: 0),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Kata Sandi',
                                  hintText: 'Masukkan kata sandi'),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginDemo()),
                                );
                              },
                              child: Text(
                                'Sudah punya akun? Masuk',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Container(
                              height: 45,
                              width: 150,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20)),
                              child: ElevatedButton(
                                onPressed: () {
                                  _register();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                ),
                                child: Text(
                                  'Daftar',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
