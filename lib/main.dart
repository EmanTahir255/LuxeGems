import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ---------------- DATA MODELS ----------------
class User {
  String email;
  String password;
  String name;
  User({required this.email, required this.password, required this.name});
}

class Product {
  final String name;
  final String brand;
  final String description;
  final String image;
  final int price;
  final double rating;
  final String category;
  final List<String> materials;

  Product({
    required this.name,
    required this.brand,
    required this.description,
    required this.image,
    required this.price,
    required this.rating,
    required this.category,
    required this.materials,
  });
}

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class Order {
  final List<CartItem> items;
  final int total;
  final DateTime date;
  final String status;
  Order({required this.items, required this.total, required this.date, this.status = 'Delivered'});
}

// ---------------- GLOBAL STATE ----------------
class AppState {
  static User? currentUser;
  static final List<User> registeredUsers = [];
  static final List<CartItem> cartItems = [];
  static final List<Product> wishlistItems = [];
  static final List<Order> orderHistory = [];

  static void addToCart(Product product) {
    final existingIndex = cartItems.indexWhere((item) => item.product.name == product.name);
    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity++;
    } else {
      cartItems.add(CartItem(product: product));
    }
  }

  static void removeFromCart(int index) {
    cartItems.removeAt(index);
  }

  static void toggleWishlist(Product product) {
    final isExist = wishlistItems.any((p) => p.name == product.name);
    if (isExist) {
      wishlistItems.removeWhere((p) => p.name == product.name);
    } else {
      wishlistItems.add(product);
    }
  }

  static bool isInWishlist(Product product) {
    return wishlistItems.any((p) => p.name == product.name);
  }

  static void clearCart() {
    cartItems.clear();
  }

  static void clearWishlist() {
    wishlistItems.clear();
  }

  static int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  static int get totalPrice => cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
}

// ---------------- MAIN APP ----------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LuxeGems Jewelry',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37),
          primary: const Color(0xFFD4AF37),
          secondary: const Color(0xFF2C2C2C),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C2C2C),
          foregroundColor: Color(0xFFD4AF37),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ---------------- SIDEBAR / DRAWER ----------------
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF5F5F0),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF2C2C2C),
            ),
            accountName: Text(
              AppState.currentUser?.name ?? "Guest User",
              style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(
              AppState.currentUser?.email ?? "Welcome to LuxeGems",
              style: const TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
              },
              child: const CircleAvatar(
                backgroundColor: Color(0xFFD4AF37),
                child: Icon(Icons.person, color: Color(0xFF2C2C2C), size: 40),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined, color: Color(0xFF2C2C2C)),
            title: const Text('Home Dashboard', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Color(0xFF2C2C2C)),
            title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border, color: Color(0xFF2C2C2C)),
            title: const Text('My Wishlist', style: TextStyle(fontWeight: FontWeight.w600)),
            trailing: AppState.wishlistItems.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle),
                    child: Text(
                      AppState.wishlistItems.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF2C2C2C)),
            title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.w600)),
            trailing: AppState.totalItems > 0
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle),
                    child: Text(
                      AppState.totalItems.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () {
              AppState.currentUser = null;
              AppState.clearCart();
              AppState.clearWishlist();
              AppState.orderHistory.clear();
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LandingPage()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ---------------- LANDING PAGE ----------------
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C2C2C),
              Color(0xFF1A1A1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(
                Icons.diamond,
                size: 100,
                color: Color(0xFFD4AF37),
              ),
              const SizedBox(height: 24),
              const Text(
                'LuxeGems',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Timeless Elegance',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: const Color(0xFF2C2C2C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const SignUpPage()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD4AF37),
                          side: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

//  ---------------- SIGN UP PAGE ----------------



class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  // Forces the content to be at least the height of the screen
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back Button at the very top
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
                                onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LandingPage()),
                                ),
                              ),
                            ),

                            // --- TOP FLEXIBLE SPACE ---
                            const Spacer(flex: 1),

                            const Text(
                              'Create\nAccount',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Full Name Field
                            TextFormField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: _buildInputDecoration('Full Name', Icons.person),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter your name';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              decoration: _buildInputDecoration('Email', Icons.email),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter your email';
                                if (!value.contains('@')) return 'Please enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: _buildInputDecoration('Password', Icons.lock).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: const Color(0xFFD4AF37),
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter a password';
                                if (value.length < 6) return 'Password must be at least 6 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),

                            // Sign Up Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _handleSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4AF37),
                                  foregroundColor: const Color(0xFF2C2C2C),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),

                            // --- BOTTOM FLEXIBLE SPACE ---
                            const Spacer(flex: 2),

                            Padding(
                              padding: const EdgeInsets.only(bottom: 20, top: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Already have an account? ', style: TextStyle(color: Colors.white70)),
                                  GestureDetector(
                                    onTap: () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LoginPage()),
                                    ),
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper for Input Decoration
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
    );
  }


  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      final user = User(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );
      AppState.registeredUsers.add(user);
      AppState.currentUser = user;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Color(0xFFD4AF37),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    }
  }
}
// ---------------- LOGIN PAGE ----------------

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back button stays at the top
                            Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
                                onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LandingPage()),
                                ),
                              ),
                            ),

                            // --- FLEXIBLE SPACE TOP ---
                            const Spacer(flex: 1),

                            const Text(
                              'Welcome\nBack',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: _buildInputDecoration('Email', Icons.email),
                              validator: (value) => (value == null || value.isEmpty) ? 'Please enter email' : null,
                            ),
                            const SizedBox(height: 20),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: _buildInputDecoration('Password', Icons.lock).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: const Color(0xFFD4AF37),
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (value) => (value == null || value.isEmpty) ? 'Please enter password' : null,
                            ),
                            const SizedBox(height: 30),

                            // Sign In Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4AF37),
                                  foregroundColor: const Color(0xFF2C2C2C),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Sign In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),

                            // --- FLEXIBLE SPACE BOTTOM ---
                            const Spacer(flex: 2),

                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Don't have an account? ", style: TextStyle(color: Colors.white70)),
                                  GestureDetector(
                                    onTap: () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                                    ),
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper method for consistent decoration
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
    );
  }

  // Extracted logic to keep build method clean
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      User? user;
      try {
        user = AppState.registeredUsers.firstWhere(
              (u) => u.email == _emailController.text && u.password == _passwordController.text,
        );
      } catch (_) {
        user = null;
      }

      if (user != null) {
        AppState.currentUser = user;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password'), backgroundColor: Colors.red),
        );
      }
    }
  }
}




// ---------------- DASHBOARD / HOME PAGE ----------------
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Inside _DashboardPageState
  final List<Product> products = [
    // --- RINGS (10) ---
    Product(
        name: "Diamond Solitaire",
        brand: "LuxeGems",
        description: "Exquisite 1-carat diamond ring",
        price: 2500, image: "assets/appimages/ring1.jpg",
        rating: 4.9,
        category: "Rings",
        materials: ["Platinum", "Diamond"]),
    Product(
        name: "Gold Band Ring",
        brand: "Elegance",
        description: "Classic 18K gold wedding band",
        price: 800, image: "assets/appimages/ring2.jpg",
        rating: 4.7,
        category: "Rings",
        materials: ["18K Gold"]),
    Product(
        name: "Sapphire Dream",
        brand: "GemStone",
        description: "Blue sapphire with diamond halo",
        price: 1900,
        image: "assets/appimages/ring3.jpg",
        rating: 4.8,
        category: "Rings",
        materials: ["White Gold", "Sapphire"]),
    Product(
        name: "Rose Gold Knot",
        brand: "Moderno",
        description: "Intricate knot design in rose gold",
        price: 450,
        image: "assets/appimages/ring4.jpg",
        rating: 4.5,
        category: "Rings",
        materials: ["Rose Gold"]),
    Product(
        name: "Emerald Cut Ring",
        brand: "LuxeGems",
        description: "Emerald cut diamond on thin band",
        price: 3200,
        image: "assets/appimages/ring5.jpg",
        rating: 4.9,
        category: "Rings",
        materials: ["Platinum", "Diamond"]),
    Product(
        name: "Vintage Floral",
        brand: "Legacy",
        description: "Art deco inspired floral ring",
        price: 1100,
        image: "assets/appimages/ring6.jpg",
        rating: 4.6,
        category: "Rings",
        materials: ["Yellow Gold"]),
    Product(
        name: "Infinity Band",
        brand: "Elegance",
        description: "Continuous diamond infinity ring",
        price: 1500, image: "assets/appimages/ring7.jpg",
        rating: 4.8,
        category: "Rings",
        materials: ["White Gold", "Diamond"]),
    Product(
        name: "Opal Fire Ring",
        brand: "OceanGems",
        description: "Ethopian opal with fiery play",
        price: 950,
        image: "assets/appimages/ring8.jpg",
        rating: 4.4,
        category: "Rings",
        materials: ["Gold", "Opal"]),
    Product(
        name: "Midnight Onyx",
        brand: "Noir",
        description: "Black onyx statement ring",
        price: 600,
        image: "assets/appimages/ring9.jpg",
        rating: 4.3,
        category: "Rings",
        materials: ["Silver", "Onyx"]),
    Product(
        name: "Twisted Vine",
        brand: "Nature",
        description: "Vine-like band with leaf detail",
        price: 300,
        image: "assets/appimages/ring10.jpg",
        rating: 4.7,
        category: "Rings",
        materials: ["Sterling Silver"]),

    // --- NECKLACES (10) ---
    Product(
        name: "Pearl Necklace",
        brand: "OceanGems",
        description: "Freshwater pearl strand",
        price: 1200,
        image: "assets/appimages/necklace1.jpg",
        rating: 4.8,
        category: "Necklaces",
        materials: ["Gold", "Pearl"]),
    Product(name: "Diamond Pendant",
        brand: "LuxeGems",
        description: "Heart-shaped diamond pendant",
        price: 1800,
        image: "assets/appimages/necklace2.jpg",
        rating: 4.9,
        category: "Necklaces",
        materials: ["White Gold", "Diamond"]),
    Product(
        name: "Gold Bar Choker",
        brand: "Minimal",
        description: "Sleek horizontal gold bar",
        price: 350,
        image: "assets/appimages/necklace3.jpg",
        rating: 4.2,
        category: "Necklaces",
        materials: ["14K Gold"]),
    Product(
        name: "Ruby Tear Drop",
        brand: "GemStone",
        description: "Pigeon blood ruby pendant",
        price: 2100,
        image: "assets/appimages/necklace4.jpg",
        rating: 4.7,
        category: "Necklaces",
        materials: ["Gold", "Ruby"]),
    Product(
        name: "Layered Chain",
        brand: "Moderno",
        description: "Triple layer gold chain set",
        price: 500,
        image: "assets/appimages/necklace5.jpg",
        rating: 4.5,
        category: "Necklaces",
        materials: ["Gold Plated"]),
    Product(
        name: "Moon & Star",
        brand: "Celestial",
        description: "Dainty celestial motif necklace",
        price: 200,
        image: "assets/appimages/necklace6.jpg",
        rating: 4.6,
        category: "Necklaces",
         materials: ["Silver"]),
    Product(
        name: "Locket Charm",
        brand: "Legacy",
        description: "Oval engraved vintage locket",
        price: 400,
        image: "assets/appimages/necklace7.jpg",
        rating: 4.4,
        category: "Necklaces",
        materials: ["Gold"]),
    Product(
        name: "Cross Pendant",
        brand: "Elegance",
        description: "Diamond studded classic cross",
        price: 1300,
        image: "assets/appimages/necklace8.jpg",
        rating: 4.8,
        category: "Necklaces",
        materials: ["Platinum", "Diamond"]),
    Product(
        name: "Emerald Cascade",
        brand: "LuxeGems",
        description: "Waterfall of emerald gems",
        price: 4500,
        image: "assets/appimages/necklace9.jpg",
        rating: 5.0,
        category: "Necklaces",
        materials: ["White Gold", "Emerald"]),
    Product(
        name: "Silk Tassel",
        brand: "Boho",
        description: "Long silk tassel with gold beads",
        price: 150,
        image: "assets/appimages/necklace10.jpg",
        rating: 4.1,
        category: "Necklaces",
        materials: ["Silk", "Gold Beads"]),


    // --- EARRINGS (10) ---
    Product(name: "Emerald Studs", brand: "GemStone", description: "Vibrant emerald stud earrings", price: 1500, image: "assets/appimages/earring1.jpg", rating: 4.8, category: "Earrings", materials: ["Yellow Gold", "Emerald"]),
    Product(name: "Diamond Hoops", brand: "LuxeGems", description: "Classic diamond hoop earrings", price: 2200, image: "assets/appimages/earring2.jpg", rating: 4.9, category: "Earrings", materials: ["White Gold", "Diamond"]),
    Product(name: "Pearl Drops", brand: "OceanGems", description: "Elegant hanging pearl drops", price: 700, image: "assets/appimages/earring3.jpg", rating: 4.6, category: "Earrings", materials: ["Rose Gold", "Pearl"]),
    Product(name: "Gold Knot Studs", brand: "Minimal", description: "Simple love knot gold studs", price: 250, image: "assets/appimages/earring4.jpg", rating: 4.4, category: "Earrings", materials: ["18K Gold"]),
    Product(name: "Blue Topaz Dangles", brand: "Nature", description: "Sky blue topaz teardrops", price: 550, image: "assets/appimages/earring5.jpg", rating: 4.5, category: "Earrings", materials: ["Silver", "Topaz"]),
    Product(name: "Crystal Clusters", brand: "Moderno", description: "Geometric crystal clusters", price: 180, image: "assets/appimages/earring6.jpg", rating: 4.2, category: "Earrings", materials: ["Rhodium"]),
    Product(name: "Starfish Studs", brand: "OceanGems", description: "Summer inspired gold starfish", price: 120, image: "assets/appimages/earring7.jpg", rating: 4.3, category: "Earrings", materials: ["Gold"]),
    Product(name: "Feather Silver", brand: "Boho", description: "Engraved silver feather dangles", price: 90, image: "assets/appimages/earring8.jpg", rating: 4.0, category: "Earrings", materials: ["Sterling Silver"]),
    Product(name: "Amethyst Oval", brand: "GemStone", description: "Deep purple amethyst settings", price: 800, image: "assets/appimages/earring9.jpg", rating: 4.7, category: "Earrings", materials: ["Gold", "Amethyst"]),
    Product(name: "Threader Hearts", brand: "Celestial", description: "Modern heart threader earrings", price: 300, image: "assets/appimages/earring10.jpg", rating: 4.6, category: "Earrings", materials: ["White Gold"]),

    // --- BRACELETS (10) ---
    Product(name: "Tennis Bracelet", brand: "Elegance", description: "Sparkling diamond tennis bracelet", price: 3500, image: "assets/appimages/bracelet1.jpg", rating: 5.0, category: "Bracelets", materials: ["Platinum", "Diamond"]),
    Product(name: "Gold Bangle", brand: "LuxeGems", description: "Solid 22K gold engraved bangle", price: 1600, image: "assets/appimages/bracelet2.jpg", rating: 4.7, category: "Bracelets", materials: ["22K Gold"]),
    Product(name: "Charm Bracelet", brand: "Legacy", description: "Bracelet with various gold charms", price: 850, image: "assets/appimages/bracelet3.jpg", rating: 4.5, category: "Bracelets", materials: ["Gold"]),
    Product(name: "Leather Wrap", brand: "Noir", description: "Black leather with silver clasp", price: 150, image: "assets/appimages/bracelet4.jpg", rating: 4.1, category: "Bracelets", materials: ["Leather", "Silver"]),
    Product(name: "Cuff Bracelet", brand: "Minimal", description: "Wide hammered metal cuff", price: 300, image: "assets/appimages/bracelet5.jpg", rating: 4.3, category: "Bracelets", materials: ["Brass"]),
    Product(name: "Turquoise Bead", brand: "Nature", description: "Natural turquoise beaded band", price: 200, image: "assets/appimages/bracelet6.jpg", rating: 4.4, category: "Bracelets", materials: ["Turquoise"]),
    Product(name: "Link Bracelet", brand: "Moderno", description: "Heavy industrial link design", price: 450, image: "assets/appimages/bracelet7.jpg", rating: 4.2, category: "Bracelets", materials: ["Sterling Silver"]),
    Product(name: "ID Bracelet", brand: "Minimal", description: "Personalized gold ID plate", price: 600, image: "assets/appimages/bracelet8.jpg", rating: 4.6, category: "Bracelets", materials: ["14K Gold"]),
    Product(name: "Multi-Color Gem", brand: "Boho", description: "Bracelet with various stones", price: 750, image: "assets/appimages/bracelet9.jpg", rating: 4.5, category: "Bracelets", materials: ["Gold", "Mixed Gems"]),
    Product(name: "Diamond Cuff", brand: "LuxeGems", description: "Dainty open cuff with diamonds", price: 1900, image: "assets/appimages/bracelet10.jpg", rating: 4.9, category: "Bracelets", materials: ["White Gold", "Diamond"]),
  ];

  final List<String> categories = ["All", "Rings", "Necklaces", "Earrings", "Bracelets"];
  String selectedCategory = "All";
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  List<Product> get filteredProducts {
    return products.where((p) {
      final matchesCategory = selectedCategory == "All" || p.category == selectedCategory;
      final matchesSearch = p.name.toLowerCase().contains(searchQuery.toLowerCase()) || 
                           p.brand.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LuxeGems",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  ).then((_) => setState(() {}));
                },
              ),
              if (AppState.totalItems > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4AF37),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      AppState.totalItems.toString(),
                      style: const TextStyle(
                        color: Color(0xFF2C2C2C),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // ADDED: Wishlist Icon with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WishlistPage()),
                  ).then((_) => setState(() {}));
                },
              ),
              if (AppState.wishlistItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4AF37),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      AppState.wishlistItems.length.toString(),
                      style: const TextStyle(
                        color: Color(0xFF2C2C2C),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2C2C2C), Color(0xFF4A4A4A)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Icon(
                      Icons.diamond,
                      size: 200,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome, ${AppState.currentUser?.name ?? "Guest"}',
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Discover timeless elegance',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search for rings, necklaces...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
                  suffixIcon: searchQuery.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              searchQuery = "";
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            // --- ADDED HERE: Larger Square Banner ---
            const AestheticDiscountBanner(),
            // Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = category == selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                            selectedColor: const Color(0xFFD4AF37),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? const Color(0xFF2C2C2C) : Colors.black54,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Products Grid
            Padding(
              padding: const EdgeInsets.all(16),
              child: filteredProducts.isEmpty 
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No products found matching "$searchQuery"',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredProducts.length,
                    // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    //   crossAxisCount: 2,
                    //   childAspectRatio: 1.3,
                    //   crossAxisSpacing: 16,
                    //   mainAxisSpacing: 16,
                    // ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2, // 3 columns on tablets
                  childAspectRatio: MediaQuery.of(context).size.width < 360 ? 0.65: 0.72, // Adjust for small/large screens
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: filteredProducts[index],
                        onAdd: () {
                          setState(() {
                            AppState.addToCart(filteredProducts[index]);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${filteredProducts[index].name} added to cart"),
                              duration: const Duration(seconds: 1),
                              backgroundColor: const Color(0xFFD4AF37),
                            ),
                          );
                        },
                        onToggleWishlist: () {
                          setState(() {
                            AppState.toggleWishlist(filteredProducts[index]);
                          });
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- PRODUCT CARD ----------------
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;
  final VoidCallback onToggleWishlist;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAdd,
    required this.onToggleWishlist,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInWishlist = AppState.isInWishlist(product);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        ).then((_) => onToggleWishlist()); // Refresh state on return
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
        AspectRatio(
        aspectRatio: 1.2,
                child:Container(
                  // height: 120,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F0),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.diamond,
                          size: 80,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.rating.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.star, size: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: onToggleWishlist,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isInWishlist ? Icons.favorite : Icons.favorite_border,
                        color: isInWishlist ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                // padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.brand,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                        child:Text(
                          "\$${product.price}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: onAdd,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- PRODUCT DETAIL PAGE ----------------
class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int userRating = 0;

  @override
  Widget build(BuildContext context) {
    bool isInWishlist = AppState.isInWishlist(widget.product);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF2C2C2C),
            actions: [
              IconButton(
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWishlist ? Colors.red : const Color(0xFFD4AF37),
                ),
                onPressed: () {
                  setState(() {
                    AppState.toggleWishlist(widget.product);
                  });
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2C2C2C), Color(0xFF4A4A4A)],
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    widget.product.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.diamond,
                      size: 150,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.product.category,
                            style: const TextStyle(
                              color: Color(0xFF2C2C2C),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFD4AF37), size: 20),
                            const SizedBox(width: 4),
                            Text(
                              widget.product.rating.toString(),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.brand,
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "\$${widget.product.price}",
                      style: const TextStyle(
                        fontSize: 32,
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.description,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Materials',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: widget.product.materials
                          .map(
                            (material) => Chip(
                          label: Text(material),
                          backgroundColor: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                        ),
                      )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Rate this product',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < userRating ? Icons.star : Icons.star_border,
                            color: const Color(0xFFD4AF37),
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() => userRating = index + 1);
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          AppState.addToCart(widget.product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${widget.product.name} added to cart"),
                              backgroundColor: const Color(0xFFD4AF37),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- WISHLIST PAGE ----------------
class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
      ),
      body: AppState.wishlistItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Your wishlist is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Shopping'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: AppState.wishlistItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final product = AppState.wishlistItems[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            product.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.diamond,
                              color: Color(0xFFD4AF37),
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(product.brand, style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            Text(
                              "\$${product.price}",
                              style: const TextStyle(
                                color: Color(0xFFD4AF37),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                AppState.toggleWishlist(product);
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_shopping_cart, color: Color(0xFFD4AF37)),
                            onPressed: () {
                              AppState.addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${product.name} added to cart"),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: const Color(0xFFD4AF37),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ---------------- CART PAGE ----------------
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart (${AppState.totalItems} items)"),
      ),
      body: AppState.cartItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: AppState.cartItems.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final cartItem = AppState.cartItems[index];
                return Dismissible(
                  key: ValueKey("${cartItem.product.name}-$index"),
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.delete, color: Colors.white, size: 32),
                  ),
                  secondaryBackground: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white, size: 32),
                  ),
                  onDismissed: (_) {
                    setState(() {
                      AppState.removeFromCart(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${cartItem.product.name} removed from cart"),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              cartItem.product.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.diamond,
                                size: 40,
                                color: Color(0xFFD4AF37),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cartItem.product.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cartItem.product.brand,
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "\$${cartItem.product.price * cartItem.quantity}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD4AF37),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: () {
                                  setState(() {
                                    if (cartItem.quantity > 1) {
                                      cartItem.quantity--;
                                    } else {
                                      AppState.removeFromCart(index);
                                    }
                                  });
                                },
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  cartItem.quantity.toString(),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () {
                                  setState(() {
                                    cartItem.quantity++;
                                  });
                                },
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${AppState.totalPrice}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CheckoutPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- CHECKOUT PAGE ----------------
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedPayment = 'Credit Card';

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Shipping Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter address' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter city' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter phone' : null,
              ),
              const SizedBox(height: 30),
              const Text('Payment Method', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              RadioListTile(
                title: const Text('Credit Card'),
                value: 'Credit Card',
                groupValue: _selectedPayment,
                onChanged: (val) => setState(() => _selectedPayment = val!),
              ),
              RadioListTile(
                title: const Text('Cash on Delivery'),
                value: 'COD',
                groupValue: _selectedPayment,
                onChanged: (val) => setState(() => _selectedPayment = val!),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Items:'),
                        Text('${AppState.totalItems}'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('\$${AppState.totalPrice}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Order Successful!'),
                          content: const Text('Your jewelry will be delivered soon.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                // Save order to history
                                AppState.orderHistory.add(
                                  Order(
                                    items: List.from(AppState.cartItems),
                                    total: AppState.totalPrice,
                                    date: DateTime.now(),
                                  ),
                                );
                                AppState.clearCart();
                                Navigator.pop(ctx);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                                  (route) => false,
                                );
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Place Order', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- PROFILE PAGE ----------------
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: AppState.currentUser?.name);
    _emailController = TextEditingController(text: AppState.currentUser?.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AppState.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                setState(() {
                  AppState.currentUser?.name = _nameController.text;
                  AppState.currentUser?.email = _emailController.text;
                  _isEditing = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully!')),
                );
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFD4AF37),
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name.substring(0, 1).toUpperCase() : "G",
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C)),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF2C2C2C),
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18, color: Color(0xFFD4AF37)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Profile picture upload coming soon!")),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileField('Full Name', _nameController, Icons.person),
                  const SizedBox(height: 20),
                  _buildProfileField('Email Address', _emailController, Icons.email),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersPage())),
                    child: _buildStatCard('Orders', '${AppState.orderHistory.length}', Icons.shopping_bag),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistPage())),
                    child: _buildStatCard('Wishlist', '${AppState.wishlistItems.length}', Icons.favorite),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildSettingsItem('Notification Settings', Icons.notifications_none, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsPage()));
            }),
            _buildSettingsItem('Privacy & Security', Icons.security, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySecurityPage()));
            }),
            _buildSettingsItem('Help & Support', Icons.help_outline, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportPage()));
            }),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    AppState.currentUser = null;
                    AppState.clearCart();
                    AppState.clearWishlist();
                    AppState.orderHistory.clear();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LandingPage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Logout'),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
        border: _isEditing ? const OutlineInputBorder() : InputBorder.none,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37)),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2C2C2C)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

// ---------------- ORDERS PAGE ----------------
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: AppState.orderHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No orders yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: AppState.orderHistory.length,
              itemBuilder: (context, index) {
                final order = AppState.orderHistory[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${AppState.orderHistory.length - index}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order.status,
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Date: ${order.date.day}/${order.date.month}/${order.date.year}'),
                        const Divider(height: 24),
                        ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.asset(item.product.image, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.diamond, size: 40)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(item.product.name)),
                                  Text('x${item.quantity}'),
                                ],
                              ),
                            )),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('\$${order.total}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ---------------- NOTIFICATION SETTINGS PAGE ----------------
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _orderUpdates = true;
  bool _promotions = false;
  bool _newsletter = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Order Updates'),
            subtitle: const Text('Receive notifications about your order status'),
            value: _orderUpdates,
            onChanged: (val) => setState(() => _orderUpdates = val),
          ),
          SwitchListTile(
            title: const Text('Promotions'),
            subtitle: const Text('Get notified about sales and special offers'),
            value: _promotions,
            onChanged: (val) => setState(() => _promotions = val),
          ),
          SwitchListTile(
            title: const Text('Newsletter'),
            subtitle: const Text('Stay updated with our weekly jewelry trends'),
            value: _newsletter,
            onChanged: (val) => setState(() => _newsletter = val),
          ),
        ],
      ),
    );
  }
}

// ---------------- PRIVACY & SECURITY PAGE ----------------
class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password reset email sent!")));
            },
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Two-Factor Authentication'),
            trailing: Switch(value: false, onChanged: (val) {}),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
            title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Account?'),
                  content: const Text('This action cannot be undone. All your data will be permanently removed.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------- HELP & SUPPORT PAGE ----------------
class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Frequently Asked Questions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildFaqItem('How long does shipping take?', 'Usually 3-5 business days depending on your location.'),
          _buildFaqItem('Is the jewelry authentic?', 'Yes, all our gems come with a certificate of authenticity.'),
          _buildFaqItem('What is your return policy?', 'We offer a 30-day no-questions-asked return policy.'),
          const SizedBox(height: 30),
          const Text('Contact Us', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.email_outlined, color: Color(0xFFD4AF37)),
            title: const Text('support@luxegems.com'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined, color: Color(0xFFD4AF37)),
            title: const Text('+1 234 567 890'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
      children: [Padding(padding: const EdgeInsets.all(16), child: Text(answer))],
    );
  }
}
// --- AESTHETIC SLIDING SQUARE DISCOUNT BANNER ---
class AestheticDiscountBanner extends StatefulWidget {
  const AestheticDiscountBanner({super.key});

  @override
  State<AestheticDiscountBanner> createState() => _AestheticDiscountBannerState();
}

class _AestheticDiscountBannerState extends State<AestheticDiscountBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // void _handleRedeem(String promoCode) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Promo code "$promoCode" applied!'),
  //       backgroundColor: const Color(0xFFD4AF37),
  //       behavior: SnackBarBehavior.floating,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 250,
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) => setState(() => _currentPage = page),
                children: [
                  _buildSlide('EXCLUSIVE COLLECTION', 'Special\nOffer 40% OFF', 'LUXE40', const Color(0xFF1A1A1A), Icons.auto_awesome),
                  _buildSlide('WEDDING SEASON', 'Bridal\nSets -20%', 'FOREVER', const Color(0xFF2C2C2C), Icons.favorite),
                  _buildSlide('NEW ARRIVALS', 'Gold\nEssentials', 'GOLDEN', const Color(0xFF333333), Icons.diamond),
                ],
              ),
            ),
            // Arrows for navigation
            if (_currentPage > 0)
              Positioned(
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white54),
                  onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                ),
              ),
            if (_currentPage < 2)
              Positioned(
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
                  onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: _currentPage == index ? 24 : 12,
            margin: const EdgeInsets.only(right: 5),
            color: _currentPage == index ? const Color(0xFFD4AF37) : Colors.grey[400],
          )),
        ),
      ],
    );
  }

  Widget _buildSlide(String title, String headline, String promo, Color color, IconData icon) {
    return InkWell( // Wrap the whole slide
      onTap: () {
        // Calculate discount value based on the promo string
        double val = promo == 'LUXE40' ? 0.40 : (promo == 'FOREVER' ? 0.20 : 0.10);
       // _handleRedeem(promo, val);
      },
      child: Container(
        color: color,
        child: Stack(
          children: [
            Positioned(
              right: -30,
              bottom: -20,
              child: Icon(icon, size: 200, color: Colors.white.withOpacity(0.05)),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, letterSpacing: 4)),
                  const SizedBox(height: 12),
                  Text(headline, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
                  const SizedBox(height: 10),
                  // Button is removed here
                  const Text(
                    'Tap to apply discount',
                    style: TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





// ---------------- SPLASH SCREEN (OPENING PAGE) ----------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // 1. Setup Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // 2. Navigate to LandingPage after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LandingPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C), // Matches your app's dark theme
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.diamond,
                size: 100,
                color: Color(0xFFD4AF37), // Your Gold color
              ),
              const SizedBox(height: 20),
              const Text(
                'LuxeGems',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 2,
                color: const Color(0xFFD4AF37),
              ),
              const SizedBox(height: 10),
              const Text(
                'FINE JEWELRY',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                  letterSpacing: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}