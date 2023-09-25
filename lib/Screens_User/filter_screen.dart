import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  bool filterOption1 = false;
  bool filterOption2 = false;
  bool filterOption3 = false;

  void applyFilters() {
    List<String> selectedFilters = [];

    if (filterOption1) {
      selectedFilters.add('Filter 1');
    }
    if (filterOption2) {
      selectedFilters.add('Filter 2');
    }
    if (filterOption3) {
      selectedFilters.add('Filter 3');
    }

    Navigator.pop(context, selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter Options'),
      ),
      body: ListView(
        children: [
          SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Filters',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 16.0),
          CheckboxListTile(
            title: Text('Filter Option 1'),
            value: filterOption1,
            onChanged: (value) {
              setState(() {
                filterOption1 = value ?? false;
              });
            },
          ),
          CheckboxListTile(
            title: Text('Filter Option 2'),
            value: filterOption2,
            onChanged: (value) {
              setState(() {
                filterOption2 = value ?? false;
              });
            },
          ),
          CheckboxListTile(
            title: Text('Filter Option 3'),
            value: filterOption3,
            onChanged: (value) {
              setState(() {
                filterOption3 = value ?? false;
              });
            },
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: applyFilters,
              child: Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
