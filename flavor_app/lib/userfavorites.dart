import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'favoriteProvider.dart';
import 'post.dart';
import 'recipepage.dart';

//THis is the user favorites class
class UserFavorites extends StatelessWidget {
  const UserFavorites({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Favorites',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const Scaffold(body: UserFavoritesPage()),
    );
  }
}

class UserFavoritesPage extends StatefulWidget {
  const UserFavoritesPage({super.key});

  @override
  State<UserFavoritesPage> createState() => _UserFavoritesPageState();
}

class _UserFavoritesPageState extends State<UserFavoritesPage> {
  String ifnull =
      'https://firebasestorage.googleapis.com/v0/b/recipeapp-3ab43.appspot.com/o/images%2F1000_F_251955356_FAQH0U1y1TZw3ZcdPGybwUkH90a3VAhb.jpg?alt=media&token=091b00f6-a4a8-4a4a-b66f-60e8978fb471&_gl=1*1dfhnga*_ga*MTM5MTUxODI4My4xNjk4NTE4MjUw*_ga_CW55HF8NVT*MTY5OTM1MTA4OS40MS4xLjE2OTkzNTQ2MzMuMTAuMC4w';
  late List<Post> posts = [];
  late List<Post> favs = [];
  late List<Post> favList = [];
  final searchFavs = TextEditingController();

  late final db;
  late final auth;
  late final provider;

  @override
  void initState() {
    super.initState();
    db = Provider.of<FirebaseFirestore>(context, listen: false);
    provider = Provider.of<FavoritesProvider>(context, listen: false);
    auth = Provider.of<FirebaseAuth>(context, listen: false);

    getFavs();
  }

  //gets the favorites from the favorites list in the favorites provider class
  getFavs() {
    setState(() {
      favs = provider.recipes;
    });
    favList = favs;
  }

  //Searches the recipes in the favorites list
  void searchRecipes(String query) {
    //Searches and creates new list of games that matches the query String
    //everytime the text field is changed
    final suggestions = favs.where((recipe) {
      final recipeName = recipe.posts.recipeName.toLowerCase();
      final input = query.toLowerCase();

      //return the instance that == the query String
      return recipeName.contains(input);
    }).toList();

    //sets the state back to gameList to refill the list of previous games
    setState(() => favList = suggestions);
  }

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
        isFavorite: post.posts.isFavorite,
        valueChanged: (fav) {
          post.posts.isFavorite = fav;
          if (fav) {
            post.posts.canAdd = false;
          }
          favs.addFav(post);
          List<Map<String, dynamic>> jsonList =
          favs.recipes.map((item) => item.posts.toJson()).toList();
          var authUser = auth.currentUser;
          db
              .collection('users')
              .doc(authUser!.uid)
              .update({'favorites': jsonList});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 35,
            child: TextFormField(
              controller: searchFavs,
              decoration: InputDecoration(
                  prefix: const Icon(Icons.search),
                  hintText: 'Recipe Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black),
                  )),
              onChanged: searchRecipes,
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: favList.length,
              itemBuilder: (BuildContext context, int index) {
                var post = favList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowRecipe(
                          post: post,
                          index: index,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Stack(alignment: Alignment.bottomRight, children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                              ),
                              child: Image.network(
                                post.posts.image ?? ifnull,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.posts.recipeName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  post.posts.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _like(post)),
                    ]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
