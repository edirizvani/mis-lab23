import 'package:flutter/material.dart';
import '../models/meal.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;

  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const MealCard({
    Key? key,
    required this.meal,
    required this.onTap,
    required this.isFavorite,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      image: DecorationImage(
                        image: NetworkImage(meal.strMealThumb),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      meal.strMeal,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              top: 6,
              right: 6,
              child: Material(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(24),
                child: IconButton(
                  onPressed: onToggleFavorite,
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                  color: isFavorite ? Colors.redAccent : Colors.white,
                  tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}