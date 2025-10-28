import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pmsn2025_2/firebase/plants_firebase.dart';
import 'package:pmsn2025_2/screens/flora/add_plant_screen.dart';
import 'package:pmsn2025_2/screens/flora/plant_screen.dart';
import 'package:pmsn2025_2/screens/flora/account_screen.dart';
import 'package:pmsn2025_2/screens/flora/cart_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class FloraHomeScreen extends StatefulWidget {
  FloraHomeScreen({super.key});

  @override
  State<FloraHomeScreen> createState() => _FloraHomeScreenState();
}

class _FloraHomeScreenState extends State<FloraHomeScreen> {
  PlantsFirebase plantsFirebase = PlantsFirebase();

  // Image, name, price
  // final List<Map<String, String>> plants = [
  //   {'image': 'assets/flora/plant1.png', 'name': 'Plant 1', 'price': '\$10'},
  //   {'image': 'assets/flora/plant2.png', 'name': 'Plant 2', 'price': '\$12'},
  //   {'image': 'assets/flora/plant3.png', 'name': 'Plant 3', 'price': '\$15'},
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // Asegura que el fondo sea exactamente blanco
      appBar: AppBar(
        elevation: 0, // Elimina completamente la elevación/sombra
        shadowColor: Colors.transparent,
        surfaceTintColor:
            Colors.transparent, // Elimina el tinte de superficie en Material 3
        leading: Icon(Icons.menu, color: Colors.black38),
        backgroundColor: Colors.white,
        foregroundColor:
            Colors.black, // Asegura que el color del contenido sea consistente
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountScreen()),
              );
            },
            child: Icon(Icons.account_circle_outlined, color: Colors.black38),
          ),
          SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPlantScreen()),
              );
            },
            child: Icon(Icons.add, color: Colors.black38),
          ),
          SizedBox(width: 16),
        ],
        title: Row(
          children: [
            // Ícono de carrito en el lado izquierdo
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.green[600],
                      size: 24,
                    ),
                    // Badge de notificación (simulado)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Título centrado con logo
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/flora/flora_logo.png',
                    height: 28,
                    width: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "FLORA",
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Espacio para balancear el diseño
            SizedBox(width: 40),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormField(
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.black38),
                      hintText: "Explore your favorites",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                textAlign: TextAlign.left,
                "All Plants",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 160, // Define una altura específica
              child: StreamBuilder(
                stream: plantsFirebase.selectAllPlants(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.isEmpty) {
                      return Text("No se encontró información");
                    }
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final id = snapshot.data!.docs[index].reference.id;
                        final plant = {
                          ...(doc.data() as Map<String, dynamic>),
                          "id": id,
                        };
                        return PlantCard(plant: plant);
                      },
                    );
                  } else {
                    return Text("No se encontró información");
                  }
                },
              ),
              // child: ListView(

              //   children: <Widget>[
              //     ...plants.map(
              //       (plant) => GestureDetector(
              //         onTap: () {
              //           Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) => PlantScreen(plant: plant),
              //             ),
              //           );
              //         },
              //         child: Container(
              //           width: 150,
              //           alignment: Alignment.centerLeft,
              //           margin: EdgeInsets.only(right: 28),
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(20),
              //             color: const Color.fromARGB(156, 131, 214, 24),
              //           ),
              //           child: Column(
              //             mainAxisAlignment: MainAxisAlignment.start,
              //             children: [
              //               Center(
              //                 child: Image.asset(
              //                   plant['image']!,
              //                   height: 120,
              //                   width: 120,
              //                 ),
              //               ),
              //               Text(
              //                 plant['name']!,
              //                 style: TextStyle(fontWeight: FontWeight.bold),
              //               ),
              //               Text(plant['price']!, textAlign: TextAlign.left),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                textAlign: TextAlign.left,
                "Categories",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // GridView.builder(
            //   shrinkWrap: true,
            //   physics:
            //       NeverScrollableScrollPhysics(), // Esto permite que el SingleChildScrollView maneje el scroll
            //   padding: EdgeInsets.symmetric(horizontal: 20),
            //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: 3,
            //     mainAxisSpacing: 30,
            //     crossAxisSpacing: 20,
            //     childAspectRatio: 0.8,
            //   ),
            //   itemCount:
            //       plants.length *
            //       2, // Mostrar cada planta dos veces (6 items total)
            //   itemBuilder: (context, index) {
            //     final plant = plants[index % plants.length];
            //     return GestureDetector(
            //       onTap: () {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => PlantScreen(plant: plant),
            //           ),
            //         );
            //       },
            //       child: Container(
            //         decoration: BoxDecoration(
            //           // borderRadius: BorderRadius.circular(12),
            //           color: Colors.grey[100],
            //           // border: Border.all(color: Colors.grey[300]!, width: 1),
            //         ),
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             Expanded(
            //               flex: 3,
            //               child: Padding(
            //                 padding: EdgeInsets.all(8.0),
            //                 child: Image.asset(
            //                   plant['image']!,
            //                   fit: BoxFit.contain,
            //                 ),
            //               ),
            //             ),
            //             Expanded(
            //               flex: 1,
            //               child: Padding(
            //                 padding: EdgeInsets.symmetric(horizontal: 4.0),
            //                 child: Text(
            //                   plant['name']!,
            //                   style: TextStyle(
            //                     fontWeight: FontWeight.bold,
            //                     fontSize: 12,
            //                   ),
            //                   textAlign: TextAlign.center,
            //                   maxLines: 2,
            //                   overflow: TextOverflow.ellipsis,
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     );
            //   },
            // ),

            // Banner promocional
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[400],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Special Offer!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Get Up To 40% Off",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                    Icon(Icons.local_offer, color: Colors.white, size: 24),
                  ],
                ),
              ),
            ),

            // // Añadir más contenido para demostrar el scroll
            // Padding(
            //   padding: const EdgeInsets.all(20.0),
            //   child: Text(
            //     "Popular Plants",
            //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //   ),
            // ),

            // // Lista adicional para asegurar que haya scroll
            // Container(
            //   height: 200,
            //   child: ListView.builder(
            //     scrollDirection: Axis.horizontal,
            //     padding: EdgeInsets.symmetric(horizontal: 20),
            //     itemCount: plants.length,
            //     itemBuilder: (context, index) {
            //       final plant = plants[index];
            //       return GestureDetector(
            //         onTap: () {
            //           Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //               builder: (context) => PlantScreen(plant: plant),
            //             ),
            //           );
            //         },
            //         child: Container(
            //           width: 150,
            //           margin: EdgeInsets.only(right: 16),
            //           decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(16),
            //             color: Colors.white,
            //             boxShadow: [
            //               BoxShadow(
            //                 color: Colors.grey.withOpacity(0.2),
            //                 spreadRadius: 1,
            //                 blurRadius: 6,
            //                 offset: Offset(0, 3),
            //               ),
            //             ],
            //           ),
            //           child: Column(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               Image.asset(
            //                 plant['image']!,
            //                 height: 100,
            //                 width: 100,
            //                 fit: BoxFit.contain,
            //               ),
            //               SizedBox(height: 8),
            //               Text(
            //                 plant['name']!,
            //                 style: TextStyle(
            //                   fontWeight: FontWeight.bold,
            //                   fontSize: 14,
            //                 ),
            //               ),
            //               Text(
            //                 plant['price']!,
            //                 style: TextStyle(
            //                   color: Colors.green[600],
            //                   fontSize: 16,
            //                   fontWeight: FontWeight.w600,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),
            SizedBox(height: 40), // Espacio final para asegurar scroll
          ],
        ),
      ),
    );
  }
}

class PlantCard extends StatelessWidget {
  const PlantCard({super.key, required this.plant});

  final Map<String, dynamic> plant;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PlantScreen(plant: plant)),
        );
      },
      child: Container(
        width: 150,
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(right: 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(156, 131, 214, 24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Image.network(plant['image']!, height: 120, width: 120),
            ),
            Text(plant['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(plant['price']!.toString(), textAlign: TextAlign.left),
          ],
        ),
      ),
    );
  }
}
