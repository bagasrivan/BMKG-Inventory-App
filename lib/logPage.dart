import 'package:flutter/material.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  _LogState createState() => _LogState();
}

class _LogState extends State<LogPage> {
  Widget build(BuildContext) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Peminjaman'),
        centerTitle: true,
        backgroundColor: Colors.blue[200],
        titleTextStyle: TextStyle(fontSize: 20, color: Colors.black),
      ),
    );
  }
}