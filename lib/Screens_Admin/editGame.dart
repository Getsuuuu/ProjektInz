import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../Screens/game_details.dart';

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
                            builder: (context) => GameDetailsScreen(
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