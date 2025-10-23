import 'package:flutter/material.dart';
import 'package:pmsn2025_2/firebase/plants_firebase.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  PlantsFirebase? plantsFirebase;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores para los campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _careInstructionsController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    plantsFirebase = PlantsFirebase();
  }

  @override
  void dispose() {
    // Limpiar los controladores
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    _careInstructionsController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _addPlant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await plantsFirebase!.insertPlant({
        "name": _nameController.text.trim(),
        "price": double.tryParse(_priceController.text.trim()) ?? 0.0,
        "image": _imageController.text.trim().isEmpty 
            ? "https://via.placeholder.com/300x300/4CAF50/FFFFFF?text=🌱"
            : _imageController.text.trim(),
        "description": _descriptionController.text.trim(),
        "care_instructions": _careInstructionsController.text.trim(),
        "category": _categoryController.text.trim(),
        "rating": 4.5, // Rating por defecto
        "reviews": 0, // Reseñas iniciales
        "created_at": DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🌱 Planta agregada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al agregar planta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "🌱 Agregar Planta",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo Nombre
              _buildTextField(
                controller: _nameController,
                label: "Nombre de la planta",
                icon: Icons.local_florist,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Precio
              _buildTextField(
                controller: _priceController,
                label: "Precio (USD)",
                icon: Icons.attach_money,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el precio';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Por favor ingresa un precio válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Categoría
              _buildTextField(
                controller: _categoryController,
                label: "Categoría (ej: Interior, Exterior)",
                icon: Icons.category,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa la categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo URL de imagen
              _buildTextField(
                controller: _imageController,
                label: "URL de la imagen (opcional)",
                icon: Icons.image,
                validator: null, // Este campo es opcional
              ),
              const SizedBox(height: 16),

              // Campo Descripción
              _buildTextField(
                controller: _descriptionController,
                label: "Descripción de la planta",
                icon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Instrucciones de cuidado
              _buildTextField(
                controller: _careInstructionsController,
                label: "Instrucciones de cuidado",
                icon: Icons.eco,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa las instrucciones de cuidado';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón Agregar
              ElevatedButton(
                onPressed: _isLoading ? null : _addPlant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text("Agregando planta..."),
                        ],
                      )
                    : const Text(
                        "🌱 Agregar Planta",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[600]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      maxLines: maxLines,
      validator: validator,
    );
  }
}