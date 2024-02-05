import 'dart:io';
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

  XFile? _compressedFile;
  final String _placeholderImage = 'assets/placeholder.jpg';
  final _formKey = GlobalKey<FormState>();
  final controllerNazwa = TextEditingController();
  String? controllerWiek;
  String? controllerLiczbaGraczy;
  String? controllerKategoria;
  final controllerOpis = TextEditingController();
  final controllerEgzemplarze = TextEditingController();
  File? _image;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> compress() async {
    var result = await FlutterImageCompress.compressAndGetFile(
      _image!.absolute.path,
      _image!.path + 'compressed.jpg',
      quality: 50,
    );
    setState(() {
      _compressedFile = result as XFile?;
    });
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
          title: Text('Dodawanie gry'),
          backgroundColor: Colors.purple,
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
                        width: 200.0,
                        height: 200.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: _image != null
                              ? Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  _placeholderImage,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        // Add some top padding for space
                        child: Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              child: isLoading
                                  ? CircularProgressIndicator()
                                  : Text('Zapisz'),
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
                              onPressed: isLoading || _image == null
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        await compress();
                                        ParseFileBase? parseFile;

                                        if (kIsWeb) {
                                          parseFile = ParseWebFile(
                                              await _compressedFile!
                                                  .readAsBytes(),
                                              name:
                                                  'image.jpg'); //Name for file is required
                                        } else {
                                          parseFile = ParseFile(
                                              File(_compressedFile!.path));
                                        }
                                        await parseFile.save();

                                        final nazwa =
                                            controllerNazwa.text.trim();
                                        final wiek = controllerWiek;
                                        final liczbaGraczy =
                                            controllerLiczbaGraczy;
                                        final kategoria = controllerKategoria;
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
                                          controllerLiczbaGraczy = null;
                                          _image = null;
                                          controllerNazwa.clear();
                                          controllerEgzemplarze.clear();
                                          controllerWiek = null;
                                          controllerKategoria = null;
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
                                      }
                                    },
                            )),
                      ))
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
}
