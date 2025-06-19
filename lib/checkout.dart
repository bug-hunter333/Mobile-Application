import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with TickerProviderStateMixin {
  Map<String, dynamic>? checkoutData;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  
  // Payment and shipping options
  String _selectedPaymentMethod = 'card';
  String _selectedShippingMethod = 'standard';
  
  // Location variables
  bool _isLoadingLocation = false;
  
  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _initAnimations();
  }
  
  void _initAnimations() {
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    // Start animations
    _slideController.forward();
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkoutData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  double get _subtotal => double.tryParse(checkoutData?['price']?.toString() ?? '') ?? 0.0;
  double get _shippingCost => _selectedShippingMethod == 'express' ? 15.0 : 5.0;
  double get _tax => _subtotal * 0.08;
  double get _total => _subtotal + _shippingCost + _tax;

  // Location permission and services methods
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationDialog(
        'Location Service Disabled',
        'Location services are disabled. Please enable them in your device settings.',
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationDialog(
          'Location Permission Denied',
          'Location permissions are denied. Please enable them to use this feature.',
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationDialog(
        'Location Permission Permanently Denied',
        'Location permissions are permanently denied. Please enable them in your device settings.',
      );
      return false;
    }

    return true;
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        setState(() {
          _addressController.text = 
              '${place.street ?? ''} ${place.subThoroughfare ?? ''} ${place.thoroughfare ?? ''}'.trim();
          _cityController.text = place.locality ?? '';
          _zipController.text = place.postalCode ?? '';
        });
        
        _showLocationSuccessDialog();
      }
    } catch (e) {
      _showLocationDialog(
        'Location Error',
        'Failed to get your location. Please try again or enter your address manually.',
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _showLocationDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1a1a1a),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.location_off, color: Colors.red[400], size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[600]!, Colors.green[400]!],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLocationSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1a1a1a),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[400], size: 28),
              SizedBox(width: 12),
              Text(
                'Location Found!',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Text(
            'Your current location has been automatically filled in the address fields.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[600]!, Colors.green[400]!],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productName = checkoutData?['productName'] ?? 'Product';
    final productPrice = checkoutData?['price'] ?? 0.0;
    final productImage = checkoutData?['image'];
    final quantity = checkoutData?['quantity'] ?? 1;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF000000),
              Color(0xFF1a1a1a),
              Color(0xFF2d5a2d),
              Color(0xFF1b4d1b),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildOrderSummaryCard(
                                productName,
                                double.parse(productPrice.toString()),
                                productImage,
                                quantity
                              ),
                              SizedBox(height: 20),
                              _buildShippingInformationCard(),
                              SizedBox(height: 20),
                              _buildShippingMethodCard(),
                              SizedBox(height: 20),
                              _buildPaymentMethodCard(),
                              SizedBox(height: 20),
                              _buildPriceBreakdownCard(),
                              SizedBox(height: 30),
                              _buildPlaceOrderButton(),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 16),
          Text(
            'Checkout',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_cart,
              color: Colors.green[300],
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard({required Widget child}) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
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
            color: Colors.green.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildOrderSummaryCard(String productName, double price, String? image, int quantity) {
    return _buildAnimatedCard(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.green[300], size: 24),
                SizedBox(width: 8),
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Colors.green[700]!, Colors.green[500]!],
                      ),
                      image: image != null
                          ? DecorationImage(
                              image: NetworkImage(image),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: image == null
                        ? Icon(Icons.image, color: Colors.white, size: 30)
                        : null,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Qty: $quantity',
                            style: TextStyle(
                              color: Colors.green[300],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green[600]!, Colors.green[400]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInformationCard() {
    return _buildAnimatedCard(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.green[300], size: 24),
                SizedBox(width: 8),
                Text(
                  'Shipping Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                // Location button
                GestureDetector(
                  onTap: _getCurrentLocation,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green[600]!, Colors.green[400]!],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isLoadingLocation
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(Icons.my_location, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          _isLoadingLocation ? 'Getting...' : 'Use Location',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildStyledTextField(_nameController, 'Full Name', Icons.person),
            SizedBox(height: 16),
            _buildStyledTextField(_emailController, 'Email Address', Icons.email, keyboardType: TextInputType.emailAddress),
            SizedBox(height: 16),
            _buildStyledTextField(_phoneController, 'Phone Number', Icons.phone, keyboardType: TextInputType.phone),
            SizedBox(height: 16),
            _buildStyledTextField(_addressController, 'Street Address', Icons.home, showLocationIcon: true),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStyledTextField(_cityController, 'City', Icons.location_city)),
                SizedBox(width: 16),
                Expanded(child: _buildStyledTextField(_zipController, 'ZIP Code', Icons.pin_drop, keyboardType: TextInputType.number)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, 
    {TextInputType? keyboardType, bool showLocationIcon = false}
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.green[300]),
        prefixIcon: Icon(icon, color: Colors.green[300]),
        suffixIcon: showLocationIcon ? GestureDetector(
          onTap: _getCurrentLocation,
          child: Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isLoadingLocation
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400]!),
                    ),
                  )
                : Icon(
                    Icons.my_location,
                    color: Colors.green[400],
                    size: 20,
                  ),
          ),
        ) : null,
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[400]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[400]!),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        if (label == 'Email Address' && !value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildShippingMethodCard() {
    return _buildAnimatedCard(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.delivery_dining, color: Colors.green[300], size: 24),
                SizedBox(width: 8),
                Text(
                  'Shipping Method',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildShippingOption('standard', 'Standard Shipping', '5-7 business days', 5.00, Icons.local_shipping),
            SizedBox(height: 12),
            _buildShippingOption('express', 'Express Shipping', '2-3 business days', 15.00, Icons.flash_on),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingOption(String value, String title, String subtitle, double price, IconData icon) {
    bool isSelected = _selectedShippingMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedShippingMethod = value;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.2) : Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green[400]! : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.green[300] : Colors.white70),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green[600] : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '\$${price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return _buildAnimatedCard(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Colors.green[300], size: 24),
                SizedBox(width: 8),
                Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildPaymentOption('card', 'Credit/Debit Card', Icons.credit_card),
            SizedBox(height: 12),
            _buildPaymentOption('paypal', 'PayPal', Icons.account_balance_wallet),
            SizedBox(height: 12),
            _buildPaymentOption('cod', 'Cash on Delivery', Icons.money),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon) {
    bool isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.2) : Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green[400]! : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.green[300] : Colors.white70),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.green[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdownCard() {
    return _buildAnimatedCard(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, color: Colors.green[300], size: 24),
                SizedBox(width: 8),
                Text(
                  'Price Breakdown',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildPriceRow('Subtotal', _subtotal),
                  SizedBox(height: 8),
                  _buildPriceRow('Shipping', _shippingCost),
                  SizedBox(height: 8),
                  _buildPriceRow('Tax (8%)', _tax),
                  SizedBox(height: 16),
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green[600]!, Colors.green[400]!],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildPriceRow('Total', _total, isTotal: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.white : Colors.white70,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: isTotal ? 12 : 8, vertical: isTotal ? 8 : 4),
          decoration: isTotal ? BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[600]!, Colors.green[400]!],
            ),
            borderRadius: BorderRadius.circular(8),
          ) : null,
          child: Text(
            '\${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceOrderButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[700]!, Colors.green[500]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Place Order - \${_total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _placeOrder() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFF1a1a1a),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400]!),
                ),
                SizedBox(height: 20),
                Text(
                  'Processing your order...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          );
        },
      );

     Future.delayed(Duration(seconds: 3), () {
  Navigator.of(context).pop();
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[400], size: 28),
            SizedBox(width: 12),
            Text(
              'Order Placed!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'Your order has been successfully placed. You will receive a confirmation email shortly.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Only close the dialog
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[600]!, Colors.green[400]!],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    },
  );
});
    }
  }
    }
