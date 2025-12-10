import 'package:flutter/material.dart';
import 'package:pmsn2025_2/services/simple_plants_service.dart';
import 'package:pmsn2025_2/services/firebase_error_notification_service.dart';
import 'package:pmsn2025_2/utils/database_cleaner.dart';
import 'package:pmsn2025_2/widgets/storage_mode_selector.dart';
import 'package:pmsn2025_2/widgets/firebase_error_banner.dart';
import 'package:pmsn2025_2/screens/flora/add_plant_screen.dart';
import 'package:pmsn2025_2/screens/flora/plant_screen.dart';
import 'package:pmsn2025_2/screens/flora/account_screen.dart';
import 'package:pmsn2025_2/screens/flora/cart_screen.dart';
import 'package:pmsn2025_2/screens/flora/storage_settings_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FloraHomeScreen extends StatefulWidget {
  FloraHomeScreen({super.key});

  @override
  State<FloraHomeScreen> createState() => _FloraHomeScreenState();
}

class _FloraHomeScreenState extends State<FloraHomeScreen> {
  final SimplePlantsService _plantsService = SimplePlantsService();
  final FirebaseErrorNotificationService _errorNotification = FirebaseErrorNotificationService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _plantsService.initialize();
      print('✅ Simple Plants Service initialized');
    } catch (e) {
      print('❌ Error initializing service: $e');
    }
  }

  void _showStorageModeDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StorageSettingsScreen()),
    );
  }

  Future<void> _clearDatabase() async {
    // Mostrar confirmación
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Limpiar Base de Datos'),
          content: Text('¿Estás seguro de que deseas limpiar la base de datos local? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Limpiar', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await DatabaseCleaner.clearDatabase();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Base de datos limpiada. Reinicia la app.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al limpiar: $e')),
        );
      }
    }
  }

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
        surfaceTintColor: Colors.transparent, // Elimina el tinte de superficie en Material 3
        leading: Icon(Icons.menu, color: Colors.black38),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Asegura que el color del contenido sea consistente
        
        // Título simple centrado
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/flora/flora_logo.png',
              height: 20,
              width: 20,
            ),
            SizedBox(width: 4),
            Text(
              "FLORA",
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        
        // Acciones simplificadas
        actions: [
          // Carrito compacto
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
            child: Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.green[600],
                    size: 20,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
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
          
          // Menú de opciones
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black38, size: 20),
            onSelected: (String value) {
              switch (value) {
                case 'storage':
                  _showStorageModeDialog();
                  break;
                case 'account':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountScreen()),
                  );
                  break;
                case 'add':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddPlantScreen()),
                  );
                  break;
                case 'clear_db':
                  _clearDatabase();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'add',
                child: Row(
                  children: [
                    Icon(Icons.add, color: Colors.green[600], size: 18),
                    SizedBox(width: 8),
                    Text('Agregar Planta'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'storage',
                child: Row(
                  children: [
                    Icon(Icons.storage, color: Colors.blue[600], size: 18),
                    SizedBox(width: 8),
                    Text('Almacenamiento'),
                    SizedBox(width: 4),
                    CurrentStorageModeIndicator(showIcon: false),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'account',
                child: Row(
                  children: [
                    Icon(Icons.account_circle, color: Colors.grey[600], size: 18),
                    SizedBox(width: 8),
                    Text('Cuenta'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'clear_db',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red[600], size: 18),
                    SizedBox(width: 8),
                    Text('Limpiar BD'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de error Firebase
            StreamBuilder<bool>(
              stream: _errorNotification.errorStream,
              initialData: _errorNotification.hasError,
              builder: (context, snapshot) {
                return FirebaseErrorBanner(
                  showError: snapshot.data ?? false,
                  onDismiss: () {
                    _errorNotification.dismissError();
                  },
                );
              },
            ),
            
            // Contenido original
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
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _plantsService.plantsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_florist, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text("No plants found", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final plant = snapshot.data![index];
                        return PlantCard(plant: plant);
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 48, color: Colors.red),
                          SizedBox(height: 8),
                          Text("Error loading plants", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                      ),
                    );
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
    // Validar la URL de la imagen
    final imageUrl = plant['image'] as String?;
    final bool isUrlValid = imageUrl != null && imageUrl.isNotEmpty;

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
            SizedBox(
              height: 120,
              width: 120,
              child: isUrlValid
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      placeholder: (context, url) => Container(
                        height: 120,
                        width: 120,
                        child: Center(child: CircularProgressIndicator(color: Colors.green[600])),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 120,
                        width: 120,
                        child: Center(child: Icon(Icons.error, color: Colors.red, size: 40)),
                      ),
                      fit: BoxFit.cover,
                    )
                  : Container( // Placeholder si la URL no es válida o está vacía
                      height: 120,
                      width: 120,
                      child: Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40)),
                    ),
            ),
            Text(plant['name'] ?? 'No Name', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(plant['price']?.toString() ?? '\$0.0', textAlign: TextAlign.left),
          ],
        ),
      ),
    );
  }
}
