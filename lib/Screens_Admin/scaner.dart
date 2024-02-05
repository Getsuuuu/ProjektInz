import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'QRCodeResultPage.dart';

class ScanerPage extends StatefulWidget {
  @override
  _ScanerPageState createState() => _ScanerPageState();
}

class _ScanerPageState extends State<ScanerPage> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isCodeScanned = false;
  late String uniqueId;
  late String currentUser;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    controller.scannedDataStream.take(1).listen((scanData) {
      if (!isCodeScanned) {
        setState(() {
          isCodeScanned = true;
          result = scanData;
        });

        // Handle the scanned QR code
        handleScannedQRCode(result!.code!);
      }
    });
  }

  void handleScannedQRCode(String qrCodeData) async {
    await saveScannedQRCode(qrCodeData);

    // Navigate to the ScannedQrCodePage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannedQrCodePage(
          qrCodeData: qrCodeData,
          uniqueId: uniqueId,
          currentUser: currentUser,
          onReturn: () {
            setState(() {
              isCodeScanned = false;
            });
          },
        ),
      ),
    ).then((_) {
      setState(() {
        isCodeScanned = false;
      });
    });
  }

  Future<void> saveScannedQRCode(String qrCodeData) async {
    try {
      dynamic decodedData = json.decode(qrCodeData);

      if (decodedData is List<dynamic>) {
        if (decodedData.length > 0) {
          uniqueId = decodedData[0].toString();
          currentUser = decodedData.length > 1 ? decodedData[1].toString() : '';
        } else {
          throw Exception('Invalid decoded data format');
        }
      } else if (decodedData is Map<String, dynamic>) {
        uniqueId = decodedData['uniqueId'].toString();
        currentUser = decodedData['currentUser'].toString();
      } else {
        throw Exception('Invalid decoded data format');
      }
    } catch (e) {
      print('Error decoding QR code data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zeskanuj QR'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Theme.of(context).primaryColor,
                borderRadius: 10,
                borderWidth: 5,
                cutOutSize: 250,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
