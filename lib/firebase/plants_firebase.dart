import 'package:cloud_firestore/cloud_firestore.dart';

class PlantsFirebase {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference? floraCollection;

  PlantsFirebase() {
    floraCollection = firestore.collection('plants');
  }

  Future<void> insertPlant(Map<String, dynamic> plant) async {
    await floraCollection!.doc().set(plant);
  }

  Future<void> updatePlant(String uid, Map<String, dynamic> plant) async {
    await floraCollection!.doc(uid).update(plant);
  }

  Future<void> deletePlant(String uid) async {
    await floraCollection!.doc(uid).delete();
  }

  Stream<QuerySnapshot> selectAllPlants() {
    return floraCollection!.snapshots();
  }
}
