import 'package:flutter/material.dart';
import 'package:pmsn2025_2/services/storage_preferences_service.dart';
import 'package:pmsn2025_2/widgets/storage_mode_selector.dart';

class StorageSettingsScreen extends StatelessWidget {
  const StorageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "⚙️ Configuración de Almacenamiento",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            
            // Información actual
            _buildCurrentModeInfo(),
            
            SizedBox(height: 20),
            
            // Selector de modo
            StorageModeSelector(),
            
            SizedBox(height: 20),
            
            // Información adicional
            _buildInfoCard(),
            
            SizedBox(height: 20),
            
            // Botones de acción (para futuras funcionalidades)
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentModeInfo() {
    final StoragePreferencesService storagePrefs = StoragePreferencesService();
    
    return StreamBuilder<StorageMode>(
      stream: storagePrefs.modeStream,
      initialData: storagePrefs.currentMode,
      builder: (context, snapshot) {
        final mode = snapshot.data ?? StorageMode.firebase;
        final isLocal = mode == StorageMode.local;
        
        return Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLocal 
                  ? [Colors.orange[400]!, Colors.orange[600]!]
                  : [Colors.blue[400]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
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
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isLocal ? Icons.phone_android : Icons.cloud,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Modo Actual",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      isLocal ? "Dispositivo Local" : "Firebase Cloud",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isLocal 
                          ? "Datos guardados en SQLite local"
                          : "Datos sincronizados en la nube",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600]),
              SizedBox(width: 8),
              Text(
                "Información Importante",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildInfoItem(
            "📱 Modo Local (SQLite)",
            "Los datos se guardan solo en tu dispositivo. No necesitas internet, pero los datos no se sincronizan entre dispositivos.",
          ),
          SizedBox(height: 8),
          _buildInfoItem(
            "☁️ Modo Firebase (Nube)",
            "Los datos se guardan en la nube de Firebase. Requiere conexión a internet, pero se sincronizan automáticamente.",
          ),
          SizedBox(height: 8),
          _buildInfoItem(
            "🔄 Cambio de Modo",
            "Al cambiar de modo, solo verás los datos del modo actual. Los datos del modo anterior se mantienen pero no son visibles.",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("🚧 Funcionalidad de sincronización en desarrollo"),
                    backgroundColor: Colors.orange[600],
                  ),
                );
              },
              icon: Icon(Icons.sync),
              label: Text("Sincronizar Datos Manualmente"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
              label: Text("Volver al Inicio"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green[600],
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}