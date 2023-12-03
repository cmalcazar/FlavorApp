import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flavor_app/post.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'recipe.dart';
import 'favoriteProvider.dart';
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
  final List<TextEditingController> ingredientPreferenceControllers =
  List.generate(4, (_) => TextEditingController());
  List recipeList = [];
  String ifnull =
      'https://firebasestorage.googleapis.com/v0/b/recipeapp-3ab43.appspot.com/o/images%2F1000_F_251955356_FAQH0U1y1TZw3ZcdPGybwUkH90a3VAhb.jpg?alt=media&token=091b00f6-a4a8-4a4a-b66f-60e8978fb471&_gl=1*1dfhnga*_ga*MTM5MTUxODI4My4xNjk4NTE4MjUw*_ga_CW55HF8NVT*MTY5OTM1MTA4OS40MS4xLjE2OTkzNTQ2MzMuMTAuMC4w';

  @override
  initState() {
    super.initState();
    //addPost();
  }

  // addPost() {
  //   final auth = Provider.of<FirebaseAuth>(context, listen: false);
  //   final db = Provider.of<FirebaseFirestore>(context, listen: false);
  //   for (int i = 0; i < 201; i++) {
  //     db
  //         .collection('recipes')
  //         .doc(i.toString())
  //         .update({'posterID': auth.currentUser!.uid});
  //   }
  // }

  //this is the like button
  _like(var post) {
    final favs = Provider.of<FavoritesProvider>(context, listen: false);
    final db = Provider.of<FirebaseFirestore>(context);
    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: FavoriteButton(
        iconColor: Colors.pinkAccent.shade400,
        iconSize: 35.5,
        isFavorite: post['isFavorite'],
        valueChanged: (fav) async {
          Map<String, dynamic> updatedPost =
          Map<String, dynamic>.from(post.data());
          updatedPost['isFavorite'] = fav;
          if (fav) {
            updatedPost['canAdd'] = false;
          }
          var temp = convertToPost(updatedPost);
          favs.addFav(temp);
          List<Map<String, dynamic>> jsonList =
          favs.recipes.map((item) => item.posts.toJson()).toList();
          var authUser = auth.currentUser;
          await db
              .collection('users')
              .doc(authUser!.uid)
              .update({'favorites': jsonList});
        },
      ),
    );
  }

  convertToPost(post) {
    Recipe tempRecipe = Recipe(
      recipeId: post['recipeID'],
      recipeName: post['recipeName'],
      description: post['description'],
      image: post['image'],
      ingredients: List<String>.from(post['ingredients']),
      steps: List<String>.from(post['steps']),
      minutes: post['minutes'],
      isFavorite: post['isFavorite'],
      canAdd: post['canAdd'],
      nutrition: List<double>.from(post['nutrition']),
      tags: List<String>.from(post['tags']),
    );
    var tempPost = Post(posterID: post['posterID'], posts: tempRecipe);
    return tempPost;
  }

  void filterRecipes() {
    final int minutesToCook = int.tryParse(minutesToCookController.text) ?? 0;
    final List<String> ingredientPreferences = ingredientPreferenceControllers
        .map((controller) => controller.text.toLowerCase())
        .where((ingredient) => ingredient.isNotEmpty)
        .toList();
    print('USER MINUTES $minutesToCook');
    print('USER PREFERENCES $ingredientPreferences');

    var dbF = Provider.of<FirebaseFirestore>(context, listen: false);
    dbF.collection('recipes').get().then((querySnapshot) {
      final suggestions = querySnapshot.docs.where((recipeDoc) {
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
        final hasMatchingIngredients = ingredientPreferences.every(
                (ingredient) => recipeIngredients
                .contains(ingredient)); //every ingredient must match
        print("has Matching ingredients $hasMatchingIngredients");
        return meetsCookingTime && hasMatchingIngredients;
      }).toList();

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
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 116,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: minutesToCookController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Minutes to Cook',
                        ),
                      ),
                      const SizedBox(
                          height: 20), // Adjust as needed for spacing
                      TextFormField(
                        controller: ingredientPreferenceControllers[0],
                        decoration: const InputDecoration(
                          hintText: 'Ingredient Preference 1',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: ingredientPreferenceControllers[1],
                        decoration: const InputDecoration(
                          hintText: 'Ingredient Preference 2',
                        ),
                      ),
                      const SizedBox(
                          height: 20), // Adjust as needed for spacing
                      TextFormField(
                        controller: ingredientPreferenceControllers[2],
                        decoration: const InputDecoration(
                          hintText: 'Ingredient Preference 3',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100), // Adjust as needed for spacing
          ElevatedButton(
            onPressed: filterRecipes,
            child: const Text('Filter Recipes'),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: recipeList.length,
              itemBuilder: (context, index) {
                final r = recipeList[index];
                return ListTile(
                  leading: Image.network(
                    r['image'] ?? ifnull,
                    fit: BoxFit.cover,
                  ),
                  title: Text(r['recipeName']),
                  trailing: _like(r),
                  onTap: () {
                    // Navigate to the Recipe Details screen when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetails(r.data()),
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
