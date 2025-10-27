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
    // Get cart items


    // Get items info
    return cartCollection!.snapshots();
  }
}
