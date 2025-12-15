import 'dart:convert';
import "package:http/http.dart" as http;
import '../models/category.dart';
import '../models/meal_detail.dart';
import '../models/meal.dart';
import '../models/meal_detail.dart';

class MealService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  static Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> categoriesJson = data['categories'];
        return categoriesJson.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  static Future<List<Meal>> getMealsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filter.php?c=$category')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> mealsJson = data['meals'] ?? [];
        return mealsJson.map((json) => Meal.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load meals');
      }
    } catch (e) {
      throw Exception('Error fetching meals: $e');
    }
  }

  static Future<MealDetail> getMealDetail(String mealId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lookup.php?i=$mealId')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> mealsJson = data['meals'];
        if (mealsJson.isNotEmpty) {
          return MealDetail.fromJson(mealsJson.first);
        } else {
          throw Exception('Meal not found');
        }
      } else {
        throw Exception('Failed to load meal detail');
      }
    } catch (e) {
      throw Exception('Error fetching meal detail: $e');
    }
  }

  static Future<MealDetail> getRandomMeal() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/random.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> mealsJson = data['meals'];
        return MealDetail.fromJson(mealsJson.first);
      } else {
        throw Exception('Failed to load random meal');
      }
    } catch (e) {
      throw Exception('Error fetching random meal: $e');
    }
  }

  static Future<List<Meal>> searchMeals(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search.php?s=$query')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> mealsJson = data['meals'] ?? [];
        return mealsJson.map((json) => Meal.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}