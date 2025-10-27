import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pmsn2025_2/firebase/cart_firebase.dart';
import 'package:pmsn2025_2/firebase/fire_auth.dart';

class PlantScreen extends StatefulWidget {
  final Map<String, dynamic> plant;

  const PlantScreen({super.key, required this.plant});

  @override
  State<PlantScreen> createState() => _PlantScreenState();
}

class _PlantScreenState extends State<PlantScreen> {
  bool isFavorite = false;
  int quantity = 1;

  CartFirebase cartFirebase = CartFirebase();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
  }

  Future<void> _addToCart() async {
    print('Adding to cart: Plant ID=${widget.plant}, Quantity=$quantity');
    await cartFirebase.insertCartItem({
      "user_id": _user!.uid, // Reemplazar con el ID del usuario actual
      "plant_id": widget.plant['id']!,
      "quantity": quantity,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to cart'),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo dividido (verde arriba, blanco abajo)
          Column(
            children: [
              // Fondo verde superior
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(100),
                      bottomRight: Radius.circular(100),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.green[600]!, Colors.green[400]!],
                    ),
                  ),
                ),
              ),
              // Fondo blanco inferior
              Expanded(
                flex: 1,
                child: Container(width: double.infinity, color: Colors.white),
              ),
            ],
          ),

          // Contenido scrolleable
          SingleChildScrollView(
            child: Column(
              children: [
                // AppBar personalizado
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isFavorite = !isFavorite;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Imagen flotante de la planta
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green[100]?.withOpacity(0.3),
                    boxShadow: [
                      // BoxShadow(
                      //   color: Colors.black.withOpacity(0.2),
                      //   spreadRadius: 5,
                      //   blurRadius: 20,
                      //   offset: Offset(0, 10),
                      // ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      padding: EdgeInsets.all(30),
                      child: Image.network(
                        widget.plant['image']!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Información de la planta
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre y precio
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.plant['name']!,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    widget.plant['price']!.toString(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Control de cantidad
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: quantity > 1
                                        ? () {
                                            setState(() {
                                              quantity--;
                                            });
                                          }
                                        : null,
                                    icon: Icon(Icons.remove),
                                    color: Colors.grey[600],
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      '$quantity',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        quantity++;
                                      });
                                    },
                                    icon: Icon(Icons.add),
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Rating y reseñas
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                color: index < widget.plant['rating']!.toInt()
                                    ? Colors.amber
                                    : Colors.grey[300],
                                size: 20,
                              );
                            }),
                            SizedBox(width: 8),
                            Text(
                              '${widget.plant['rating']!} (${widget.plant['reviews']!} reviews)',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24),

                        // About the plant
                        Text(
                          'About the Plant',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '${widget.plant['description']!}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: 24),

                        // How to care
                        Text(
                          'How to Care',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 16),

                        // Cuidados en grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildCareItem(
                                Icons.wb_sunny,
                                'Light',
                                'Bright indirect',
                                Colors.orange,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildCareItem(
                                Icons.water_drop,
                                'Water',
                                'Weekly',
                                Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCareItem(
                                Icons.device_thermostat,
                                'Temperature',
                                '18-24°C',
                                Colors.red,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildCareItem(
                                Icons.grass,
                                'Humidity',
                                '40-60%',
                                Colors.green,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 120), // Espacio para los botones fijos
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Botones inferiores fijos
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Botón Add to Favorites
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavorite
                            ? 'Added to favorites'
                            : 'Removed from favorites',
                      ),
                      backgroundColor: Colors.grey[700],
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[800],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey[600],
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Add to Favorites',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),

            // Botón Buy
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(
                  //     content: Text('Processing purchase...'),
                  //     backgroundColor: Colors.green[600],
                  //     behavior: SnackBarBehavior.floating,
                  //   ),
                  // );
                  _addToCart();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag),
                    SizedBox(width: 8),
                    Text(
                      'Add to cart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildCareItem(
    IconData icon,
    String title,
    String value,
    Color iconColor,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
