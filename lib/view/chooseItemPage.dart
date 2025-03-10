import 'package:flutter/material.dart';

class ChooseItemPage extends StatefulWidget {
  const ChooseItemPage({super.key});

  _ChooseItemState createState() => _ChooseItemState();
}

class _ChooseItemState extends State<ChooseItemPage> {
  Widget build(BuildContext) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Barang'),
        titleTextStyle: TextStyle(fontSize: 20, color: Colors.black),
        backgroundColor: Colors.blue[200],
        centerTitle: true,
      ),
    );
  }
}
