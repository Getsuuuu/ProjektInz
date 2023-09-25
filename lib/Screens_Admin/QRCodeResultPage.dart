import 'package:flutter/material.dart';

class QRCodeResultPage extends StatelessWidget {
  final String? qrCodeData;

  QRCodeResultPage({required this.qrCodeData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Result'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            qrCodeData ?? 'No data available',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }
}
