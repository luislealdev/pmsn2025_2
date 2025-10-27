import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pmsn2025_2/firebase/cart_firebase.dart';
import 'package:pmsn2025_2/firebase/plants_firebase.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  CartFirebase cartFirebase = CartFirebase();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  PlantsFirebase plantsFirebase = PlantsFirebase();
  User? _user;
  double totalAmount = 0.0;
  int totalItems = 0;

  // double get totalAmount {
  //   return cartItems.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity']));
  // }

  // int get totalItems {
  //   return cartItems.fold(0, (sum, item) => sum + item['quantity'] as int);
  // }

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Shopping Cart",
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        // actions: [
        //   cartItems.isNotEmpty
        //       ? TextButton(
        //           onPressed: () => _showClearCartDialog(),
        //           child: Text(
        //             "Clear",
        //             style: TextStyle(
        //               color: Colors.red[600],
        //               fontWeight: FontWeight.w600,
        //             ),
        //           ),
        //         )
        //       : SizedBox.shrink(),
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: cartFirebase.selectAllCartItems(_user!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isEmpty) {
                    return _buildEmptyCart();
                  }

                  final cartItems = snapshot.data!.docs;

                  totalItems = cartItems.fold(
                    0,
                    (sum, item) => sum + item['quantity'] as int,
                  );

                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final cartDoc = cartItems[index];
                      final cartData = cartDoc.data() as Map<String, dynamic>;
                      final String plantId = cartData['plant_id'];
                      final int quantity = cartData['quantity'];

                      // final item =
                      //     snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      return FutureBuilder<DocumentSnapshot>(
                        future: plantsFirebase.selectPlantById(plantId),
                        builder: (context, plantSnapshot) {
                          if (plantSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ListTile(
                              leading: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                              title: Text('Cargando...'),
                            );
                          }

                          if (!plantSnapshot.hasData ||
                              !plantSnapshot.data!.exists) {
                            return ListTile(
                              title: Text('Planta no encontrada'),
                              subtitle: Text('ID: $plantId'),
                            );
                          }

                          final plantData =
                              plantSnapshot.data!.data()
                                  as Map<String, dynamic>;

                          final double price = plantData['price'];
                          totalAmount += price * quantity;

                          return _buildCartItem({
                            'name': plantData['name'],
                            'image': plantData['image'],
                            'price': plantData['price'],
                            'quantity': quantity,
                          }, index);
                        },
                      );
                    },
                  );
                } else {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }
              },
            ),
          ),
          _buildCartSummary(),
        ],
      ),
      // body: cartItems.isEmpty
      //     ? _buildEmptyCart()
      //     : Column(
      //         children: [
      //           // Lista de productos en el carrito
      //           Expanded(
      //             child: ListView.builder(
      //               padding: EdgeInsets.all(16),
      //               itemCount: cartItems.length,
      //               itemBuilder: (context, index) {
      //                 final item = cartItems[index];
      //                 return _buildCartItem(item, index);
      //               },
      //             ),
      //           ),

      //           // Resumen y botón de checkout
      //           _buildCartSummary(),
      //         ],
      //       ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Add some plants to get started!",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Continue Shopping",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagen del producto
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.local_florist,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 16),

          // Información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "\$${item['price'].toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),

                // Controles de cantidad
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (item['quantity'] > 1) {
                                  item['quantity']--;
                                }
                              });
                            },
                            icon: Icon(Icons.remove, size: 16),
                            constraints: BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${item['quantity']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                item['quantity']++;
                              });
                            },
                            icon: Icon(Icons.add, size: 16),
                            constraints: BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Text(
                      "\$${(item['price'] * item['quantity']).toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Botón eliminar
          IconButton(
            onPressed: () => _showRemoveItemDialog(item, index),
            icon: Icon(Icons.delete_outline, color: Colors.red[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary() {
    return Container(
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
      child: Column(
        children: [
          // Resumen de totales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Items ($totalItems)",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              Text(
                "\$${totalAmount.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Delivery",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              Text(
                "Free",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                "\$${totalAmount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Botón de checkout
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _proceedToCheckout(),
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
                  Icon(Icons.payment),
                  SizedBox(width: 8),
                  Text(
                    "Proceed to Checkout",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveItemDialog(Map<String, dynamic> item, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Remove Item"),
        content: Text(
          "Are you sure you want to remove ${item['name']} from your cart?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // setState(() {
              //   cartItems.removeAt(index);
              // });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${item['name']} removed from cart"),
                  backgroundColor: Colors.red[600],
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
            child: Text("Remove"),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clear Cart"),
        content: Text(
          "Are you sure you want to remove all items from your cart?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // cartItems.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Cart cleared"),
                  backgroundColor: Colors.red[600],
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
            child: Text("Clear All"),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Checkout"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order Summary:"),
            SizedBox(height: 8),
            // Text("Items: $totalItems"),
            // Text("Total: \$${totalAmount.toStringAsFixed(2)}"),
            SizedBox(height: 16),
            Text(
              "Your order will be processed and delivered within 2-3 business days.",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // cartItems.clear();
              });
              Navigator.pop(context);
              Navigator.pop(context); // Volver al home
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Order placed successfully! 🎉"),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
            child: Text("Place Order"),
          ),
        ],
      ),
    );
  }
}
