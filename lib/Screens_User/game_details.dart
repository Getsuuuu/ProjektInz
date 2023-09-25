import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'search_User.dart';

class GameDetailsPageUser extends StatefulWidget {
  final ParseObject game;
  final String gameId;

  const GameDetailsPageUser({Key? key, required this.game, required this.gameId})
      : super(key: key);

  @override
  _GameDetailsPageUserState createState() => _GameDetailsPageUserState();
}

class _GameDetailsPageUserState extends State<GameDetailsPageUser> {
  ParseObject? _game;
  int _availableCopies = 0;

  @override
  void initState() {
    super.initState();
    fetchGameData();
  }

  Future<void> fetchGameData() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Gry'))
      ..whereEqualTo('objectId', widget.gameId)
      ..includeObject(['Zdjecie']);

    final response = await query.query();

    if (response.success &&
        response.results != null &&
        response.results!.isNotEmpty) {
      final game = response.results!.first;
      final availableCopies = game.get<int>('Egzemplarze') ?? 0;
      setState(() {
        _game = game;
        _availableCopies = availableCopies;
      });
    }
  }


  Future<void> _reserveGame() async {
    if (_availableCopies > 0) {
      setState(() {
        _availableCopies--;
      });

      _game?.set<int>('Egzemplarze', _availableCopies);
      final response = await _game?.save();

      if (response?.success == true) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Rezerwacja pomyślna'),
              content: Text('Gra została zarezerwowana.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => SearchPageUser()),
                    );
                  },
                ),
              ],
            );
          },
        );

        final egzemplarzQuery = QueryBuilder<ParseObject>(ParseObject('Egzemplarze'))
          ..whereEqualTo('gameId', widget.gameId)
          ..whereEqualTo('Status', 0)
          ..orderByAscending('unigueId')
          ..setLimit(1);

        final egzemplarzResponse = await egzemplarzQuery.query();

        if (egzemplarzResponse.success &&
            egzemplarzResponse.results != null &&
            egzemplarzResponse.results!.isNotEmpty) {
          final egzemplarz = egzemplarzResponse.results!.first;

          if (egzemplarz is ParseObject) {
            final currentUser = await ParseUser.currentUser();
            if (currentUser != null) {
              final now = DateTime.now();
              final week = now.add(const Duration(days: 7));

              final userPointer = ParseObject('_User')
                ..objectId = currentUser.objectId;

              final gamePointer = ParseObject('Gry')
                ..objectId = widget.gameId;

              final idPointer = ParseObject('Egzemplarze')
                ..objectId = egzemplarz['objectId'];

              final reservation = ParseObject('Rezerwacje')
                ..set('user', userPointer)
                ..set('gra', gamePointer)
                ..set('dataDoKoncaRezerwacji', week)
                ..set('Id', idPointer);

              final reservationResponse = await reservation.save();

              if (reservationResponse.success) {
                print('Reservation saved successfully!');
              } else {
                print('Error saving reservation: ${reservationResponse.error}');
              }
            }
          } else {
            print('Invalid type for egzemplarz');
          }
        } else {
          print('No available Egzemplarze found for the given game and status.');
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Rezerwacja niepomyślna'),
            content: Text('Nie udało się zarezerwować. Spróbuj ponownie'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final ParseFile? image = widget.game.get<ParseFile>('Zdjecie');
    String imageUrl = '';
    if (image != null) {
      imageUrl = image.url!;
    }

    bool hasAvailableCopies = _availableCopies > 0;

    return KeyedSubtree(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.game.get<String>('Nazwa') ?? ''),
        ),
        body: _game == null
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Padding(
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
                SizedBox(height: 16.0),
                Text(
                  'Nazwa: ${widget.game.get<String>('Nazwa') ?? ''}',
                  style: TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Wiek: ${widget.game.get<String>('Wiek') ?? ''}',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Liczba graczy: ${widget.game.get<String>('LiczbaGraczy') ??
                      ''}',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Kategoria: ${widget.game.get<String>('Kategoria') ?? ''}',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Opis: ${widget.game.get<String>('Opis') ?? ''}',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Dostępne egzemplarze: ${widget.game.get<int>(
                      'Egzemplarze') ?? 0}',
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: kToolbarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ReserveButton(
                  availableCopies: _availableCopies,
                  reserveGame: _reserveGame,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReserveButton extends StatelessWidget {
  final int availableCopies;
  final VoidCallback reserveGame;

  const ReserveButton({
    required this.availableCopies,
    required this.reserveGame,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasAvailableCopies = availableCopies > 0;

    return TextButton(
      onPressed: hasAvailableCopies
          ? () async {
              reserveGame();
            }
          : null,
      child: Text(
        'Zarezerwuj grę',
        style: TextStyle(
          fontSize: 18.0,
          color: hasAvailableCopies ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }
}
