import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../Screens_Admin/menu.dart';
import '../Screens_User/filter_screen.dart';
import '../Screens_User/menu.dart';
import 'game_details.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Map<String, List<String>> selectedFilters = {
    'Wiek': [],
    'LiczbaGraczy': [],
    'Kategoria': [],
  };
  IconData sortIcon = Icons.arrow_upward;
  IconData filter = Icons.filter_alt;
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

  Future<void> fetchGameList({
    String searchQuery = "",
    Map<String, List<String>>? selectedFilters,
  }) async {
    if (_isLoading || _isLastPage) return;

    setState(() {
      _isLoading = true;
    });

    final queryBuilder = QueryBuilder<ParseObject>(ParseObject('Gry'))
      ..setLimit(_pageSize)
      ..setAmountToSkip(pageKey * _pageSize);

    if (selectedSortIndex == 1) {
      queryBuilder.orderByDescending('Nazwa');
    } else if (selectedSortIndex == 0) {
      queryBuilder.orderByAscending('Nazwa');
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryBuilder.whereContains('Nazwa', searchQuery);
    }

    if (selectedFilters != null) {
      selectedFilters.forEach((filterKey, filterValues) {
        if (filterValues.isNotEmpty) {
          queryBuilder.whereContainedIn(filterKey, filterValues);
        }
      });
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

    if (_scrollController.hasClients &&
        !_scrollController.position.outOfRange &&
        _scrollController.position.maxScrollExtent -
            _scrollController.position.pixels <=
            _scrollThreshold) {
      loadMoreData(selectedFilters: selectedFilters);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> loadMoreData({Map<String, List<String>>? selectedFilters}) async {
    if (!isLoadingMore && !_isLastPage) {
      setState(() {
        isLoadingMore = true;
      });
      await fetchGameList(
        searchQuery: searchQuery,
        selectedFilters: selectedFilters,
      );
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      searchResults.clear();
      gameList.clear();
      pageKey = 0;
      _isLastPage = false;
    });

    await fetchGameList(
      searchQuery: _searchController.text,
      selectedFilters: selectedFilters,
    );
  }



  void applySorting(int selectedSortIndex) {
    setState(() {
      if (selectedSortIndex == 0) {
        gameList.sort((a, b) => (a.get<String>('Nazwa') ?? '')
            .compareTo(b.get<String>('Nazwa') ?? ''));
      } else if (selectedSortIndex == 1) {
        gameList.sort((a, b) => (b.get<String>('Nazwa') ?? '')
            .compareTo(a.get<String>('Nazwa') ?? ''));
      }
    });
  }

  void toggleSortOrder() {
    setState(() {
      selectedSortIndex = selectedSortIndex == 0 ? 1 : 0;
      applySorting(selectedSortIndex);
      sortIcon =
          selectedSortIndex == 0 ? Icons.arrow_upward : Icons.arrow_downward;
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

    await fetchGameList(
        searchQuery: searchQuery, selectedFilters: selectedFilters);
  }

  void resetSearch() {
    setState(() {
      gameList.clear();
      searchResults.clear();
      pageKey = 0;
      _isLastPage = false;
      _isLoading = false;
    });
  }

  navigateToFilterScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(selectedFilters: selectedFilters),
      ),
    );

    if (result is Map) {
      setState(() {
        selectedFilters = result['selectedFilters'] ?? {};
      });

      resetSearch();

      await fetchGameList(
        searchQuery: searchQuery,
        selectedFilters: selectedFilters,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ParseObject> currentList = isSearching ? searchResults : gameList;
    int itemCount = isSearching ? searchResults.length : gameList.length;
    return WillPopScope(
        onWillPop: () async {
          final ParseUser currentUser = await ParseUser.currentUser() as ParseUser;
          final bool isAdmin = currentUser.get<bool>('admin') ?? false;

          if (isAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MenuPageAdmin()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MenuPageUser()),
            );
          }

          await Future.delayed(Duration(milliseconds: 100));

          return false;
        },
        child: Stack(children: [
          Scaffold(
            appBar: AppBar(
              title: Text("Wyszukaj"),
              automaticallyImplyLeading: false,
              backgroundColor: Colors.red,
            ),
            body: RefreshIndicator(
              onRefresh: _handleRefresh,
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
                        IconButton(
                          icon: Icon(sortIcon, color: Colors.grey),
                          onPressed: toggleSortOrder,
                        ),
                        SizedBox(width: 8.0),
                        IconButton(
                          icon: Icon(filter, color: Colors.grey,),
                          onPressed: navigateToFilterScreen,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: currentList.isEmpty && !_isLoading
                        ? Center(
                            child: Text('Nic tu nie ma'),
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
                                        builder: (context) => GameDetailsScreen(
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
          ),
          if (_isLoading && !isLoadingMore)
            Container(
              color: Colors.black26,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ]));
  }
}
