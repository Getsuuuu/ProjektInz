import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../Screens/search.dart';
import 'menu.dart';

class SearchPageAdmin extends StatefulWidget {
  const SearchPageAdmin({Key? key, required this.title});

  final String title;

  @override
  State<SearchPageAdmin> createState() => _SearchPageAdminState();
}

class _SearchPageAdminState extends State<SearchPageAdmin> {
  List<ParseObject> gameList = [];
  List<ParseObject> searchResults = [];
  bool _isLoading = false;
  bool _isLastPage = false;
  int pageKey = 0;
  int _pageSize = 15;
  final double _scrollThreshold = 200.0;
  bool isLoading = false;
  bool isLoadingMore = false;
  String searchQuery = '';
  bool isSearching = false;
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchGameList();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        !isLoadingMore) {
      loadMoreData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchGameList({String? searchQuery}) async {
    if (_isLoading || _isLastPage) return;

    setState(() {
      _isLoading = true;
    });

    final queryBuilder = QueryBuilder<ParseObject>(ParseObject('Gry'))
      ..orderByDescending('objectId')
      ..setLimit(_pageSize)
      ..setAmountToSkip(pageKey * _pageSize);

    // Dodajemy warunek wyszukiwania, jeśli searchQuery nie jest pusty
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryBuilder.whereContains('Nazwa', searchQuery);
    }

    final response = await queryBuilder.query();

    if (response.success && response.results != null) {
      setState(() {
        if (searchQuery != null && searchQuery.isNotEmpty) {
          isSearching = true; // Ustaw flagę isSearching na true
          searchResults.addAll(response.results! as List<ParseObject>);
        } else {
          isSearching = false; // Ustaw flagę isSearching na false
          gameList.addAll(response.results! as Iterable<ParseObject>);
        }
        pageKey++;
        _isLoading = false;
        _isLastPage = response.results!.length < _pageSize;
      });
    }

    if (_scrollController.position.maxScrollExtent -
            _scrollController.position.pixels <=
        _scrollThreshold) {
      fetchGameList(searchQuery: searchQuery);
    }
  }

  Future<void> loadMoreData() async {
    if (!isLoading && !_isLastPage) {
      await fetchGameList(searchQuery: searchQuery);
    }
  }

  void refreshListBySearchQuery() async {
    setState(() {
      searchResults.clear();
      pageKey = 0;
      searchQuery = _searchController.text;
      isSearching = true; // Ustaw flagę isSearching na true
    });
    await fetchGameList(searchQuery: searchQuery);
  }

  void navigateToSortScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SortScreen()),
    );
  }

  void navigateToFilterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FilterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    int itemCount = isSearching ? searchResults.length : gameList.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: refreshListBySearchQuery,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            searchResults.clear();
            gameList.clear();
            pageKey = 0;
          });
          await fetchGameList(searchQuery: searchQuery);
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Wyszukaj grę',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: refreshListBySearchQuery,
                        ),
                      ),
                      onSubmitted: (value) {
                        refreshListBySearchQuery();
                      },
                    ),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: navigateToSortScreen,
                    child: Text('Sortuj'),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: navigateToFilterScreen,
                    child: Text('Filtruj'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: itemCount == 0
                  ? Center(
                      child: Text('No games found'),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: itemCount + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == itemCount) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: isLoadingMore
                                  ? CircularProgressIndicator()
                                  : null,
                            ),
                          );
                        } else {
                          final ParseObject game = isSearching
                              ? searchResults[index]
                              : gameList[index];
                          final ParseFile? image =
                              game.get<ParseFile>('Zdjecie');
                          String imageUrl = '';
                          if (image != null) {
                            imageUrl = image.url!;
                          }
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GameDetailsScreenAdmin(
                                    game: game,
                                    gameId: game.objectId ?? '',
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
                                    placeholder:
                                        AssetImage('assets/loader.gif'),
                                    image: CachedNetworkImageProvider(
                                      imageUrl,
                                    ),
                                    fit: BoxFit.cover,
                                    width: 40.0,
                                    height: 40.0,
                                  ),
                                ),
                                title: Text(game.get<String>('Nazwa') ?? ''),
                              ),
                            ),
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class SortScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sortowanie'),
      ),
      body: Center(
        child: Text('Sortowanie'),
      ),
    );
  }
}

class FilterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtrowanie'),
      ),
      body: Center(
        child: Text('Filtrowanie'),
      ),
    );
  }
}

class GameDetailsScreenAdmin extends StatefulWidget {
  final ParseObject game;
  final String gameId;

  const GameDetailsScreenAdmin(
      {Key? key, required this.game, required this.gameId})
      : super(key: key);

  @override
  _GameDetailsScreenAdminState createState() => _GameDetailsScreenAdminState();
}

class _GameDetailsScreenAdminState extends State<GameDetailsScreenAdmin> {
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
                      MaterialPageRoute(builder: (context) => SearchPage()),
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

  Future<bool> isAdminUser() async {
    final ParseUser currentUser = await ParseUser.currentUser() as ParseUser;
    final bool isAdmin = currentUser.get<bool>('admin') ?? false;
    return isAdmin;
  }

  List<ParseObject> gameList = [];
  @override
  Widget build(BuildContext context) {
    isAdminUser().then((isAdmin) {
      setState(() {
        isAdmin = isAdmin;
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
                      'Liczba graczy: ${widget.game.get<String>('LiczbaGraczy') ?? ''}',
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
                    SizedBox(height: 8.0),
                    Text(
                      'Dostępne egzemplarze: ${widget.game.get<int>('Egzemplarze') ?? 0}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (isAdmin)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditGameScreen(
                                    gameId: widget.game.objectId,
                                    game: widget.game,
                                  ),
                                ),
                              );
                            },
                            child: Text('Edytuj grę'),
                          ),
                        if (isAdmin)
                          ElevatedButton(
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                      'Czy na pewno chcesz usunąć tę grę?'),
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
                            child: Text('Usuń grę'),
                          ),
                        if (_availableCopies > 0) ElevatedButton(
                          onPressed: hasAvailableCopies
                              ? () async {
                            _reserveGame();
                          }
                              : null,
                          child: Text(
                            'Zarezerwuj grę',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: hasAvailableCopies ? Colors.blue : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class EditGameScreen extends StatefulWidget {
  final ParseObject game;
  final String? gameId;

  const EditGameScreen({Key? key, required this.gameId, required this.game})
      : super(key: key);

  @override
  _EditGameScreenState createState() => _EditGameScreenState();
}

class _EditGameScreenState extends State<EditGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final controllerNazwa = TextEditingController();
  final controllerLiczbaGraczyOd = TextEditingController();
  final controllerLiczbaGraczyDo = TextEditingController();
  final controllerKategoria = TextEditingController();
  final controllerOpis = TextEditingController();
  final controllerObraz = TextEditingController();
  final controllerEgzemplarze = TextEditingController();
  String? controllerWiek;
  int? _from;
  int? _to;
  File? _compressedFile;
  File? _image;
  bool isLoading = false;
  String _gameImage = '';
  List<String> _age = [
    "2+",
    "3+",
    "4+",
    "5+",
    "6+",
    "7+",
    "8+",
    "9+",
    "10+",
    "11+",
    "12+",
    "13+",
    "14+",
    "15+",
    "16+",
    "17+",
    "18+"
  ];

  @override
  void initState() {
    super.initState();
    _loadGameDetails();
  }

  Future<void> _loadGameDetails() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Gry'))
      ..whereEqualTo('objectId', widget.gameId);
    final result = await query.query();

    if (result.success &&
        result.results != null &&
        result.results!.isNotEmpty) {
      final game = result.results!.first;
      controllerNazwa.text = game.get<String>('Nazwa') ?? '';
      controllerWiek = game.get<String>('Wiek') ?? '';
      controllerKategoria.text = game.get<String>('Kategoria') ?? '';
      controllerOpis.text = game.get<String>('Opis') ?? '';
      String? liczbaGraczy = game.get<String>('LiczbaGraczy');
      int? egz = game.get<int>('Egzemplarze');
      controllerEgzemplarze.text = egz?.toString() ?? '';
      if (liczbaGraczy != null) {
        List<String> liczbaGraczyParts = liczbaGraczy.split('-');
        if (liczbaGraczyParts.length == 2) {
          controllerLiczbaGraczyOd.text = liczbaGraczyParts[0].trim();
          controllerLiczbaGraczyDo.text = liczbaGraczyParts[1].trim();
        }
      }

      final ParseFile? image = game.get<ParseFile>('Zdjecie');
      String imageUrl = '';
      if (image != null) {
        imageUrl = image.url!;
      }

      setState(() {
        _gameImage = imageUrl;
      });
    }
  }

  Future<void> compress() async {
    try {
      var result = await FlutterImageCompress.compressAndGetFile(
        _image!.absolute.path,
        _image!.path + 'compressed.jpg',
        quality: 50,
      );
      setState(() {
        _compressedFile = result as File?;
      });
    } catch (e) {
      print('Error: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Nie udało się wysłać. Prosze spróbować jeszcze raz.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Edycja gry'),
        ),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: controllerNazwa,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        labelText: 'Nazwa'),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: controllerWiek,
                    items: _age.map((wiek) {
                      return DropdownMenuItem(
                        value: wiek,
                        child: Text(wiek),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        controllerWiek = newValue;
                      });
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        labelText: 'Wiek'),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controllerLiczbaGraczyOd,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          autocorrect: false,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              labelText: 'Od'),
                          onChanged: (text) {
                            _from = int.tryParse(text);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: TextField(
                          controller: controllerLiczbaGraczyDo,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          autocorrect: false,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              labelText: 'Do'),
                          onChanged: (text) {
                            _to = int.tryParse(text);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: controllerEgzemplarze,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelText: 'Liczba egzemplarzy',
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: controllerKategoria,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        labelText: 'Kategoria'),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: controllerOpis,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        labelText: 'Opis'),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: _gameImage,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.cover,
                        width: 200.0,
                        height: 200.0,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showGallery().then((value) {});
                    },
                    child: Text('Wybierz zdjecie'),
                  ),
                  Container(
                    height: 50,
                    child: ElevatedButton(
                      child: isLoading
                          ? CircularProgressIndicator()
                          : Text('Zaktualizuj'),
                      style: ElevatedButton.styleFrom(primary: Colors.blue),
                      onPressed: isLoading ||
                              (_image == null && widget.game['Zdjecie'] == null)
                          ? null
                          : () async {
                              setState(() {
                                isLoading = true;
                              });

                              ParseFileBase? parseFile;

                              if (_image != null) {
                                await compress();

                                if (kIsWeb) {
                                  parseFile = ParseWebFile(
                                      await _compressedFile!.readAsBytes(),
                                      name: 'image.jpg');
                                } else {
                                  parseFile =
                                      ParseFile(File(_compressedFile!.path));
                                }

                                await parseFile.save();
                              } else {
                                parseFile =
                                    widget.game.get<ParseFileBase>('Zdjecie');
                              }

                              final nazwa = controllerNazwa.text.trim();
                              final wiek = controllerWiek;
                              final liczbaGraczy = '$_from-$_to';
                              final kategoria = controllerKategoria.text.trim();
                              final opis = controllerOpis.text.trim();
                              String egzemplarzeText =
                                  controllerEgzemplarze.text;
                              int? egzemplarze = int.tryParse(egzemplarzeText);

                              ParseObject gry = ParseObject('Gry')
                                ..objectId = widget.gameId;
                              gry.set('Nazwa', nazwa);
                              gry.set('Wiek', wiek);
                              gry.set('LiczbaGraczy', liczbaGraczy);
                              gry.set('Kategoria', kategoria);
                              gry.set('Opis', opis);
                              gry.set('Zdjecie', parseFile);
                              gry.set('Egzemplarze', egzemplarze);
                              await gry.save();

                              setState(() {
                                isLoading = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Dane zostały zapisane'),
                                  duration: Duration(seconds: 3),
                                ),
                              );

                              await Future.delayed(Duration(seconds: 2));
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GameDetailsScreenAdmin(
                                    game: widget.game,
                                    gameId: widget.game?.objectId ?? '',
                                  ),
                                ),
                              ).then((value) {
                                setState(() {
                                  // Wywołaj setState, aby odświeżyć widok GameDetailsScreen
                                });
                              });
                            },
                    ),
                  ),
                ],
              ),
            )));
  }

  Future<void> _showGallery() async {
    final ImagePicker _picker = ImagePicker();

    // Show options for camera or gallery
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select the image source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ElevatedButton(
                  child: Text('Gallery'),
                  onPressed: () async {
                    Navigator.pop(context);
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _image = File(image.path);
                      });
                      _showConfirmationDialog();
                    }
                  },
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  child: Text('Camera'),
                  onPressed: () async {
                    Navigator.pop(context);
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      setState(() {
                        _image = File(image.path);
                      });
                      _showConfirmationDialog();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showConfirmationDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Image'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Image.file(_image!),
                SizedBox(height: 8),
                ElevatedButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _image = null;
                    });
                  },
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  child: Text('Send'),
                  onPressed: () async {
                    Navigator.pop(context, _image);
                    setState(() {
                      isLoading = true;
                    });

                    ParseFileBase? parseFile;

                    try {
                      await compress();

                      if (kIsWeb) {
                        parseFile = ParseWebFile(
                          await _compressedFile!.readAsBytes(),
                          name: 'image.jpg',
                        );
                      } else {
                        parseFile = ParseFile(_compressedFile!);
                      }

                      await parseFile.save();

                      setState(() {
                        _gameImage = parseFile!.url!;
                        isLoading = false;
                      });
                    } catch (e) {
                      print('Error: $e');
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Error'),
                          content: Text(
                              'Nie udało się wysłać. Proszę spróbować jeszcze raz.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
