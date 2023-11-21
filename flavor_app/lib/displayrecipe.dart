import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:favorite_button/favorite_button.dart';

import 'package:provider/provider.dart';
import 'addpost.dart';
import 'favoriteProvider.dart';

import 'post.dart';
import 'postprovider.dart';
import 'recipepage.dart';

//this is the page where the user can view the recipes as a timeline
//might change it to a list time so you can just click and it'll show who uploaded it and the recipe

class DisplayRecipe extends StatelessWidget {
  const DisplayRecipe({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const DisplayRecipePage(),
    );
  }
}

class DisplayRecipePage extends StatefulWidget {
  const DisplayRecipePage({super.key});

  @override
  State<DisplayRecipePage> createState() => _DisplayRecipeState();
}

class _DisplayRecipeState extends State<DisplayRecipePage> {
  final recipeSearch = TextEditingController();

  late List<Post> posts = [];
  late List<Post> recipes = [];
  late List<Post> recipeList = [];

  late final provider;
  late final db;
  late final auth;
  var recipe;
  var data;
  String ifnull =
      'https://firebasestorage.googleapis.com/v0/b/recipeapp-3ab43.appspot.com/o/images%2F1000_F_251955356_FAQH0U1y1TZw3ZcdPGybwUkH90a3VAhb.jpg?alt=media&token=091b00f6-a4a8-4a4a-b66f-60e8978fb471&_gl=1*1dfhnga*_ga*MTM5MTUxODI4My4xNjk4NTE4MjUw*_ga_CW55HF8NVT*MTY5OTM1MTA4OS40MS4xLjE2OTkzNTQ2MzMuMTAuMC4w';

  //this is the method that will be called when the user taps on the bottom navigator
  @override
  void initState() {
    super.initState();
    provider = Provider.of<PostProvider>(context, listen: false);
    db = Provider.of<FirebaseFirestore>(context, listen: false);
    auth = Provider.of<FirebaseAuth>(context, listen: false);

    extraData();
  }

  getUserData() async {
    var querySnapshot =
    await db.collection('users').doc(auth.currentUser!.uid).get();
    var uData = querySnapshot.data()!;
    print(uData);
    return uData;
  }

  //gets the top 10 recipes from the database and adds it to the list
  //If the recipe is already in the list it won't add it again
  extraData() async {
    var uData = await getUserData();
    for (int i = 0; i < 10; i++) {
      db
          .collection('recipes')
          .doc(i.toString())
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          recipe = documentSnapshot.data();
          setState(() {
            data = Post.fromJson2(auth.currentUser, recipe);
            if (!provider.posts.any(
                    (post) => post.posts.recipeName == data.posts.recipeName)) {
              provider.addPost(data);
            }

            recipes = provider.posts
                .where((recipe) =>
            recipe.posts.location == uData['location'] ||
                recipe.posts.location == null)
                .toList();

            recipeList = recipes;
          });
        } else {
          print('Document does not exist on the database');
        }
      });
    }
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

  void searchRecipes(String query) {
    //Searches and creates new list of games that matches the query String
    //everytime the text field is changed
    final suggestions = recipes.where((recipe) {
      final recipeName = recipe.posts.recipeName.toLowerCase();
      final input = query.toLowerCase();

      //return the instance that == the query String
      return recipeName.contains(input);
    }).toList();

    //sets the state back to gameList to refill the list of previous games
    setState(() => recipeList = suggestions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //This button is to add recipes
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            //This is the button that will take you to the add recipe page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPosts()),
            );
          },
          child: const Icon(Icons.add)),
      body: Column(children: [
        SizedBox(
          height: 35,
          child: TextFormField(
            controller: recipeSearch,
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
            child: ListView.builder(
              itemCount: recipeList.length,
              itemBuilder: (BuildContext context, int index) {
                var post = recipeList[index];
                //this is the list of recipes
                return ListTile(
                  leading: Image.network(
                    post.posts.image ?? ifnull,
                    fit: BoxFit.cover,
                  ),
                  title: Text(post.posts.recipeName),
                  subtitle: Text(post.poster!.displayName!),
                  trailing: _like(post),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShowRecipe(
                            post: post,
                          )),
                    );
                  },
                );
              },
            )),
      ]),
    );
  }
}
