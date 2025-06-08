import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:primefit/Dshop.dart';

class Dumbellspage extends StatefulWidget {
  const Dumbellspage({super.key});

  @override
  State<Dumbellspage> createState() => _DumbellspageState();
}

class _DumbellspageState extends State<Dumbellspage> with TickerProviderStateMixin {
  List<dynamic> dumbellProducts = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = true;
  String errorMessage = '';
  String searchQuery = '';
  String selectedCategory = 'All';
  String sortBy = 'name';
  bool isAscending = true;
  int cartItemCount = 0;
  
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fabAnimation;

  final TextEditingController _searchController = TextEditingController();
  final List<String> categories = ['All', 'Light Weight', 'Medium Weight', 'Heavy Weight'];
  final List<String> sortOptions = ['name', 'price', 'weight'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    loadData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void loadData() async {
    try {
      List<dynamic> data = await loadDumbellData();
      setState(() {
        dumbellProducts = data;
        filteredProducts = data;
        isLoading = false;
        errorMessage = '';
      });
      _animationController.forward();
      _fabAnimationController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data: $e';
      });
    }
  }

  Future<List<dynamic>> loadDumbellData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/dumbell.json');
      List<dynamic> jsonData = json.decode(jsonString);
      return jsonData;
    } catch (e) {
      print('Error loading dumbell data: $e');
      throw e;
    }
  }

  void _filterAndSortProducts() {
    List<dynamic> filtered = dumbellProducts.where((product) {
      bool matchesSearch = product['name']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false;
      bool matchesCategory = selectedCategory == 'All' || _getCategoryForProduct(product) == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    filtered.sort((a, b) {
      dynamic aValue = a[sortBy];
      dynamic bValue = b[sortBy];
      
      if (sortBy == 'price') {
        aValue = double.tryParse(aValue?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0;
        bValue = double.tryParse(bValue?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0;
      } else if (sortBy == 'weight') {
        aValue = aValue ?? 0;
        bValue = bValue ?? 0;
      } else {
        aValue = aValue?.toString() ?? '';
        bValue = bValue?.toString() ?? '';
      }

      int result = aValue.compareTo(bValue);
      return isAscending ? result : -result;
    });

    setState(() {
      filteredProducts = filtered;
    });
  }

  String _getCategoryForProduct(Map<String, dynamic> product) {
    int weight = product['weight'] ?? 0;
    if (weight <= 10) return 'Light Weight';
    if (weight <= 25) return 'Medium Weight';
    return 'Heavy Weight';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF000000),
              Color(0xFF1a1a1a),
              Color(0xFF0d4f3c),
              Color(0xFF134e3a),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildSearchAndFilter(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: () => _showCartDialog(),
          backgroundColor: const Color(0xFF10b981),
          child: Stack(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white),
              if (cartItemCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Dumbbell Collection',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () => _showSortDialog(),
            icon: const Icon(Icons.sort, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFF10b981).withOpacity(0.3)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                _filterAndSortProducts();
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search dumbbells...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: const Color(0xFF10b981)),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                          _filterAndSortProducts();
                        },
                        icon: const Icon(Icons.clear, color: Colors.white),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
    SizedBox(
  height: 40,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: categories.length,
    itemBuilder: (context, index) {
      final category = categories[index];
      final isSelected = selectedCategory == category;
      return Container(
        margin: const EdgeInsets.only(right: 12),
        child: FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              selectedCategory = category;
            });
            _filterAndSortProducts();
          },
         backgroundColor: Colors.white, // white background
          selectedColor: const Color(0xFF10b981), // green accent when selected
          labelStyle: TextStyle(
            color: Colors.black, // black font
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF10b981) // green when selected
                : Colors.black.withOpacity(0.3), // faded black when not selected
          ),

        ),
      );
    },
  ),
),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10b981)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading dumbbell products...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Error Loading Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = '';
                  });
                  loadData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10b981),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredProducts.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fitness_center,
                size: 64,
                color: Colors.white.withOpacity(0.6),
              ),
              const SizedBox(height: 16),
              Text(
                searchQuery.isNotEmpty ? 'No Results Found' : 'No Products Available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                searchQuery.isNotEmpty 
                    ? 'Try adjusting your search or filter criteria'
                    : 'Please check if dumbell.json exists in assets folder',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6)),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildProductsList(),
    );
  }

  Widget _buildProductsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value * (index + 1) * 0.1),
              child: _buildProductCard(filteredProducts[index], index),
            );
          },
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF10b981).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[800]!,
                    Colors.grey[900]!,
                  ],
                ),
              ),
              child: product['image_url'] != null
                  ? Image.network(
                      product['image_url'],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10b981)),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 48,
                                color: Color(0xFF10b981),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Image not available',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        Icons.fitness_center,
                        size: 48,
                        color: Color(0xFF10b981),
                      ),
                    ),
            ),
          ),

          // Product Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name and Category
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product['name'] ?? 'Unknown Product',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10b981).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF10b981)),
                      ),
                      child: Text(
                        _getCategoryForProduct(product),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF10b981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  product['description'] ?? 'No description available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Price and Weight Row
                Row(
                  children: [
                    // Price
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF10b981).withOpacity(0.2),
                              const Color(0xFF10b981).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFF10b981)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.attach_money, color: Color(0xFF10b981), size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${product['price'] ?? '0.00'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10b981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Weight
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.fitness_center, color: Colors.white, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${product['weight'] ?? 0}kg',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

// Stock and Add to Cart Row
Row(
  children: [
    // Stock Status
    Expanded(
      child: Row(
        children: [
          Icon(
            Icons.inventory,
            size: 18,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(width: 6),
          Text(
            'Stock: ${product['quantity'] ?? 0}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    ),

    // Shop Now Button
    ElevatedButton.icon(
      onPressed: (product['quantity'] ?? 0) > 0
          ? () => _navigateToShop(product)
          : null,
      icon: const Icon(Icons.shopping_bag, size: 18),
      label: const Text('Shop Now'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10b981),
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[600],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
  ],
),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Navigate to Shop Page method
  void _navigateToShop(Map<String, dynamic> product) {
    // Navigate to shop page - replace 'ShopPage' with your actual shop page widget
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopPage(product: product), // Pass product data if needed
      ),
    );
  }


  

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1a1a),
          title: const Text('Sort Products', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...sortOptions.map((option) => RadioListTile<String>(
                title: Text(
                  option.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
                value: option,
                groupValue: sortBy,
                activeColor: const Color(0xFF10b981),
                onChanged: (value) {
                  setState(() {
                    sortBy = value!;
                  });
                  _filterAndSortProducts();
                  Navigator.pop(context);
                },
              )),
              const Divider(color: Colors.white30),
              SwitchListTile(
                title: const Text('Ascending Order', style: TextStyle(color: Colors.white)),
                value: isAscending,
                activeColor: const Color(0xFF10b981),
                onChanged: (value) {
                  setState(() {
                    isAscending = value;
                  });
                  _filterAndSortProducts();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1a1a),
          title: Row(
            children: [
              const Icon(Icons.shopping_cart, color: Color(0xFF10b981)),
              const SizedBox(width: 8),
              const Text('Shopping Cart', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            'You have $cartItemCount item(s) in your cart',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Color(0xFF10b981))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to cart page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10b981),
              ),
              child: const Text('View Cart'),
            ),
          ],
        );
      },
    );
  }
}