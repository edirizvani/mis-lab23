class FavoriteMeal {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;

  FavoriteMeal({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
  });

  Map<String, dynamic> toJson() => {
    'idMeal': idMeal,
    'strMeal': strMeal,
    'strMealThumb': strMealThumb,
  };

  factory FavoriteMeal.fromJson(Map<String, dynamic> json) => FavoriteMeal(
    idMeal: (json['idMeal'] ?? '') as String,
    strMeal: (json['strMeal'] ?? '') as String,
    strMealThumb: (json['strMealThumb'] ?? '') as String,
  );
}