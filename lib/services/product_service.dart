import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final CollectionReference products = FirebaseFirestore.instance.collection('products');

  Future<void> addProduct(Product product) async {
    await products.doc(product.id).set(product.toMap());
  }
}
