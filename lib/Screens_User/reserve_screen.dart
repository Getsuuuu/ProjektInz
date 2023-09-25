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

  @override
  void initState() {
    super.initState();
    fetchReservedGames();
  }


  Future<void> fetchReservedGames() async {
    final currentUser = await ParseUser.currentUser();
    final user = ParseObject('_User')..objectId = currentUser?.objectId;

    final query = QueryBuilder<ParseObject>(ParseObject('Rezerwacje'))
      ..whereEqualTo('user', user)
      ..includeObject(['gra']);

    final response = await query.query();

    if (response.success && response.results != null) {
      setState(() {
        reservedGames = response.results!
            .map((result) => result.get<ParseObject>('gra'))
            .where((game) => game != null) // Filter out null values
            .cast<ParseObject>()
            .toList();
      });
    } else {
      print('Error fetching reserved games: ${response.error}');
    }
  }
  void refreshReservedGames() {
    fetchReservedGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reserved Games'),
      ),
      body: reservedGames != null && reservedGames!.isNotEmpty
          ? ListView.builder(
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
            )
          : Center(
              child: Text(
                'Nic tu nie ma',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
    );
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
        title: Text('Game Details'),
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
                    String currentUserEmail = '';
                    final currentUser = await ParseUser.currentUser();
                    final userQuery =
                    QueryBuilder<ParseUser>(ParseUser.forQuery())
                      ..whereEqualTo('objectId', currentUser.objectId)
                      ..setLimit(1);

                    final response = await userQuery.query();
                    if (response.success &&
                        response.results != null &&
                        response.results!.isNotEmpty) {
                      final user = response.results!.first;
                      currentUserEmail = user.get<String>('email') ?? '';
                    }

                    final uniqueIdQuery =
                    QueryBuilder<ParseObject>(ParseObject('Rezerwacje'))
                      ..whereEqualTo('user', currentUser)..whereEqualTo(
                        'gra', game);

                    final uniqueIdResponse = await uniqueIdQuery.query();

                    String uniqueId = '';
                    if (uniqueIdResponse.success &&
                        uniqueIdResponse.results != null &&
                        uniqueIdResponse.results!.isNotEmpty) {
                      final rezerwacje = uniqueIdResponse.results!.first;
                      uniqueId = rezerwacje.get<String>('uniqueId') ?? '';
                    }

                    String qrCodeData =
                        'Nazwa: ${game.get<String>('Nazwa') ?? ''}\n'
                        'Wiek: ${game.get<String>('Wiek') ?? ''}\n'
                        'Liczba graczy: ${game.get<String>('LiczbaGraczy') ??
                        ''}\n'
                        'Kategoria: ${game.get<String>('Kategoria') ?? ''}\n'
                        'Opis: ${game.get<String>('Opis') ?? ''}\n'
                        'Dla użytkownika: $currentUserEmail\n'
                        'Id gry: $uniqueId';
                    final data = {
                      'Nazwa': game.get<String>('Nazwa') ?? '',
                      'Wiek': game.get<String>('Wiek') ?? '',
                      'Liczba graczy': game.get<String>('LiczbaGraczy') ?? '',
                      'Kategoria': game.get<String>('Kategoria') ?? '',
                      'Opis': game.get<String>('Opis') ?? '',
                      'Dla użytkownika': currentUserEmail,
                      'Id gry': uniqueId,
                    };
                    final jsonData = json.encode(data);

                    showQRCodeModal(context, jsonData);
                  },
                  child: Text('Odbierz gre'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Anuluj rezerwacje'),
                          content: Text('Czy na pewno chcesz usunać rezerwacje?'),
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

                                final currentUser = await ParseUser.currentUser();
                                final userPointer = ParseObject('_User')
                                  ..objectId = currentUser.objectId;
                                final gamePointer = ParseObject('Gry')
                                  ..objectId = gameId;

                                final query =
                                QueryBuilder<ParseObject>(ParseObject('Rezerwacje'))
                                  ..whereEqualTo('user', userPointer)
                                  ..whereEqualTo('gra', gamePointer);

                                final response = await query.query();

                                if (response.success &&
                                    response.results != null &&
                                    response.results!.isNotEmpty) {
                                  final reservation = response.results![0];
                                  final uniqueId = reservation.get<String>('uniqueId');
                                  final egzemplarzeQuery =
                                  QueryBuilder<ParseObject>(ParseObject('Egzemplarze'))
                                    ..whereEqualTo('uniqueId', uniqueId)
                                    ..whereEqualTo('Status', 1);

                                  final egzemplarzeResponse = await egzemplarzeQuery.query();

                                  if (egzemplarzeResponse.success &&
                                      egzemplarzeResponse.results != null &&
                                      egzemplarzeResponse.results!.isNotEmpty) {
                                    final egzemplarz = egzemplarzeResponse.results![0];
                                    egzemplarz.set('Status', 0);
                                    final saveResponse = await egzemplarz.save();

                                    if (saveResponse.success) {
                                      final deleteResponse = await reservation.delete();

                                      if (deleteResponse.success) {
                                        final gryQuery =
                                        QueryBuilder<ParseObject>(ParseObject('Gry'))
                                          ..whereEqualTo('objectId', gameId);

                                        final gryResponse = await gryQuery.query();

                                        if (gryResponse.success &&
                                            gryResponse.results != null &&
                                            gryResponse.results!.isNotEmpty) {
                                          final gry = gryResponse.results![0];
                                          final currentValue =
                                              gry.get<int>('Egzemplarze') ?? 0;
                                          final incrementedValue = currentValue + 1;
                                          gry.set('Egzemplarze', incrementedValue);
                                          await gry.save();
                                          refreshReservedGames();

                                          Navigator.pop(context);
                                        } else {
                                          print('Game object not found.');
                                        }
                                      } else {
                                        print(
                                            'Error deleting reservation object: ${deleteResponse.error}');
                                      }
                                    } else {
                                      print(
                                          'Error saving Egzemplarze object: ${saveResponse.error}');
                                    }
                                  } else {
                                    print('Matching Egzemplarze object not found.');
                                  }
                                } else {
                                  print('Reservation not found.');
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
