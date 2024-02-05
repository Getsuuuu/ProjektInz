import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../Screens_Admin/editGame.dart';
import '../Screens_Admin/menu.dart';
import '../Screens_User/menu.dart';

class GameDetailsScreen extends StatefulWidget {
  final ParseObject game;
  final String gameId;

  const GameDetailsScreen({Key? key, required this.game, required this.gameId})
      : super(key: key);

  @override
  _GameDetailsScreenState createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  ParseObject? _game;
  bool isAdmin = false;
  int _availableCopies = 0;

  @override
  void initState() {
    super.initState();
    _fetchGameData();
  }

  Future<void> _fetchGameData() async {
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

  void _showEnlargedImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: double.infinity,
            height: 300.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
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
                      MaterialPageRoute(builder: (context) => MenuPageUser(initialIndex: 0),),
                    );
                  },
                ),
              ],
            );
          },
        );

        final egzemplarzQuery =
        QueryBuilder<ParseObject>(ParseObject('Egzemplarze'))
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

              final gamePointer = ParseObject('Gry')..objectId = widget.gameId;

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
          print(
              'No available Egzemplarze found for the given game and status.');
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

  Future<bool> isAdminUser() async {
    final ParseUser currentUser = await ParseUser.currentUser() as ParseUser;
    final bool isAdmin2 = currentUser.get<bool>('admin') ?? false;
    return isAdmin2;
  }

  List<ParseObject> gameList = [];

  @override
  Widget build(BuildContext context) {
    isAdminUser().then((isAdmin2) {
      setState(() {
        isAdmin = isAdmin2;
      });
    });
    final ParseFile? image = widget.game.get<ParseFile>('Zdjecie');
    String imageUrl = '';
    if (image != null) {
      imageUrl = image.url!;
    }

    bool hasAvailableCopies = _availableCopies > 0;

    Future<bool> deleteGame() async {
      final response = await widget.game.delete();

      if (response.success) {
        return true;
      } else {
        print(response.error?.message);
        return false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.get<String>('Nazwa') ?? ''),
        backgroundColor: Colors.red,
      ),
      body: _game == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showEnlargedImage(imageUrl);
                      },
                      child: Center(
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
                      'Liczba graczy: ${widget.game.get<String>(
                          'LiczbaGraczy') ?? ''}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Kategoria: ${widget.game.get<String>('Kategoria') ??
                          ''}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Opis: ${widget.game.get<String>('Opis') ?? ''}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Dostępne egzemplarze: ${widget.game.get<int>(
                          'Egzemplarze') ?? 0}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ),
          if (isAdmin)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditGameScreen(
                                gameId: widget.game.objectId,
                                game: widget.game,
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
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
                    child: Text('Edytuj grę'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(
                              title: Text('Czy na pewno chcesz usunąć tę grę?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text('Nie'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final deleted = await deleteGame();
                                    if (deleted) {
                                      Navigator.of(context).pop(true);
                                    }
                                  },
                                  child: Text('Tak'),
                                ),
                              ],
                            ),
                      );
                      if (confirm != null && confirm) {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MenuPageAdmin()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
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
                    child: Text('Usuń grę'),
                  ),
                ),
              ],
            ),
          if (isAdmin == false)
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: hasAvailableCopies
                    ? () async {
                  _reserveGame();
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  primary: hasAvailableCopies ? Colors.blue : Colors.grey,
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
                  minimumSize: Size(double.infinity, 0),
                ),
                child: Text(
                  'Zarezerwuj grę',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }}
