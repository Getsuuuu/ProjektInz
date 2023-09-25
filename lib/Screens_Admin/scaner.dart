import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanerPage extends StatefulWidget {
  @override
  _ScanerPageState createState() => _ScanerPageState();
}

class _ScanerPageState extends State<ScanerPage> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isCodeScanned = false; // Flag to track if QR code has been scanned

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Listen for changes in the route
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (route != null) {
      if (route.isCurrent && isCodeScanned) {
        // Reset the flag if the route is current (scanned code has been returned from the result page)
        setState(() {
          isCodeScanned = false;
        });
      }
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      if (!isCodeScanned) {
        setState(() {
          isCodeScanned = true; // Set the flag to true to prevent multiple scans
          result = scanData;

          // Process the scan data here
          print('Scanned QR code: ${scanData.code}');

          // Open the QRCodeResultPage with the scanned QR code data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QRCodeResultPage(
                qrCodeData: scanData.code ?? '',
                onReturn: () {
                  setState(() {
                    isCodeScanned = false; // Reset the flag when returning from QRCodeResultPage
                  });
                },
              ),
            ),
          ).then((_) {
            // After returning from the QRCodeResultPage, reset the flag
            setState(() {
              isCodeScanned = false;
            });
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
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
          SizedBox(height: 20),
          Text(
            'Scanning QR Code...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class QRCodeResultPage extends StatelessWidget {
  final String qrCodeData;
  final VoidCallback onReturn;

  const QRCodeResultPage({required this.qrCodeData, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Result'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(qrCodeData),
            ElevatedButton(
              onPressed: () {
                // Return to the previous screen
                Navigator.pop(context);
              },
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
