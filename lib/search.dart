import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:primefit/BarbellsPage.dart';
import 'package:primefit/DumbellsPage.dart';
import 'package:primefit/GlovesPage.dart';
import 'package:primefit/RacksPage.dart';
import 'package:primefit/YogaMatsPage.dart';

class ShopSearchPage extends StatefulWidget {
  @override
  _ShopSearchPageState createState() => _ShopSearchPageState();
}

class _ShopSearchPageState extends State<ShopSearchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredItems = [];
  
  // Trending items data
  final List<Map<String, dynamic>> trendingItems = [
    {
      'title': 'DUMBELLS ❚█══█❚',
      'page': Dumbellspage(),
      'keywords': ['dumbells', 'dumbbells', 'weights', 'free weights']
    },
    {
      'title': 'Barbells & Weight Plates 🏋️‍♂️',
      'page': Barbellspage(),
      'keywords': ['barbells', 'barbell', 'weight plates', 'plates', 'olympic']
    },
    {
      'title': 'Weightlifting Gloves 🧤',
      'page': Glovespage(),
      'keywords': ['gloves', 'weightlifting gloves', 'lifting gloves', 'grip']
    },
    {
      'title': 'Yoga Mats 🧘🏼‍♀️',
      'page': Yogamatspage(),
      'keywords': ['yoga mats', 'yoga', 'mats', 'exercise mats', 'fitness mats']
    },
    {
      'title': 'RIGS & Racks',
      'page': Rackspage(),
      'keywords': ['rigs', 'racks', 'power racks', 'squat racks', 'cage']
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    filteredItems = trendingItems; // Show all trending items by default
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      if (query.isEmpty) {
        filteredItems = trendingItems;
      } else {
        filteredItems = trendingItems.where((item) {
          String title = item['title'].toLowerCase();
          List<String> keywords = item['keywords'];
          
          // Check if query matches title or any keyword
          return title.contains(query) || 
                 keywords.any((keyword) => keyword.toLowerCase().contains(query));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B0F), // Dark green
              Color(0xFF000000), // Black
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'PRIME FIT',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 36, 255, 171),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),

              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'What are you looking for?',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Dynamic Section Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      _searchController.text.isEmpty ? 'TRENDING' : 'SEARCH RESULTS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      Text(
                        ' (${filteredItems.length})',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Items List
              Expanded(
                child: filteredItems.isEmpty
                    ? _buildNoResultsWidget()
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => item['page'],
                                ),
                              );
                            },
                            child: _buildTrendingCard(item['title']),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingCard(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withOpacity(0.6),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try searching for something else',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}