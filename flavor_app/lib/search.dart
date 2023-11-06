import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'displayRecipe.dart';
import 'userfavorites.dart';
import 'post.dart';

//This is the search page, unimplemented. I will do this later
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
  final recipeSearch = TextEditingController();
  List<Post> recipes = [];
  List<Post> recipeList = [];

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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 35,
            child: TextFormField(
                controller: recipeSearch,
              decoration: InputDecoration(
                prefix: const Icon(Icons.search),
                hintText: 'Recipe Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide( color: Colors.black),
                )
              ),
              onChanged: searchRecipes,
            ),
          ),
        ],
      ),
    );
  }
}
