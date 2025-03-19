import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<ScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'qr');
  QRViewController? controller;
  String scannedData = "";

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scannedData = scanData.code ?? "";
      });
      Navigator.pop(context, scannedData);
    });
  }

  @override
  Widget build(BuildContext) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan Barcode"),
        backgroundColor: Colors.blue[200],
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, color: Colors.black),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
          )
        ],
      ),
    );
  }
}
