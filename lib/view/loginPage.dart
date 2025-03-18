import 'dart:convert';
import 'dart:io';

import 'package:bmkg_inventory_system/controller/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  bool _obscurePassword = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://api-bmkg.athaland.my.id/api/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Login berhasil, Selamat datang'),
          backgroundColor: Colors.green,
        ));

        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => Navigation())
        );
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['message'] ?? 'Login gagal, silahkan coba lagi';
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_errorMessage),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Koneksi error, periksa koneksi internet anda';
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_errorMessage),
        backgroundColor: Colors.red,
      ));
      
      // Print error for debugging
      print('Login error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView( 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/logo-splash.png',
                  width: 140,
                  height: 50,
                ),
                const SizedBox(height: 20),
                const Text(
                  'BMKG INVENTORY SYSTEM',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/hands-holding.png',
                  width: 250,
                  height: 250,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _usernameController, 
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle:
                          const TextStyle(fontSize: 15, color: Colors.grey),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _passwordController, 
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle:
                          const TextStyle(fontSize: 15, color: Colors.grey),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 320,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isLoading 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 320,
                  child: ElevatedButton(
                    onPressed: () {
                      if (Platform.isAndroid) {
                        SystemNavigator.pop();
                      } else if (Platform.isIOS) {
                        exit(0);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Exit',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}