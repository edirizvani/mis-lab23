import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/favorites_notifier.dart';
import 'meal_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesNotifier>().favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Омилени рецепти')),
      body: favorites.isEmpty
          ? const Center(child: Text('Немате омилени рецепти.'))
          : ListView.separated(
        itemCount: favorites.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final m = favorites[i];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(m.strMealThumb, width: 56, height: 56, fit: BoxFit.cover),
            ),
            title: Text(m.strMeal),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MealDetailScreen(mealId: m.idMeal)),
              );
            },
          );
        },
      ),
    );
  }
}