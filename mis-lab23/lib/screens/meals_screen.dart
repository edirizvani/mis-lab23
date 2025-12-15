import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal.dart';
import '../state/favorites_notifier.dart';
import '/services/meals_service.dart';
import '../widgets/meal_card.dart';
import '../widgets/loading_widget.dart';
import 'favorites_screen.dart';
import 'meal_detail_screen.dart';

class MealsScreen extends StatefulWidget {
  final String category;

  const MealsScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  List<Meal> meals = [];
  List<Meal> filteredMeals = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadMeals();
  }

  Future<void> loadMeals() async {
    try {
      final loadedMeals = await MealService.getMealsByCategory(widget.category);
      setState(() {
        meals = loadedMeals;
        filteredMeals = loadedMeals;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading meals: $e')),
      );
    }
  }

  Future<void> searchMeals(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredMeals = meals;
        searchQuery = '';
      });
      return;
    }

    setState(() {
      searchQuery = query;
      isLoading = true;
    });

    try {
      final searchResults = await MealService.searchMeals(query);
      // Filter results to only show meals from current category
      final categoryFilteredResults = searchResults.where((meal) {
        return meals.any((categoryMeal) => categoryMeal.idMeal == meal.idMeal);
      }).toList();

      setState(() {
        filteredMeals = categoryFilteredResults;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        filteredMeals = meals.where((meal) =>
            meal.strMeal.toLowerCase().contains(query.toLowerCase())
        ).toList();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Meals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search meals...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: searchMeals,
            ),
          ),
          Expanded(
            child: isLoading
                ? const LoadingWidget()
                : filteredMeals.isEmpty
                ? const Center(
              child: Text('No meals found'),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredMeals.length,
              itemBuilder: (context, index) {
                final meal = filteredMeals[index];
                final fav = context.watch<FavoritesNotifier>();

                return MealCard(
                  meal: meal,
                  isFavorite: fav.isFavorite(meal.idMeal),
                  onToggleFavorite: () async {
                    await context.read<FavoritesNotifier>().toggle(meal);
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealDetailScreen(mealId: meal.idMeal),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}