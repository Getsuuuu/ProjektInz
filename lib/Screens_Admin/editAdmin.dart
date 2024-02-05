import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class EditAdminPage extends StatefulWidget {
  @override
  _EditAdminPageState createState() => _EditAdminPageState();
}

class _EditAdminPageState extends State<EditAdminPage> {
  TextEditingController searchController = TextEditingController();
  List<ParseUser> searchResults = [];
  ParseUser? selectedUser;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Edytuj pracownika'),
          backgroundColor: Colors.purple,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Wyszukaj użytkownika',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => searchUsers(searchController.text),
                ),
              ),
              onChanged: (query) => searchUsers(query),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final user = searchResults[index];
                  final bool isAdmin = user.get<bool>('admin') ?? false;

                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(user.username ?? ''),
                        Icon(
                          isAdmin ? Icons.check : Icons.close,
                          size: 20.0,
                          color: isAdmin ? Colors.green : Colors.red,
                        )
                      ],
                    ),
                    tileColor: user == selectedUser ? Colors.grey[300] : null,
                    onTap: () {
                      setState(() {
                        selectedUser = user;
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
          Align(
              alignment: Alignment.bottomCenter,
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: selectedUser != null &&
                          (selectedUser!.get<bool>('admin') ?? false) == false
                      ? () {
                          setAdminStatus(true);
                        }
                      : null,
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
                  child: Text('Dodaj admina'),
                )),
                SizedBox(height: 8.0),
                Expanded(
                    child: ElevatedButton(
                  onPressed: selectedUser != null &&
                          (selectedUser!.get<bool>('admin') ?? false)
                      ? () {
                          setAdminStatus(false);
                        }
                      : null,
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
                  child: Text('Usuń admina'),
                )),
              ],
            )),
          ]),
        ));
  }

  Future<void> loadUsers() async {
    try {
      final QueryBuilder<ParseUser> queryBuilder =
          QueryBuilder<ParseUser>(ParseUser.forQuery())
            ..orderByAscending('username');

      final response = await queryBuilder.query();

      if (response.success && response.results != null) {
        setState(() {
          searchResults = response.results!.cast<ParseUser>();
        });
      }
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  void searchUsers(String query) async {
    try {
      final QueryBuilder<ParseUser> queryBuilder =
          QueryBuilder<ParseUser>(ParseUser.forQuery())
            ..whereStartsWith('username', query)
            ..orderByAscending('username');

      final List<ParseUser> results = await queryBuilder.find();

      setState(() {
        searchResults = results;
      });
    } catch (e) {
      print('Error searching users: $e');
    }
  }

  void setAdminStatus(bool isAdmin) async {
    try {
      final currentUser = await ParseUser.currentUser();

      if (currentUser != null) {
        final ParseCloudFunction cloudFunction =
            ParseCloudFunction('makeUserAdmin');
        final Map<String, dynamic> params = <String, dynamic>{
          'userId': selectedUser!.objectId,
          'makeAdmin': isAdmin
        };

        final ParseResponse response =
            await cloudFunction.execute(parameters: params);

        if (response.success) {
          print('Admin status updated successfully');
        } else {
          print('Failed to change admin status: ${response.error?.message}');
        }
      } else {
        print('Error: User not authenticated');
      }
    } catch (e) {
      print('Error setting admin status: $e');
    }
  }
}
