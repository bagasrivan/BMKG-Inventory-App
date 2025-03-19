import 'package:flutter/material.dart';

class ReturnPage extends StatefulWidget {
  const ReturnPage({super.key});

  @override
  _ReturnState createState() => _ReturnState();
}

class _ReturnState extends State<ReturnPage> {
  @override
  Widget build(BuildContext) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengembalian Barang'),
        backgroundColor: Colors.blue[200],
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, color: Colors.black),
      ),
    );
  }
}
