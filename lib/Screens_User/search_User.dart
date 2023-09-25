import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'filter_screen.dart';
import 'game_details.dart';
import 'menu.dart';
import 'sort_screen.dart';

class SearchPageUser extends StatefulWidget {
  @override
  State<SearchPageUser> createState() => _SearchPageUserState();
}

class _SearchPageUserState extends State<SearchPageUser> {
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
  String selectedSortOption = '';
  int selectedSortIndex = 0;
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchGameList();
    _scrollController.addListener(_scrollListener);
    applySorting(selectedSortIndex);
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

    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryBuilder.whereContains('Nazwa', searchQuery);
    }

    final response = await queryBuilder.query();

    if (response.success && response.results != null) {
      setState(() {
        if (searchQuery != null && searchQuery.isNotEmpty) {
          isSearching = true;
          searchResults.addAll(response.results! as List<ParseObject>);
        } else {
          isSearching = false;
          gameList.addAll(response.results! as List<ParseObject>);
        }
        applySorting(selectedSortIndex);
        pageKey++;
        _isLoading = false;
        _isLastPage = response.results!.length < _pageSize;
      });
    }

    if (_scrollController.hasClients && !_scrollController.position.outOfRange && _scrollController.position.maxScrollExtent - _scrollController.position.pixels <= _scrollThreshold) {
      fetchGameList(searchQuery: searchQuery); // Pass the searchQuery parameter recursively
    }
  }

  Future<void> loadMoreData() async {
    if (!isLoading && !_isLastPage) {
      setState(() {
        isLoadingMore = true;
      });
      await fetchGameList(searchQuery: searchQuery); // Pass the searchQuery parameter to fetchGameList
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void applySorting(int selectedSortIndex) {
    setState(() {
      if (selectedSortIndex == 0) {
        gameList.sort((a, b) => (a.get<String>('Nazwa') ?? '')
            .compareTo(b.get<String>('Nazwa') ?? ''));
      } else if (selectedSortIndex == 1) {
        gameList.sort((a, b) => (b.get<String>('Nazwa') ?? '')
            .compareTo(a.get<String>('Nazwa') ?? ''));
      } else if (selectedSortIndex == 2) {
        gameList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
      } else if (selectedSortIndex == 3) {
        gameList.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      }
    });
  }

  void refreshListBySearchQuery() async {
    setState(() {
      searchResults.clear();
      gameList.clear();
      pageKey = 0;
      searchQuery = _searchController.text;
      isSearching = true;
    });
    await fetchGameList(searchQuery: searchQuery);
  }

  void navigateToSortScreen() async {
    final selectedOptionIndex = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SortScreen()),
    );
    if (selectedOptionIndex != null) {
      setState(() {
        selectedSortIndex =
            selectedOptionIndex; // Update the selected sort index
      });
      applySorting(
          selectedSortIndex); // Apply sorting after selecting a sort option
    }
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
    return WillPopScope(
        onWillPop: () async {
          if (Navigator.canPop(context)) {
            return true;
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MenuPageUser()),
            );
            return false;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("Wyszukiwarka"),
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
                                      builder: (context) => GameDetailsPageUser(
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
                                    title:
                                        Text(game.get<String>('Nazwa') ?? ''),
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
        ));
  }
}
