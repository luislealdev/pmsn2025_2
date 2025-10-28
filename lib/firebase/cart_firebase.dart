import 'package:cloud_firestore/cloud_firestore.dart';

class CartFirebase {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference? cartCollection;

  CartFirebase() {
    cartCollection = firestore.collection('cart');
  }

  Future<void> insertCartItem(Map<String, dynamic> cartItem) async {
    await cartCollection!.doc().set(cartItem);
  }

  Future<void> updateCartItem(String uid, Map<String, dynamic> cartItem) async {
    await cartCollection!.doc(uid).update(cartItem);
  }

  Future<void> deleteCartItem(String uid) async {
    await cartCollection!.doc(uid).delete();
  }

  Stream<QuerySnapshot> selectAllCartItems(String userId) {
    // Return only cart items that belong to the given user
    return cartCollection!.where('user_id', isEqualTo: userId).snapshots();
  }

  Future<DocumentSnapshot> selectCartItemById(String uid) async {
    return await cartCollection!.doc(uid).get();
  }
}
