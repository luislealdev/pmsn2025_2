import 'package:flutter/material.dart';
import 'package:pmsn2025_2/firebase/songs_firebase.dart';
import 'package:pmsn2025_2/widgets/songs_widget.dart';

class ListSongsScreen extends StatefulWidget {
  const ListSongsScreen({super.key});

  @override
  State<ListSongsScreen> createState() => _ListSongsScreenState();
}

class _ListSongsScreenState extends State<ListSongsScreen> {
  SongsFirebase songsFirebase = SongsFirebase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "🎵 Lista de Canciones",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.deepPurple[600],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: songsFirebase.selectAllSongs(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final song = snapshot.data!.docs[index];
                return SongsWidget(song.data() as Map<String, dynamic>);
              },
            );
          } else {
            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            } else {
              return _buildLoadingState();
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-song').then((_) {
            // Refrescar la lista cuando regrese de agregar canción
            setState(() {});
          });
        },
        backgroundColor: Colors.deepPurple[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget _buildSongCard(dynamic song, int index) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     child: Card(
  //       elevation: 4,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       child: ListTile(
  //         contentPadding: const EdgeInsets.all(16),
  //         leading: CircleAvatar(
  //           backgroundColor: Colors.deepPurple[600],
  //           child: Icon(Icons.music_note, color: Colors.white),
  //         ),
  //         title: Text(
  //           song.get("title") ?? "Sin título",
  //           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //         ),
  //         subtitle: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const SizedBox(height: 4),
  //             Text(
  //               song.get("artist") ?? "Artista desconocido",
  //               style: TextStyle(color: Colors.grey[600], fontSize: 14),
  //             ),
  //             const SizedBox(height: 4),
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //               decoration: BoxDecoration(
  //                 color: Colors.deepPurple[50],
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Text(
  //                 song.get("genre") ?? "Género",
  //                 style: TextStyle(
  //                   color: Colors.deepPurple[600],
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         trailing: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Icon(
  //               Icons.play_circle_fill,
  //               color: Colors.deepPurple[600],
  //               size: 32,
  //             ),
  //             const SizedBox(height: 4),
  //             Text(
  //               "#${index + 1}",
  //               style: TextStyle(color: Colors.grey[500], fontSize: 12),
  //             ),
  //           ],
  //         ),
  //         onTap: () {
  //           _showSongDetails(song);
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No hay canciones disponibles",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Agrega algunas canciones para comenzar",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            "Error al cargar canciones",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple[600],
              foregroundColor: Colors.white,
            ),
            child: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
          SizedBox(height: 16),
          Text(
            "Cargando canciones...",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // void _showSongDetails(dynamic song) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         title: Row(
  //           children: [
  //             Icon(Icons.music_note, color: Colors.deepPurple[600]),
  //             const SizedBox(width: 8),
  //             const Text("Detalles de la Canción"),
  //           ],
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             _buildDetailRow("Título", song.get("title") ?? "Sin título"),
  //             _buildDetailRow(
  //               "Artista",
  //               song.get("artist") ?? "Artista desconocido",
  //             ),
  //             _buildDetailRow("Género", song.get("genre") ?? "Sin género"),
  //             _buildDetailRow(
  //               "Duración",
  //               song.get("duration") ?? "Desconocida",
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: Text(
  //               "Cerrar",
  //               style: TextStyle(color: Colors.deepPurple[600]),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Widget _buildDetailRow(String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         SizedBox(
  //           width: 70,
  //           child: Text(
  //             "$label:",
  //             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
  //           ),
  //         ),
  //         Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
  //       ],
  //     ),
  //   );
  // }
}
