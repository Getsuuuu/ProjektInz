import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../Screens/game_details.dart';
import 'menu.dart';

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
  String? controllerLiczbaGraczy;
  String? controllerKategoria;
  final controllerOpis = TextEditingController();
  final controllerObraz = TextEditingController();
  final controllerEgzemplarze = TextEditingController();
  String? controllerWiek;
  File? _compressedFile;
  File? _image;
  bool isLoading = false;
  String _gameImage = '';
  List<String> _age = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17",
    "18",
    "1+",
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
  List<String> _category = [];

  @override
  void initState() {
    super.initState();
    _loadGameDetails();
    _fetchCategories();
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
      controllerKategoria = game.get<String>('Kategoria') ?? '';
      controllerLiczbaGraczy = game.get<String>('LiczbaGraczy') ?? '';
      controllerOpis.text = game.get<String>('Opis') ?? '';
      int? egz = game.get<int>('Egzemplarze');
      controllerEgzemplarze.text = egz?.toString() ?? '';

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

  Future<void> _fetchCategories() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Kategorie'));
    final response = await query.query();

    if (response.success && response.results != null) {
      setState(() {
        _category = response.results!
            .map<String>((category) => category.get<String>('Kategoria') ?? '')
            .toList();
      });
    } else {
      print('Error: ${response.error}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Edycja gry'),
          backgroundColor: Colors.red,
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
                  TextFormField(
                    controller: controllerNazwa,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelText: 'Nazwa',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nazwa nie może być pusta';
                      }
                      return null;
                    },
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
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelText: 'Wiek',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wiek nie może być pusty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: controllerLiczbaGraczy,
                    items: _age.map((gracze) {
                      return DropdownMenuItem(
                        value: gracze,
                        child: Text(gracze),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        controllerLiczbaGraczy = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelText: 'Liczba graczy',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Liczba graczy nie może być pusta';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Liczba egzemplarzy nie może być pusta';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: controllerKategoria,
                    items: _category.map((kategoria) {
                      return DropdownMenuItem(
                        value: kategoria,
                        child: Text(kategoria),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        controllerKategoria = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelText: 'Kategoria',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kategoria nie może być pusta';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: controllerOpis,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        labelText: 'Opis'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Opis nie może być pusty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Center(
                      child: GestureDetector(
                    onTap: () {
                      _getImage();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl: _gameImage,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          fit: BoxFit.cover,
                          width: 200.0,
                          height: 200.0,
                        ),
                      ),
                    ),
                  )),
                  SizedBox(height: 16.0,),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: isLoading
                          ? CircularProgressIndicator()
                          : Text('Zaktualizuj'),
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
                      onPressed: isLoading ||
                          (_image == null && widget.game['Zdjecie'] == null)
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
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
                                final liczbaGraczy = controllerLiczbaGraczy;
                                final kategoria = controllerKategoria;
                                final opis = controllerOpis.text.trim();
                                String egzemplarzeText =
                                    controllerEgzemplarze.text;
                                int? egzemplarze =
                                    int.tryParse(egzemplarzeText);

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
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => MenuPageAdmin(initialIndex: 0),),
                                );
                              }
                            },
                    ),
                  ),
                ],
              ),
            )));
  }

  Future<void> _getImage() async {
    final ImagePicker _picker = ImagePicker();

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 130.0,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _image = File(image.path);
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.grey)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library, size: 48.0),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      setState(() {
                        _image = File(image.path);
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: Colors.grey)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_camera, size: 48.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
