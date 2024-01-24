import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReservePage extends StatefulWidget {
  @override
  _ReservePageState createState() => _ReservePageState();
}

class _ReservePageState extends State<ReservePage> {
  List<ParseObject>? reservedGames;
  late LiveQuery liveQuery;
  late Subscription qrCodeSubscription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchReservedGames();
    initializeLiveQuery();
  }

  void initializeLiveQuery() async {
    liveQuery = LiveQuery();

    final currentUser = await ParseUser.currentUser();

    if (currentUser != null) {
      final userPointer = ParseObject('_User')..objectId = currentUser.objectId;

      QueryBuilder<ParseObject> qrCodeQuery =
      QueryBuilder<ParseObject>(ParseObject('Rezerwacje'))
        ..whereEqualTo('user', userPointer)
        ..includeObject(['gra']);

      qrCodeSubscription = await liveQuery.client.subscribe(qrCodeQuery);

      qrCodeSubscription.on(LiveQueryEvent.create, (value) {
        print('Object created: $value');
      });

      qrCodeSubscription.on(LiveQueryEvent.update, (value) {
        print('Object updated: $value');
      });

      qrCodeSubscription.on(LiveQueryEvent.delete, (value) {
        print('Object deleted: $value');
      });

    }
  }

  @override
  void dispose() {
    liveQuery.client.unSubscribe(qrCodeSubscription);
    super.dispose();
  }

  Future<void> fetchReservedGames() async {
    setState(() {
      _isLoading = true;
    });

    final currentUser = await ParseUser.currentUser();
    final user = ParseObject('_User')..objectId = currentUser?.objectId;

    final rezerwacjeQuery = QueryBuilder<ParseObject>(ParseObject('Rezerwacje'))
      ..whereEqualTo('user', user)
      ..includeObject(['gra']);

    final rezerwacjeResponse = await rezerwacjeQuery.query();

    if (rezerwacjeResponse.success && rezerwacjeResponse.results != null) {
      final rezerwacje = rezerwacjeResponse.results!;

      final reservedGamesNotScanned = await Future.wait(rezerwacje.map((rezerwacja) async {
        final uniqueId = rezerwacja.get<String>('uniqueId');
        return !await isGameScanned(uniqueId) ? rezerwacja.get<ParseObject>('gra') : null;
      }));

      setState(() {
        reservedGames = reservedGamesNotScanned.where((game) => game != null).cast<ParseObject>().toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Error: ${rezerwacjeResponse.error}');
    }
  }

  Future<bool> isGameScanned(String uniqueId) async {
    final scannedQuery = QueryBuilder<ParseObject>(ParseObject('ScannedQR'))
      ..whereEqualTo('uniqueId', uniqueId);

    final scannedResponse = await scannedQuery.query();
    return scannedResponse.success && scannedResponse.results != null && scannedResponse.results!.isNotEmpty;
  }


  void refreshReservedGames() {
    fetchReservedGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zarezerwowane gry'),
      ),
      body: Stack(
        children: [
          _buildReservedGamesList(),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReservedGamesList() {
    if (_isLoading) {
      return Container();
    } else if (reservedGames != null && reservedGames!.isNotEmpty) {
      return ListView.builder(
        itemCount: reservedGames!.length,
        itemBuilder: (context, index) {
          final game = reservedGames![index];
          final gameName = game.get<String>('Nazwa');
          final ParseFile? image = game.get<ParseFile>('Zdjecie');
          String imageUrl = '';
          if (image != null) {
            imageUrl = image.url!;
          }

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameDetailsScreenUser(
                    game: game,
                    gameId: game.objectId ?? '',
                    refreshReservedGames: refreshReservedGames,
                  ),
                ),
              );
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: ClipOval(
                  child: FadeInImage(
                    placeholder: AssetImage('assets/loader.gif'),
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                    width: 40.0,
                    height: 40.0,
                  ),
                ),
                title: Text(gameName ?? ''),
              ),
            ),
          );
        },
      );
    } else {
      return Center(
        child: Text(
          'Nic tu nie ma',
          style: TextStyle(fontSize: 16.0),
        ),
      );
    }
  }
}

class GameDetailsScreenUser extends StatelessWidget {
  final ParseObject game;
  final String gameId;
  final VoidCallback refreshReservedGames;

  GameDetailsScreenUser({
    required this.game,
    required this.gameId,
    required this.refreshReservedGames,
  });

  @override
  Widget build(BuildContext context) {
    final ParseFile? image = game.get<ParseFile>('Zdjecie');
    String imageUrl = '';
    if (image != null) {
      imageUrl = image.url!;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Informacje o grze'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: FadeInImage(
                  placeholder: AssetImage('assets/loader.gif'),
                  image: CachedNetworkImageProvider(imageUrl),
                  fit: BoxFit.cover,
                  width: 200.0,
                  height: 200.0,
                ),
              ),
            ),
            Text(
              'Nazwa: ${game.get<String>('Nazwa') ?? ''}',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Text(
              'Wiek: ${game.get<String>('Wiek') ?? ''}',
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              'Liczba graczy: ${game.get<String>('LiczbaGraczy') ?? ''}',
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              'Kategoria: ${game.get<String>('Kategoria') ?? ''}',
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              'Opis: ${game.get<String>('Opis') ?? ''}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final currentUser = await ParseUser.currentUser();

                    final uniqueIdQuery =
                    QueryBuilder<ParseObject>(ParseObject('Rezerwacje'))
                      ..whereEqualTo('user', currentUser)
                      ..whereEqualTo('gra', game);

                    final uniqueIdResponse = await uniqueIdQuery.query();

                    String uniqueId = '';
                    if (uniqueIdResponse.success &&
                        uniqueIdResponse.results != null &&
                        uniqueIdResponse.results!.isNotEmpty) {
                      final rezerwacje = uniqueIdResponse.results!.first;
                      uniqueId = rezerwacje.get<String>('uniqueId') ?? '';
                    }

                    final List<String> jsonData = [
                      uniqueId,
                      currentUser.username
                    ];
                    final jsonString = json.encode(jsonData);

                    showQRCodeModal(context, jsonString);

                    var subscription = await LiveQuery().client.subscribe(
                      QueryBuilder<ParseObject>(ParseObject('ScannedQR')),
                    );
                    subscription.on(LiveQueryEvent.create, (value) {
                      print('Event type: ${value.runtimeType}');
                      if (value is ParseObject) {
                        final uniqueIdFromUpdate = value.get<String>('uniqueId');
                        if (uniqueIdFromUpdate == uniqueId) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          refreshReservedGames();
                        }
                      } else {
                        print('Unexpected event type: $value');
                      }
                    });
                  },
                  child: Text('Odbierz gre'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Anuluj rezerwację'),
                          content:
                          Text('Czy na pewno chcesz usunąć rezerwację?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text('Nie'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                Navigator.pop(context);

                                final currentUser =
                                await ParseUser.currentUser();
                                final userPointer = ParseObject('_User')
                                  ..objectId = currentUser.objectId;
                                final gamePointer = ParseObject('Gry')
                                  ..objectId = gameId;

                                final query = QueryBuilder<ParseObject>(
                                    ParseObject('Rezerwacje'))
                                  ..whereEqualTo('user', userPointer)
                                  ..whereEqualTo('gra', gamePointer);

                                final response = await query.query();

                                if (response.success &&
                                    response.results != null &&
                                    response.results!.isNotEmpty) {
                                  final reservation = response.results![0];
                                  final uniqueId =
                                  reservation.get<String>('uniqueId');
                                  final egzemplarzeQuery = QueryBuilder<
                                      ParseObject>(ParseObject('Egzemplarze'))
                                    ..whereEqualTo('uniqueId', uniqueId)
                                    ..whereEqualTo('Status', 1);

                                  final egzemplarzeResponse =
                                  await egzemplarzeQuery.query();

                                  if (egzemplarzeResponse.success &&
                                      egzemplarzeResponse.results != null &&
                                      egzemplarzeResponse.results!.isNotEmpty) {
                                    final egzemplarz =
                                    egzemplarzeResponse.results![0];
                                    egzemplarz.set('Status', 0);
                                    final saveResponse =
                                    await egzemplarz.save();

                                    if (saveResponse.success) {
                                      final deleteResponse =
                                      await reservation.delete();

                                      if (deleteResponse.success) {
                                        final gryQuery = QueryBuilder<
                                            ParseObject>(ParseObject('Gry'))
                                          ..whereEqualTo('objectId', gameId);

                                        final gryResponse =
                                        await gryQuery.query();

                                        if (gryResponse.success &&
                                            gryResponse.results != null &&
                                            gryResponse.results!.isNotEmpty) {
                                          final gry = gryResponse.results![0];
                                          final currentValue =
                                              gry.get<int>('Egzemplarze') ?? 0;
                                          final incrementedValue =
                                              currentValue + 1;
                                          gry.set(
                                              'Egzemplarze', incrementedValue);
                                          await gry.save();
                                          refreshReservedGames();

                                          Navigator.pop(context);
                                        } else {
                                          print('Nie znaleziony gry.');
                                        }
                                      } else {
                                        print(
                                            'Error podczas usuwania rezerwacji: ${deleteResponse.error}');
                                      }
                                    } else {
                                      print(
                                          'Error podczas zapisywania: ${saveResponse.error}');
                                    }
                                  } else {
                                    print('Nie znaleziono egzemplarzy.');
                                  }
                                } else {
                                  print('Nie znaleziono rezerwacji.');
                                }
                              },
                              child: Text('Tak'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Anuluj rezerwację'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showQRCodeModal(BuildContext context, String data) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            QrImageView(
              data: data,
              version: QrVersions.auto,
              size: 200.0,
            ),
            SizedBox(height: 16.0),
            Text(
              'Zeskanuj kod QR',
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
