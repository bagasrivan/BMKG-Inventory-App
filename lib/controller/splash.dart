import 'package:bmkg_inventory_system/view/loginPage.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo-splash.png',
              width: 80,
            ),
            SizedBox(
              height: 18,
            ),
            Text(
              'BMKG INVENTORY SYSTEM',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
