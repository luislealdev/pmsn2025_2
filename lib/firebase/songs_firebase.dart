import 'package:cloud_firestore/cloud_firestore.dart';

class SongsFirebase {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference? songsCollection;

  SongsFirebase() {
    songsCollection = firestore.collection('songs');
  }

  Future<void> insertSong(Map<String, dynamic> song) async {
    await songsCollection!.doc().set(song);
  }

  Future<void> updateSong(String uid, Map<String, dynamic> song) async {
    await songsCollection!.doc(uid).update(song);
  }

  Future<void> deleteSong(String uid) async {
    await songsCollection!.doc(uid).delete();
  }

  Stream<QuerySnapshot> selectAllSongs() {
    return songsCollection!.snapshots();
  }
}
