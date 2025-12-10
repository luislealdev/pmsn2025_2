import 'package:flutter/material.dart';
import 'package:pmsn2025_2/services/storage_preferences_service.dart';

class StorageModeSelector extends StatefulWidget {
  final bool showAsDialog;
  
  const StorageModeSelector({super.key, this.showAsDialog = false});

  @override
  State<StorageModeSelector> createState() => _StorageModeSelectorState();
}

class _StorageModeSelectorState extends State<StorageModeSelector> {
  final StoragePreferencesService _storagePrefs = StoragePreferencesService();

  @override
  Widget build(BuildContext context) {
    if (widget.showAsDialog) {
      return _buildDialog();
    } else {
      return _buildCard();
    }
  }

  Widget _buildDialog() {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.storage, color: Colors.green[600]),
          SizedBox(width: 8),
          Text("Seleccionar Almacenamiento"),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "¿Dónde quieres guardar los datos?",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          _buildModeOptions(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cerrar"),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage, color: Colors.green[600]),
              SizedBox(width: 8),
              Text(
                "Modo de Almacenamiento",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          StreamBuilder<StorageMode>(
            stream: _storagePrefs.modeStream,
            initialData: _storagePrefs.currentMode,
            builder: (context, snapshot) {
              return Text(
                "Actual: ${_storagePrefs.modeDisplayName}",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              );
            },
          ),
          SizedBox(height: 16),
          _buildModeOptions(),
        ],
      ),
    );
  }

  Widget _buildModeOptions() {
    return StreamBuilder<StorageMode>(
      stream: _storagePrefs.modeStream,
      initialData: _storagePrefs.currentMode,
      builder: (context, snapshot) {
        final currentMode = snapshot.data ?? StorageMode.firebase;
        
        return Column(
          children: [
            // Opción Firebase
            Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: currentMode == StorageMode.firebase 
                      ? Colors.green[600]! 
                      : Colors.grey[300]!,
                  width: currentMode == StorageMode.firebase ? 2 : 1,
                ),
                color: currentMode == StorageMode.firebase 
                    ? Colors.green[50] 
                    : Colors.grey[50],
              ),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.cloud, color: Colors.blue[600]),
                ),
                title: Text(
                  "Firebase (Nube)",
                  style: TextStyle(
                    fontWeight: currentMode == StorageMode.firebase 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  "Sincronizado en la nube\nAccesible desde cualquier dispositivo",
                  style: TextStyle(fontSize: 12),
                ),
                trailing: currentMode == StorageMode.firebase 
                    ? Icon(Icons.check_circle, color: Colors.green[600])
                    : Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
                onTap: () {
                  _storagePrefs.setStorageMode(StorageMode.firebase);
                  _showModeChangedSnackbar("Firebase (Nube)");
                },
              ),
            ),

            // Opción Local
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: currentMode == StorageMode.local 
                      ? Colors.green[600]! 
                      : Colors.grey[300]!,
                  width: currentMode == StorageMode.local ? 2 : 1,
                ),
                color: currentMode == StorageMode.local 
                    ? Colors.green[50] 
                    : Colors.grey[50],
              ),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.phone_android, color: Colors.orange[600]),
                ),
                title: Text(
                  "Dispositivo (SQLite)",
                  style: TextStyle(
                    fontWeight: currentMode == StorageMode.local 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  "Almacenado localmente\nFunciona sin conexión a internet",
                  style: TextStyle(fontSize: 12),
                ),
                trailing: currentMode == StorageMode.local 
                    ? Icon(Icons.check_circle, color: Colors.green[600])
                    : Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
                onTap: () {
                  _storagePrefs.setStorageMode(StorageMode.local);
                  _showModeChangedSnackbar("Dispositivo (SQLite)");
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showModeChangedSnackbar(String modeName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Modo cambiado a: $modeName"),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// Widget simple para mostrar solo el modo actual
class CurrentStorageModeIndicator extends StatelessWidget {
  final bool showIcon;
  
  const CurrentStorageModeIndicator({super.key, this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    final StoragePreferencesService storagePrefs = StoragePreferencesService();
    
    return StreamBuilder<StorageMode>(
      stream: storagePrefs.modeStream,
      initialData: storagePrefs.currentMode,
      builder: (context, snapshot) {
        final mode = snapshot.data ?? StorageMode.firebase;
        final isLocal = mode == StorageMode.local;
        
        if (!showIcon) {
          // Versión ultra compacta solo texto
          return Text(
            isLocal ? "Local" : "Cloud",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isLocal ? Colors.orange[600] : Colors.blue[600],
            ),
          );
        }
        
        // Versión compacta con ícono
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isLocal ? Colors.orange[50] : Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isLocal ? Colors.orange[200]! : Colors.blue[200]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLocal ? Icons.phone_android : Icons.cloud,
                size: 12,
                color: isLocal ? Colors.orange[600] : Colors.blue[600],
              ),
              SizedBox(width: 2),
              Text(
                isLocal ? "Local" : "Cloud",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isLocal ? Colors.orange[600] : Colors.blue[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}