import 'package:flutter/material.dart';

class IoTDeviceDetailsScreen extends StatefulWidget {
  final String deviceName;
  final String deviceType;
  final IconData deviceIcon;
  final Color deviceColor;
  final String deviceValue;

  const IoTDeviceDetailsScreen({
    super.key,
    required this.deviceName,
    required this.deviceType,
    required this.deviceIcon,
    required this.deviceColor,
    required this.deviceValue,
  });

  @override
  State<IoTDeviceDetailsScreen> createState() => _IoTDeviceDetailsScreenState();
}

class _IoTDeviceDetailsScreenState extends State<IoTDeviceDetailsScreen> {
  bool isDeviceActive = true;
  double sliderValue = 75.0;
  final ScrollController _scrollController = ScrollController();
  final double appBarHeight = 100.0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: widget.deviceColor,
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.deviceColor,
                  widget.deviceColor.withOpacity(0.8),
                  widget.deviceColor.withOpacity(0.6),
                ],
              ),
            ),
          ),
          
          // Contenido principal
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.only(top: appBarHeight),
            children: [
              // Imagen/Icono del dispositivo
              _HeroDetailsImage(widget.deviceIcon, widget.deviceColor),
              
              // Nombre del dispositivo
              _HeroDetailsName(widget.deviceName),
              
              // Descripción
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12),
                child: Text(
                  "Dispositivo inteligente para el hogar conectado. Controla y monitorea tu ${widget.deviceType.toLowerCase()} desde cualquier lugar con funciones avanzadas de automatización y eficiencia energética.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              SizedBox(height: 28),
              
              // Botones de acción
              Row(
                children: [
                  SizedBox(width: 28),
                  Expanded(
                    child: Container(
                      height: 54,
                      child: OutlinedButton(
                        child: Text(
                          'Agregar a Favoritos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.white,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0),
                          ),
                        ),
                        child: Ink(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFF29758),
                                Color(0xFFEF5D67),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(80.0)),
                          ),
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0),
                            alignment: Alignment.center,
                            child: const Text(
                              'Controlar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 28),
                ],
              ),
              
              SizedBox(height: 28),
              
              // Card de información del dispositivo
              _buildInfoCard(isDarkMode),
              
              SizedBox(height: 20),
              
              // Card de controles
              _buildControlsCard(isDarkMode),
              
              SizedBox(height: 20),
              
              // Card de estadísticas
              _buildStatsCard(isDarkMode),
              
              SizedBox(height: 100),
            ],
          ),
          
          // AppBar personalizada
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: appBarHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    widget.deviceColor,
                    widget.deviceColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Detalles',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {},
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

  Widget _HeroDetailsImage(IconData icon, Color color) {
    return Hero(
      tag: '${widget.deviceName}_icon',
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 80,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _HeroDetailsName(String name) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      child: Text(
        name,
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildInfoCard(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del Dispositivo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    isDeviceActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Valor Actual',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    widget.deviceValue,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlsCard(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Control de Dispositivo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Switch(
                value: isDeviceActive,
                onChanged: (value) {
                  setState(() {
                    isDeviceActive = value;
                  });
                },
                activeColor: Colors.white,
                activeTrackColor: Colors.white.withOpacity(0.3),
                inactiveThumbColor: Colors.grey[400],
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Intensidad: ${sliderValue.toInt()}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.2),
              trackHeight: 6,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: sliderValue,
              min: 0,
              max: 100,
              divisions: 10,
              onChanged: (value) {
                setState(() {
                  sliderValue = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas de Uso',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 15),
          _buildStatRow('Tiempo activo hoy', '8h 32m', Icons.access_time),
          SizedBox(height: 12),
          _buildStatRow('Consumo energético', '1.2 kWh', Icons.flash_on),
          SizedBox(height: 12),
          _buildStatRow('Última actividad', 'Hace 5 min', Icons.update),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.white,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
