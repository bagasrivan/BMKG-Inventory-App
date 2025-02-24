import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<InventoryPage> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barang'),
        centerTitle: true,
        backgroundColor: Colors.blue[200],
        titleTextStyle: TextStyle(fontSize: 20, color: Colors.black),
      ),
    );
  }
}