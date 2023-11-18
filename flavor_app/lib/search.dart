import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'favoriteProvider.dart';
import 'postprovider.dart';
import 'post.dart';
import 'recipeDetails.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const SearchPages(),
    );
  }
}

class SearchPages extends StatefulWidget {
  const SearchPages({super.key});

  @override
  State<SearchPages> createState() => _SearchPagesState();
}

class _SearchPagesState extends State<SearchPages> {
  final TextEditingController minutesToCookController = TextEditingController();
  final List<TextEditingController> ingredientPreferenceControllers = List.generate(4, (_) => TextEditingController());
  List recipeList = [];

  /*
  // this is the like button
  _like(var post) {
    final favs = Provider.of<FavoritesProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: FavoriteButton(
        iconColor: Colors.pinkAccent.shade400,
        iconSize: 35.5,
        isFavorite: post.isFavorite,
        valueChanged: (fav) {
          post.isFavorite = fav;
          if (fav) {
            post.canAdd = false;
          }
          favs.addFav(post);
          print(favs.recipes.length);
        },
      ),
    );
  }
*/
  @override
  void initState() {
    super.initState();
  }

  void filterRecipes() {
    final int minutesToCook = int.tryParse(minutesToCookController.text) ?? 0;
    final List<String> ingredientPreferences = ingredientPreferenceControllers
        .map((controller) => controller.text.toLowerCase())
        .where((ingredient) => ingredient.isNotEmpty)
        .toList();
    print('USER MINUTES $minutesToCook');
    print('USER PREFERENCES $ingredientPreferences');

    var dbF = Provider.of<FirebaseFirestore>(context, listen:false);
    dbF.collection('recipes').get().then((querySnapshot) {
      final suggestions = querySnapshot.docs
          .where((recipeDoc) {
        final recipe = recipeDoc.data();
        // print(recipe);for debugging
        final recipeCookingTime = recipe['minutes'];
        //print(recipeCookingTime);
        final recipeIngredients = List<String>.from(recipe['ingredients'])
            .map((ingredient) => ingredient.toLowerCase())
            .toSet();
        //print(recipeIngredients);

        final meetsCookingTime = recipeCookingTime <= minutesToCook;
        //print("Meets cooking time! $meetsCookingTime");
        final hasMatchingIngredients = ingredientPreferences.any((ingredient) => recipeIngredients.contains(ingredient));
        print("has Matching ingredients $hasMatchingIngredients");
        return meetsCookingTime && hasMatchingIngredients;
      })
          .toList();

      print('Filtered Recipes: $suggestions');
      //updates the list with the filtered recipes
      setState(() {
        recipeList = suggestions;
        print(recipeList);
      });
    });
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 35,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: minutesToCookController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Minutes to Cook',
                      ),
                    ),
                  ),
                  for (int i = 0; i < 1; i++)
                    Expanded(
                      child: TextFormField(
                        controller: ingredientPreferenceControllers[i],
                        decoration: InputDecoration(
                          hintText: 'Ingredient Preference ${i + 1}',
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: filterRecipes,
              child: Text('Filter Recipes'),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: recipeList.length,
                itemBuilder: (context, index) {
                  final r = recipeList[index];
                  return ListTile(
                    leading: Image.network(
                      r['image'],
                      fit: BoxFit.cover,
                    ),
                    title: Text(r['recipeName']),
                    //trailing: _like(r),
                      onTap: () {
                        // Navigate to the Recipe Details screen when tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => recipeDetails(r.data()),
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