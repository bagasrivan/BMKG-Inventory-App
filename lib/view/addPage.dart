import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  _AddState createState() => _AddState();
}

class _AddState extends State<AddPage> {
  Widget build(BuildContext) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Peminjaman Barang'),
        backgroundColor: Colors.blue[200],
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, color: Colors.black),
      ),
    );
  }
}