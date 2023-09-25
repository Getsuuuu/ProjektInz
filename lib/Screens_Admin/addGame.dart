import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AddGameForm extends StatefulWidget {
  const AddGameForm({Key? key}) : super(key: key);

  @override
  AddGameFormState createState() {
    return AddGameFormState();
  }
}

class AddGameFormState extends State<AddGameForm> {
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
  int? _from;
  int? _to;
  File? _compressedFile;
  final String _placeholderImage = 'assets/placeholder.jpg';
  String _gameImage = 'assets/placeholder.jpg';
  final _formKey = GlobalKey<FormState>();
  final controllerNazwa = TextEditingController();
  String? controllerWiek;
  final controllerLiczbaGraczyOd = TextEditingController();
  final controllerLiczbaGraczyDo = TextEditingController();
  final controllerKategoria = TextEditingController();
  final controllerOpis = TextEditingController();
  final controllerEgzemplarze = TextEditingController();
  File? _image;
  bool isLoading = false;

  Future<void> compress() async {
    var result = await FlutterImageCompress.compressAndGetFile(
      _image!.absolute.path,
      _image!.path + 'compressed.jpg',
      quality: 50,
    );
    setState(() {
      _compressedFile = result as File?;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Dodawanie gry'),
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
                      child: _image != null
                          ? Image.file(
                        _image!,
                        fit: BoxFit.cover,
                        width: 200.0,
                        height: 200.0,
                      )
                          : Image.asset(
                        _placeholderImage,
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
                            : Text('Zapisz'),
                        style: ElevatedButton.styleFrom(primary: Colors.blue),
                        onPressed: isLoading || _image == null
                            ? null
                            : () async {
                                setState(() {
                                  isLoading = true;
                                });
                                await compress();
                                ParseFileBase? parseFile;

                                if (kIsWeb) {
                                  parseFile = ParseWebFile(
                                      await _compressedFile!.readAsBytes(),
                                      name:
                                          'image.jpg'); //Name for file is required
                                } else {
                                  parseFile =
                                      ParseFile(File(_compressedFile!.path));
                                }
                                await parseFile.save();

                                final nazwa = controllerNazwa.text.trim();
                                final wiek = controllerWiek;
                                final liczbaGraczy = '$_from-$_to';
                                final kategoria =
                                    controllerKategoria.text.trim();
                                final opis = controllerOpis.text.trim();
                                String egzemplarzeText =
                                    controllerEgzemplarze.text;
                                int? egzemplarze =
                                    int.tryParse(egzemplarzeText);

                                var gry = ParseObject('Gry');
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
                                  controllerLiczbaGraczyOd.clear();
                                  controllerLiczbaGraczyDo.clear();
                                  _image = null;
                                  controllerNazwa.clear();
                                  controllerEgzemplarze.clear();
                                  controllerWiek = null;
                                  controllerKategoria.clear();
                                  controllerOpis.clear();
                                });

                                ScaffoldMessenger.of(context)
                                  ..removeCurrentSnackBar()
                                  ..showSnackBar(SnackBar(
                                    content: Text(
                                      'Dane zostały zapisane',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    duration: Duration(seconds: 3),
                                    backgroundColor: Colors.blue,
                                  ));
                              },
                      )),
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
