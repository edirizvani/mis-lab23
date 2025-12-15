import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/favorite_meal.dart';
import '../models/meal.dart';
import '../services/favorites_service.dart';

class FavoritesNotifier extends ChangeNotifier {
  final FavoritesService _service;

  StreamSubscription? _subIds;
  StreamSubscription? _subList;

  Set<String> _ids = {};
  List<FavoriteMeal> _favorites = [];

  FavoritesNotifier(this._service) {
    _subIds = _service.streamFavoriteIds().listen((ids) {
      _ids = ids;
      notifyListeners();
    });

    _subList = _service.streamFavorites().listen((list) {
      _favorites = list;
      notifyListeners();
    });
  }

  bool isFavorite(String mealId) => _ids.contains(mealId);
  List<FavoriteMeal> get favorites => _favorites;

  Future<void> toggle(Meal meal) async {
    final makeFavorite = !isFavorite(meal.idMeal);
    await _service.toggleFavoriteFromMeal(meal, makeFavorite: makeFavorite);
  }

  @override
  void dispose() {
    _subIds?.cancel();
    _subList?.cancel();
    super.dispose();
  }
}