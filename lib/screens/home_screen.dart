import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:pmsn2025_2/utils/value_listener.dart';
import 'package:pmsn2025_2/widgets/attribute_widget.dart';
import 'package:pmsn2025_2/screens/iot_device_details_screen.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late int currentPage;
  late TabController tabController;
  double rotationY = 0.0; // Variable para controlar la rotación

  final List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
  ];

  @override
  void initState() {
    currentPage = 0;
    tabController = TabController(length: 5, vsync: this);
    tabController.animation!.addListener(() {
      final value = tabController.animation!.value.round();
      if (value != currentPage && mounted) {
        changePage(value);
      }
    });
    super.initState();
  }

  void changePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color unselectedColor = colors[currentPage].computeLuminance() < 0.5
        ? Colors.white
        : Colors.black;

    // Color más visible para los íconos no seleccionados en el bottom bar
    final Color unselectedIconColor = Colors.grey[600]!;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Luis Leal'),
              accountEmail: Text('luisrrleal@gmail.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.movie, color: Colors.blue[600]),
              title: Text('List Movies'),
              subtitle: Text('Database Movies'),
              trailing: Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, "/listdb"),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.add_box, color: Colors.green[600]),
              title: Text('Add Movie'),
              subtitle: Text('Agregar nueva película'),
              trailing: Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, "/add"),
            ),
            ListTile(
              leading: Icon(Icons.music_note, color: Colors.purple[600]),
              title: Text('Songs'),
              subtitle: Text('Lista de canciones Firebase'),
              trailing: Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, "/songs"),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.music_note, color: Colors.purple[600]),
              title: Text('Movies'),
              subtitle: Text('Movies desde api'),
              trailing: Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, "/api-movies"),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.nature, color: Colors.green[700]),
              title: Text('Flora App'),
              subtitle: Text('Tienda de plantas'),
              trailing: Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, "/flora"),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('GoogleApp'),
        backgroundColor: colors[currentPage],
        foregroundColor: unselectedColor,
        elevation: 0,
        actions: [
          ValueListenableBuilder(
            valueListenable: ValueListener.isDark,
            builder: (context, value, _) {
              return value
                  ? IconButton(
                      icon: Icon(Icons.wb_sunny),
                      onPressed: () {
                        ValueListener.isDark.value = false;
                      },
                    )
                  : IconButton(
                      icon: Icon(Icons.nightlight),
                      onPressed: () {
                        ValueListener.isDark.value = true;
                      },
                    );
            },
          ),
        ],
        // leading: Container(),
      ),
      body: BottomBar(
        fit: StackFit.expand,
        icon: (width, height) => Center(
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: null,
            icon: Icon(
              Icons.arrow_upward_rounded,
              color: unselectedColor,
              size: width,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(500),
        duration: Duration(seconds: 1),
        curve: Curves.decelerate,
        showIcon: true,
        width: MediaQuery.of(context).size.width * 0.8,
        barColor: colors[currentPage].computeLuminance() > 0.5
            ? Colors.black
            : Colors.white,
        start: 2,
        end: 0,
        offset: 10,
        barAlignment: Alignment.bottomCenter,
        iconHeight: 35,
        iconWidth: 35,
        reverse: false,
        hideOnScroll: true,
        scrollOpposite: false,
        respectSafeArea: true,
        onBottomBarHidden: () {},
        onBottomBarShown: () {},
        body: (context, controller) => TabBarView(
          controller: tabController,
          dragStartBehavior: DragStartBehavior.down,
          physics: const BouncingScrollPhysics(),
          children: [
            _buildPageContent(controller, 0, "Inicio", Icons.home),
            _buildPageContent(controller, 1, "Buscar", Icons.search),
            _buildIoTDevicesPage(
              controller,
            ), // Página IoT para dispositivos del hogar
            _buildFavoritesPage(controller), // Página especial para Favoritos
            _buildPageContent(controller, 4, "Configuración", Icons.settings),
          ],
        ),
        child: TabBar(
          indicatorPadding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
          controller: tabController,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: colors[currentPage], width: 4),
            insets: EdgeInsets.fromLTRB(16, 0, 16, 8),
          ),
          tabs: [
            SizedBox(
              height: 55,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.home,
                  color: currentPage == 0 ? colors[0] : unselectedIconColor,
                ),
              ),
            ),
            SizedBox(
              height: 55,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.search,
                  color: currentPage == 1 ? colors[1] : unselectedIconColor,
                ),
              ),
            ),
            SizedBox(
              height: 55,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.add,
                  color: currentPage == 2 ? colors[2] : unselectedIconColor,
                ),
              ),
            ),
            SizedBox(
              height: 55,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.favorite,
                  color: currentPage == 3 ? colors[3] : unselectedIconColor,
                ),
              ),
            ),
            SizedBox(
              height: 55,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.settings,
                  color: currentPage == 4 ? colors[4] : unselectedIconColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Página especial para dispositivos IoT del hogar
  Widget _buildIoTDevicesPage(ScrollController controller) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
                  colors[2].withOpacity(0.2),
                  colors[2].withOpacity(0.1),
                  Colors.grey[900]!.withOpacity(0.8),
                ]
              : [
                  colors[2].withOpacity(0.3),
                  colors[2].withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: ListView(
        controller: controller,
        padding: EdgeInsets.all(16),
        children: [
          // Encabezado
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(Icons.home_outlined, size: 60, color: colors[2]),
                SizedBox(height: 10),
                Text(
                  'Casa Inteligente',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors[2],
                  ),
                ),
                Text(
                  'Controla tus dispositivos IoT',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Contenedor centrado para las tarjetas
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 400,
              ), // Ancho máximo para centrar
              child: Column(
                children: [
                  // Dispositivo 1: Termostato
                  _buildIoTDeviceCard(
                    title: 'Termostato Inteligente',
                    subtitle: 'Control de Temperatura',
                    value: '24°C',
                    progress: 78,
                    icon: Icons.thermostat,
                    color: Colors.orange,
                    isActive: true,
                    onDetailsPressed: () => _navigateToDeviceDetails(
                      'Termostato Inteligente',
                      'Sistema de Climatización',
                      Icons.thermostat,
                      Colors.orange,
                      '24°C',
                    ),
                  ),

                  SizedBox(height: 20),

                  // Dispositivo 2: Iluminación
                  _buildIoTDeviceCard(
                    title: 'Sistema de Iluminación',
                    subtitle: 'Control de Luces',
                    value: '85%',
                    progress: 85,
                    icon: Icons.lightbulb,
                    color: Colors.amber,
                    isActive: true,
                    onDetailsPressed: () => _navigateToDeviceDetails(
                      'Sistema de Iluminación',
                      'Control de Luces Inteligentes',
                      Icons.lightbulb,
                      Colors.amber,
                      '85% Intensidad',
                    ),
                  ),

                  SizedBox(height: 20),

                  // Dispositivo 3: Seguridad
                  _buildIoTDeviceCard(
                    title: 'Sistema de Seguridad',
                    subtitle: 'Alarma y Monitoreo',
                    value: 'ACTIVO',
                    progress: 95,
                    icon: Icons.security,
                    color: Colors.red,
                    isActive: true,
                    onDetailsPressed: () => _navigateToDeviceDetails(
                      'Sistema de Seguridad',
                      'Alarma y Cámaras de Seguridad',
                      Icons.security,
                      Colors.red,
                      'Estado Activo',
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 100), // Espacio para el bottom bar
        ],
      ),
    );
  }

  Widget _buildIoTDeviceCard({
    required String title,
    required String subtitle,
    required String value,
    required double progress,
    required IconData icon,
    required Color color,
    required bool isActive,
    required VoidCallback onDetailsPressed,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDarkMode ? Colors.white : Colors.grey[800];
    final subtitleColor = isDarkMode ? Colors.grey[300] : Colors.grey[600];

    return Transform(
      alignment: FractionalOffset.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.01)
        ..rotateY(2 * pi / 180),
      child: Container(
        height: 180,
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                    Colors.grey[800]!.withOpacity(0.3),
                  ]
                : [
                    color.withOpacity(0.1),
                    color.withOpacity(0.05),
                    Colors.white.withOpacity(0.1),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              // Lado izquierdo - Icono principal
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [color.withOpacity(0.8), color.withOpacity(0.5)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 35),
              ),

              SizedBox(width: 20),

              // Centro - Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: subtitleColor),
                    ),
                    SizedBox(height: 8),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Switch(
                          value: isActive,
                          onChanged: (bool newValue) {
                            setState(() {
                              // Aquí puedes manejar el cambio de estado
                            });
                          },
                          activeColor: color,
                          activeTrackColor: color.withOpacity(0.3),
                          inactiveThumbColor: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey,
                          inactiveTrackColor: isDarkMode
                              ? Colors.grey[700]
                              : Colors.grey.withOpacity(0.3),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: onDetailsPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                            'Ver más',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Lado derecho - Indicador de progreso
              Container(
                width: 60,
                child: AttributeWidget(
                  progress: progress,
                  size: 60,
                  child: Text(
                    '${progress.toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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

  void _navigateToDeviceDetails(
    String name,
    String type,
    IconData icon,
    Color color,
    String value,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IoTDeviceDetailsScreen(
          deviceName: name,
          deviceType: type,
          deviceIcon: icon,
          deviceColor: color,
          deviceValue: value,
        ),
      ),
    );
  }

  // Página especial para Favoritos con transformaciones 3D
  Widget _buildFavoritesPage(ScrollController controller) {
    final double rowHeight = 220.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors[3], colors[4], Colors.white],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: ListView(
        controller: controller,
        padding: EdgeInsets.all(16),
        children: [
          SizedBox(height: 40),

          // Nuevo componente Stack
          Container(
            height: rowHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: Offset(-10, 0),
                  child: Transform(
                    alignment: FractionalOffset.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.01)
                      ..rotateY(1.5 * pi / 180),
                    child: Container(
                      height: 216,
                      margin: EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.all(Radius.circular(22)),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(-44, 0),
                  child: Transform(
                    alignment: FractionalOffset.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.01)
                      ..rotateY(8 * pi / 180),
                    child: Container(
                      height: 188,
                      margin: EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.all(Radius.circular(22)),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Transform.translate(
                    offset: Offset(-30, 0),
                    child: Container(
                      child: Image.network(
                        'https://flutter4fun.com/wp-content/uploads/2020/11/Player-1.png',
                        width: rowHeight,
                        height: rowHeight,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: EdgeInsets.only(right: 58),
                    // padding: EdgeInsets.symmetric(vertical: 34),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AttributeWidget(
                          progress: 75,
                          child: Image.network(
                            'https://flutter4fun.com/wp-content/uploads/2020/11/speed.png',
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.speed,
                                color: Colors.white,
                                size: 20,
                              );
                            },
                          ),
                        ),
                        AttributeWidget(
                          progress: 60,
                          child: Image.network(
                            'https://flutter4fun.com/wp-content/uploads/2020/11/heart.png',
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 20,
                              );
                            },
                          ),
                        ),
                        AttributeWidget(
                          progress: 85,
                          child: Image.network(
                            'https://flutter4fun.com/wp-content/uploads/2020/11/knife.png',
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.flash_on,
                                color: Colors.white,
                                size: 20,
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 32,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: Text(
                              'See Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(
    ScrollController controller,
    int index,
    String title,
    IconData icon,
  ) {
    return Container(
      color: colors[index].withOpacity(0.1),
      child: ListView.builder(
        controller: controller,
        itemCount: 20,
        padding: EdgeInsets.all(16),
        itemBuilder: (context, itemIndex) {
          if (itemIndex == 0) {
            return Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Icon(icon, size: 80, color: colors[index]),
                  SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colors[index],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bienvenido a la sección de $title',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  Divider(height: 40),
                ],
              ),
            );
          }

          return Card(
            margin: EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colors[index],
                child: Text(
                  '${itemIndex}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text('Elemento $itemIndex'),
              subtitle: Text('Descripción del elemento en $title'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: colors[index],
                size: 16,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Seleccionaste el elemento $itemIndex en $title',
                    ),
                    backgroundColor: colors[index],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
