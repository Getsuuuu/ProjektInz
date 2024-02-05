import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  final Map<String, List<String>> selectedFilters;

  FilterScreen({Key? key, required this.selectedFilters}) : super(key: key);

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  Map<String, List<String>> filters = {
    'Wiek': [
      "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
      "11", "12", "13", "14", "15", "16", "17", "18",
      "1+", "2+", "3+", "4+", "5+", "6+", "7+", "8+",
      "9+", "10+", "11+", "12+", "13+", "14+", "15+",
      "16+", "17+", "18+"
    ],
    'LiczbaGraczy': [
      "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
      "11", "12", "13", "14", "15", "16", "17", "18",
      "1+", "2+", "3+", "4+", "5+", "6+", "7+", "8+",
      "9+", "10+", "11+", "12+", "13+", "14+", "15+",
      "16+", "17+", "18+"
    ],
    'Kategoria': [
      "Ekonomiczne", "Strategiczne", "Rodzinne", "Dla dzieci", "Przygodowe", "Karciane", "Kooperacyjne", "Wojenne",
      "Dedukcyjne", "Imprezowe", "Logiczne", "Słowne", "Sci-fi", "Fantasy", "Edukacyjne", "Abstrakcyjne"],
  };

  late Map<String, List<String>> selectedFilters;

  @override
  void initState() {
    super.initState();
    selectedFilters = Map.from(widget.selectedFilters) ?? {};
    for (var category in filters.keys) {
      if (!selectedFilters.containsKey(category)) {
        selectedFilters[category] = [];
      }
    }
  }

  void applyFilters() {
    Navigator.pop(context, {
      'searchQuery': '',
      'selectedFilters': selectedFilters,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter Options'),
        backgroundColor: Colors.red,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          Expanded(
            child: ListView(
              children: [
                for (var category in filters.keys)
                  _buildFilterCategory(category),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: applyFilters,
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
              minimumSize: Size(double.infinity, 0),
            ),
            child: Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCategory(String category) {
    if (filters.containsKey(category)) {
      return ExpansionTile(
        title: Text(category),
        children: [
          for (var filter in filters[category]!)
            CheckboxListTile(
              title: Text(filter),
              value: selectedFilters[category]?.contains(filter) ?? false,
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    selectedFilters[category]?.add(filter);
                  } else {
                    selectedFilters[category]?.remove(filter);
                  }
                });
              },
            ),
        ],
      );
    } else {
      // Handle the case where category is not a valid key in the filters map.
      return Container();
    }
  }
}
