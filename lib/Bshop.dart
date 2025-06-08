// Add this ShopPage class to your project

import 'package:flutter/material.dart';
import 'package:primefit/addtocart.dart';

class ShopPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ShopPage({super.key, required this.product});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> with TickerProviderStateMixin {
  int selectedQuantity = 1;
  bool isAddingToCart = false;
  late AnimationController _animationController;
  late AnimationController _imageAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _imageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _imageAnimationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _imageAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _imageAnimationController.dispose();
    super.dispose();
  }

  // Helper method to safely convert values to int
  int _getIntValue(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    if (value is double) return value.toInt();
    return defaultValue;
  }

  // Helper method to safely convert values to double
  double _getDoubleValue(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Remove any non-numeric characters except decimal point
      String cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanValue) ?? defaultValue;
    }
    return defaultValue;
  }

  String _getCategoryForProduct(Map<String, dynamic> product) {
    int weight = _getIntValue(product['weight']);
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProductImage(),
                              const SizedBox(height: 24),
                              _buildProductInfo(),
                              const SizedBox(height: 24),
                              _buildProductDetails(),
                              const SizedBox(height: 24),
                              _buildQuantitySelector(),
                              const SizedBox(height: 32),
                              _buildPurchaseSection(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
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
              'Product Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () => _showShareDialog(),
            icon: const Icon(Icons.share, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: widget.product['image_url'] != null
              ? Image.network(
                  widget.product['image_url'],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey[800]!, Colors.grey[900]!],
                        ),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10b981)),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey[800]!, Colors.grey[900]!],
                        ),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 64,
                              color: Color(0xFF10b981),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Image not available',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[800]!, Colors.grey[900]!],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.fitness_center,
                      size: 64,
                      color: Color(0xFF10b981),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.product['name']?.toString() ?? 'Unknown Product',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10b981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF10b981)),
                ),
                child: Text(
                  _getCategoryForProduct(widget.product),
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
          Text(
            'Product ID: ${widget.product['id']?.toString() ?? 'N/A'}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.product['description']?.toString() ?? 'No description available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    int availableStock = _getIntValue(widget.product['quantity']);
    double price = _getDoubleValue(widget.product['price']);
    int weight = _getIntValue(widget.product['weight']);

    return Container(
      padding: const EdgeInsets.all(20),
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
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.attach_money,
                  'Price',
                  '\$${price.toStringAsFixed(2)}',
                  const Color(0xFF10b981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  Icons.fitness_center,
                  'Weight',
                  '${weight}kg',
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            Icons.inventory,
            'Available Stock',
            '$availableStock units',
            availableStock > 5 ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    int maxQuantity = _getIntValue(widget.product['quantity']);
    double price = _getDoubleValue(widget.product['price']);

    return Container(
      padding: const EdgeInsets.all(20),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Quantity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: selectedQuantity > 1
                    ? () => setState(() => selectedQuantity--)
                    : null,
                icon: const Icon(Icons.remove_circle),
                color: const Color(0xFF10b981),
                iconSize: 32,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10b981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF10b981)),
                ),
                child: Text(
                  '$selectedQuantity',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10b981),
                  ),
                ),
              ),
              IconButton(
                onPressed: selectedQuantity < maxQuantity
                    ? () => setState(() => selectedQuantity++)
                    : null,
                icon: const Icon(Icons.add_circle),
                color: const Color(0xFF10b981),
                iconSize: 32,
              ),
              const Spacer(),
              Text(
                'Total: \$${(price * selectedQuantity).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseSection() {
    final isOutOfStock = _getIntValue(widget.product['quantity']) == 0;
    
   return Column(
    children: [

      
      // Add to Cart Button
Container(
  width: double.infinity,
  height: 60,
  child: ElevatedButton.icon(
    onPressed: isOutOfStock ? null : () => _addToCart(),
    icon: isAddingToCart
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          )
        : const Icon(Icons.shopping_cart, size: 24),
    label: Text(
      isOutOfStock
          ? 'Out of Stock'
          : isAddingToCart
              ? 'Adding to Cart...'
              : 'Add to Cart',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: isOutOfStock ? Colors.grey[600] : const Color(0xFF10b981),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
    ),
  ),
),

// Buy Now Button


Container(
        width: double.infinity,
        height: 60,
        child: ElevatedButton.icon(
          onPressed: isOutOfStock ? null : () => _buyNow(),
          label: const Text(
            'Buy Now',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isOutOfStock
                ? const Color.fromARGB(255, 2, 2, 2)
                : const Color.fromARGB(255, 0, 0, 0),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
          ),
        ),
      ),
    ],
  );
}



void _addToCart() async {
  setState(() {
    isAddingToCart = true;
  });

  // Get the product details
  final productId = widget.product['id'] ?? widget.product['product_id'];
  final productName = widget.product['name'] ?? '';
  final productPrice = widget.product['price'] ?? 0.0;
  final productImage = widget.product['image'] ?? '';
  
  // Simulate loading
  await Future.delayed(const Duration(milliseconds: 500));
  
  setState(() {
    isAddingToCart = false;
  });

  // Navigate to Add to Cart page with specific product details
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddToCartPage(
        productId: productId,
        productName: productName,
        productPrice: productPrice,
        productImage: productImage,
        selectedQuantity: selectedQuantity,
      ),
    ),
  );
}

void _buyNow() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(Icons.shopping_cart, color: Color.fromARGB(255, 255, 255, 255)),
            const SizedBox(width: 8),
            const Text('Buy Now', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product: ${widget.product['name']}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Quantity: $selectedQuantity',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: \$${(double.tryParse(widget.product['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0 * selectedQuantity).toStringAsFixed(2)}',
              style: const TextStyle(color: Color(0xFF10b981), fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Proceed to checkout?',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _proceedToCheckout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 16, 145, 63),
              foregroundColor: Colors.white,
            ),
            child: const Text('Proceed'),
          ),
        ],
      );
    },
  );
}

void _proceedToCheckout() {
  // Get the product ID
  final productId = widget.product['id'] ?? widget.product['product_id'];
  
  // Navigate to checkout page with product data
  Navigator.pushNamed(
    context,
    '/checkout',
    arguments: {
      'productId': productId,
      'productName': widget.product['name'],
      'price': widget.product['price'],
      'quantity': selectedQuantity,
      'totalAmount': (double.tryParse(widget.product['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0 * selectedQuantity),
    },
  );
  
  // Alternative: If you're using a different navigation method
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //     builder: (context) => CheckoutPage(
  //       productId: productId,
  //       productName: widget.product['name'],
  //       price: widget.product['price'],
  //       quantity: selectedQuantity,
  //     ),
  //   ),
  // );
}

void _showShareDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text('Share Product', style: TextStyle(color: Colors.white)),
        content: Text(
          'Share ${widget.product['name']} with friends!',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF10b981))),
          ),
        ],
      );
    },
  );
}
}