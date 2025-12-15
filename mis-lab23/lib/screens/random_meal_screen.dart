import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_detail.dart';
import '/services/meals_service.dart';
import '../widgets/loading_widget.dart';

class RandomMealScreen extends StatefulWidget {
  const RandomMealScreen({Key? key}) : super(key: key);

  @override
  State<RandomMealScreen> createState() => _RandomMealScreenState();
}

class _RandomMealScreenState extends State<RandomMealScreen> {
  MealDetail? randomMeal;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRandomMeal();
  }

  Future<void> loadRandomMeal() async {
    setState(() {
      isLoading = true;
    });

    try {
      final meal = await MealService.getRandomMeal();
      setState(() {
        randomMeal = meal;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading random meal: $e')),
      );
    }
  }

  Future<void> _launchYouTube(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch YouTube video')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Recipe of the Day'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadRandomMeal,
          ),
        ],
      ),
      body: isLoading
          ? const LoadingWidget()
          : randomMeal == null
          ? const Center(child: Text('Failed to load random recipe'))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(randomMeal!.strMealThumb),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and category
                  Text(
                    randomMeal!.strMeal,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text(randomMeal!.strCategory),
                        backgroundColor: Colors.orange.shade100,
                      ),
                      const SizedBox(width: 8),
                      if (randomMeal!.strArea.isNotEmpty)
                        Chip(
                          label: Text(randomMeal!.strArea),
                          backgroundColor: Colors.blue.shade100,
                        ),
                    ],
                  ),

                  // YouTube button
                  if (randomMeal!.strYoutube.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton.icon(
                        onPressed: () => _launchYouTube(randomMeal!.strYoutube),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Watch on YouTube'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                  // Ingredients
                  const Text(
                    'Ingredients:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    randomMeal!.ingredients.length,
                        (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(
                            child: Text(
                              '${randomMeal!.measures[index]} ${randomMeal!.ingredients[index]}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Instructions
                  const Text(
                    'Instructions:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    randomMeal!.strInstructions,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}