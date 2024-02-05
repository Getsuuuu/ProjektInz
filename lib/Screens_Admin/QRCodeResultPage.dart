import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ScannedQrCodePage extends StatefulWidget {
  final String qrCodeData;
  final VoidCallback onReturn;
  final String uniqueId;
  final String currentUser;

  ScannedQrCodePage({
    required this.qrCodeData,
    required this.onReturn,
    required this.uniqueId,
    required this.currentUser,
  });

  @override
  _ScannedQrCodePageState createState() => _ScannedQrCodePageState();
}

class _ScannedQrCodePageState extends State<ScannedQrCodePage> {
  String? imageUrl;
  String nazwa = '';

  Future<String> _fetchGameId() async {
    try {
      final egzemplarzeQuery =
          QueryBuilder<ParseObject>(ParseObject('Egzemplarze'))
            ..whereEqualTo('uniqueId', widget.uniqueId)
            ..setLimit(1);

      final ParseResponse response = await egzemplarzeQuery.query();

      if (response.success &&
          response.results != null &&
          response.results!.isNotEmpty) {
        final ParseObject egzemplarzeObject = response.results!.first;
        return egzemplarzeObject.get<String>('gameId') ?? '';
      } else {
        print('Error fetching gameId: ${response.error}');
        return '';
      }
    } catch (e) {
      print('Error fetching gameId: $e');
      return '';
    }
  }

  Future<void> _buildGameImage(String gameId) async {
    try {
      final gryQuery = QueryBuilder<ParseObject>(ParseObject('Gry'))
        ..whereEqualTo('objectId', gameId)
        ..setLimit(1);

      final ParseResponse response = await gryQuery.query();

      if (response.success &&
          response.results != null &&
          response.results!.isNotEmpty) {
        final ParseObject gryObject = response.results!.first;
        final ParseFile? image = gryObject.get<ParseFile>('Zdjecie');

        if (image != null) {
          setState(() {
            imageUrl = image.url!;
          });
        } else {
          print('Error fetching image: Image not found');
        }

        nazwa = gryObject.get<String>('Nazwa') ?? '';
      } else {
        print('Error fetching image: ${response.error}');
      }
    } catch (e) {
      print('Error fetching image: $e');
    }
  }

  void _showEnlargedImage(BuildContext context) {
    if (imageUrl != null) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              width: double.infinity,
              height: 300.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(imageUrl!),
                  fit: BoxFit
                      .cover, // Use BoxFit.cover to fill the available space
                ),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.uniqueId != null && widget.uniqueId.isNotEmpty) {
      print('UniqueId is valid: ${widget.uniqueId}');
      _fetchGameId().then((gameId) => _buildGameImage(gameId));
    } else {
      print('Invalid or empty UniqueId');
      // Handle the case where uniqueId is not valid
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Zeskanowany kod QR'),
          backgroundColor: Colors.green,
        ),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            imageUrl != null
                ? Center(
                    child: GestureDetector(
                      onTap: () {
                        _showEnlargedImage(context);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: FadeInImage(
                          placeholder: AssetImage('assets/loader.gif'),
                          image: CachedNetworkImageProvider(imageUrl!),
                          fit: BoxFit.cover,
                          width: 200.0,
                          height: 200.0,
                        ),
                      ),
                    ),
                  )
                : Text(
                    'Brak zdjęcia',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
            Text(
              'Nazwa: $nazwa',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Text(
              'Nazwa odbierającego: ' + widget.currentUser,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: () async {
                          final ParseObject scannedQRObject =
                              ParseObject('ScannedQR')
                                ..set<String>('uniqueId', widget.uniqueId)
                                ..set<String>('user', widget.currentUser)
                                ..set<bool>('scanned', true);

                          final ParseResponse response =
                              await scannedQRObject.save();

                          if (response.success) {
                            print('Zeskanowane dane zapisane');
                          } else {
                            print(
                                'Error podczas zapisywania danych: ${response.error}');
                          }
                          Navigator.popUntil(
                              context, ModalRoute.withName('/menuAdmin'));
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          // Background color
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                            vertical: 20.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                          ),
                        ),
                        child: Text('Wypożycz'))),
                Expanded(
                    child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(
                        context, ModalRoute.withName('/menuAdmin'));
                    widget.onReturn();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    // Background color
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(
                      vertical: 20.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                    ),
                  ),
                  child: Text('Anuluj'),
                )),
              ],
            ),
          ]),
        ));
  }
}
