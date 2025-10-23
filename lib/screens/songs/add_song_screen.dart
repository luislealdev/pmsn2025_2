import 'package:flutter/material.dart';
import 'package:pmsn2025_2/firebase/songs_firebase.dart';

class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key});

  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  SongsFirebase? songsFirebase;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores para los campos de texto
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _coverController = TextEditingController();
  final TextEditingController _lyricsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    songsFirebase = SongsFirebase();
  }

  @override
  void dispose() {
    // Limpiar los controladores
    _titleController.dispose();
    _artistController.dispose();
    _durationController.dispose();
    _coverController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }

  Future<void> _addSong() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await songsFirebase!.insertSong({
        "title": _titleController.text.trim(),
        "artist": _artistController.text.trim(),
        "duration": _durationController.text.trim(),
        "cover": _coverController.text.trim().isEmpty 
            ? "https://via.placeholder.com/150x150/FF6B6B/FFFFFF?text=🎵"
            : _coverController.text.trim(),
        "lyrics": _lyricsController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎵 Canción agregada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al agregar canción: $e'),
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
          "🎵 Agregar Canción",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple[600],
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
              // Campo Título
              _buildTextField(
                controller: _titleController,
                label: "Título de la canción",
                icon: Icons.music_note,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Artista
              _buildTextField(
                controller: _artistController,
                label: "Artista",
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el artista';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Duración
              _buildTextField(
                controller: _durationController,
                label: "Duración (ej: 3:45)",
                icon: Icons.access_time,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa la duración';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo URL de portada
              _buildTextField(
                controller: _coverController,
                label: "URL de la portada (opcional)",
                icon: Icons.image,
                validator: null, // Este campo es opcional
              ),
              const SizedBox(height: 16),

              // Campo Letra
              _buildTextField(
                controller: _lyricsController,
                label: "Letra de la canción (opcional)",
                icon: Icons.lyrics_outlined,
                maxLines: 4,
                validator: null, // Este campo es opcional
              ),
              const SizedBox(height: 32),

              // Botón Agregar
              ElevatedButton(
                onPressed: _isLoading ? null : _addSong,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[600],
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
                          Text("Agregando canción..."),
                        ],
                      )
                    : const Text(
                        "🎵 Agregar Canción",
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
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple[600]!, width: 2),
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
