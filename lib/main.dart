import 'package:bmkg_inventory_system/controller/splash.dart';
import 'package:bmkg_inventory_system/view/loginPage.dart';
import 'package:bmkg_inventory_system/controller/navigation.dart';
import 'package:bmkg_inventory_system/view/homePage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BMKG Inventory System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/navigation': (context) => const Navigation(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}