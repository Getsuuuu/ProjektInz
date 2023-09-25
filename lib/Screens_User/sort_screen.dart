import 'package:flutter/material.dart';

class SortScreen extends StatefulWidget {
  @override
  _SortScreenState createState() => _SortScreenState();
}

class _SortScreenState extends State<SortScreen> {
  int selectedSortIndex = -1;

  List<String> sortOptions = [
    'Nazwa (Rosnąca)',
    'Nazwa (Malejąca)',
    'Data (Najstarsze)',
    'Data (Najnowsze)',
  ];

  void applySorting() {
    if (selectedSortIndex != -1) {
      Navigator.pop(context, selectedSortIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sort Options'),
      ),
      body: ListView(
        children: [
          SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Sort By',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 16.0),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: sortOptions.length,
            itemBuilder: (BuildContext context, int index) {
              return RadioListTile(
                title: Text(sortOptions[index]),
                value: index,
                groupValue: selectedSortIndex,
                onChanged: (value) {
                  setState(() {
                    selectedSortIndex = value as int;
                  });
                },
              );
            },
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: applySorting,
              child: Text('Apply Sorting'),
            ),
          ),
        ],
      ),
    );
  }
}
