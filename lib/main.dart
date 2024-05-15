import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:PaySoon/HomePage.dart';
import 'package:PaySoon/RegisterPage.dart';
import 'package:PaySoon/CoverPage.dart';
import 'package:dio/dio.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CoverPage(),
    );
  }
}

class LoginDemo extends StatefulWidget {
  @override
  _LoginDemoState createState() => _LoginDemoState();
}

class _LoginDemoState extends State<LoginDemo> {
  _LoginDemoState();
  final _dio = Dio();
  final _storage = GetStorage();
  final _apiURL = 'https://mobileapis.manpits.xyz/api';

  String email = '';
  String password = '';

  void setEmail(String value) {
    setState(() {
      email = value;
    });
  }

  void setPassword(String value) {
    setState(() {
      password = value;
    });
  }

  void goLogin() async {
    try {
      final _response = await _dio.post(
        '${_apiURL}/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      print(_response.data);
      _storage.write('token', _response.data['data']['token']);
      _storage.write('email', email);
      _storage.write('password', password);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password atau Email Anda Salah")));
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: Container(
                    width: 300,
                    height: 200,
                    child: Image.asset('asset/images/logopinjol.png')),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                onChanged: setEmail,
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
                onChanged: setPassword,
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Kata Sandi',
                    hintText: 'Masukkan kata sandi'),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text('Lupa Kata Sandi?',
                  style: TextStyle(color: Colors.blue, fontSize: 12)),
            ),
            Container(
              height: 45,
              width: 150,
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(20)),
              child: ElevatedButton(
                onPressed: () {
                  goLogin();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child: Text(
                  'Masuk',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),
            SizedBox(
              height: 130,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text(
                'Belum punya akun? Buat Akun',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
