import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'favoriteProvider.dart';
import 'postprovider.dart';
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
  @override
  initState() {
    super.initState();
    final provider = Provider.of<PostProvider>(context, listen: false);
    recipes = provider.posts;
    print('recipes: ${recipes.length}');
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

  //this is the like button
  _like(var post) {
    final favs = Provider.of<FavoritesProvider>(context, listen: false);
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
          print(favs.recipes.length);
        },
      ),
    );
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
                    borderSide: const BorderSide(color: Colors.black),
                  )),
              onChanged: searchRecipes,
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: recipeList.length,
              itemBuilder: (context, index) {
                final r = recipeList[index];
                return ListTile(
                  leading: Image.network(
                    r.posts.image!,
                    fit: BoxFit.cover,
                  ),
                  title: Text(r.posts.recipeName),
                  trailing: _like(r),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
