import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/favorite_meal.dart';
import '../models/meal.dart';

class FavoritesService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('favorites');

  Stream<List<FavoriteMeal>> streamFavorites() {
    return _col.snapshots().map((snap) {
      return snap.docs
          .map((d) => FavoriteMeal.fromJson(d.data()))
          .toList();
    });
  }

  Stream<Set<String>> streamFavoriteIds() {
    return _col.snapshots().map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  Future<void> toggleFavoriteFromMeal(Meal meal, {required bool makeFavorite}) async {
    final doc = _col.doc(meal.idMeal);
    if (makeFavorite) {
      await doc.set(FavoriteMeal(
        idMeal: meal.idMeal,
        strMeal: meal.strMeal,
        strMealThumb: meal.strMealThumb,
      ).toJson());
    } else {
      await doc.delete();
    }
  }

  Future<void> removeFavorite(String idMeal) async {
    await _col.doc(idMeal).delete();
  }
}