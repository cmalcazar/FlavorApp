import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'postprovider.dart';
import 'package:file_picker/file_picker.dart';

import 'Recipe.dart';
import 'post.dart';

//This is the page to add recipes
class AddPosts extends StatelessWidget {
  const AddPosts({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Create Post'),

          //this is the back button
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
          ),
        ),
        body: PostPage(),
      ),
    );
  }
}

class PostPage extends StatefulWidget {
  PostPage({Key? key}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  //this is the form keys for all input in the TextForms
  final GlobalKey<FormFieldState<String>> _recipeName = GlobalKey();
  late String image = '';
  final GlobalKey<FormFieldState<String>> _minutes = GlobalKey();
  final GlobalKey<FormFieldState<String>> _ingredients = GlobalKey();
  final GlobalKey<FormFieldState<String>> _tags = GlobalKey();
  final GlobalKey<FormFieldState<String>> _steps = GlobalKey();
  final GlobalKey<FormFieldState<String>> _description = GlobalKey();
  final GlobalKey<FormFieldState<String>> _nutrition = GlobalKey();

  //this is the user and database variables
  late final authUser;
  late final db;
  var userData;
  var data;
  late int recipeLength;
  PlatformFile? imageFile;
  UploadTask? uploadTask;
  late int recipeLength;

  int _postId = 0;
  String users = 'users';
  String r = 'recipes';
  String ifnull =
      'https://firebasestorage.googleapis.com/v0/b/recipeapp-3ab43.appspot.com/o/images%2F1000_F_251955356_FAQH0U1y1TZw3ZcdPGybwUkH90a3VAhb.jpg?alt=media&token=091b00f6-a4a8-4a4a-b66f-60e8978fb471&_gl=1*1dfhnga*_ga*MTM5MTUxODI4My4xNjk4NTE4MjUw*_ga_CW55HF8NVT*MTY5OTM1MTA4OS40MS4xLjE2OTkzNTQ2MzMuMTAuMC4w';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUser();
  }

  //This is to get the user and database
  setUser() {
    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    final dbF = Provider.of<FirebaseFirestore>(context, listen: false);
    authUser = auth.currentUser;
    print(authUser!);
    db = dbF;
  }

  selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      imageFile = result.files.first;
    });
  }

  uploadFile() async {
    final storage = Provider.of<FirebaseStorage>(context, listen: false);
    final path = 'images/${_recipeName.currentState!.value!}.png';
    File? file = imageFile != null ? File(imageFile!.path!) : null;
    if (file != null) {
      final ref = storage.ref().child(path);
      uploadTask = ref.putFile(file);

      final snapshot = await uploadTask!.whenComplete(() {});

      final urlDownload = await snapshot.ref.getDownloadURL();

      setState(() {
        image = urlDownload;
        print('Image URL: $image'); // Print the image URL
      });
    } else {
      image = ifnull;
      return image;
    }

    return image;
  }

  //This is to generate a random id for the recipe
  generateId() {
    var random = Random();
    int randomNumber = random.nextInt(1000000) + 200;

    return randomNumber;
  }

  Future<int> getCollectionLength() async {
    QuerySnapshot _myDoc = await db.collection('posts').get();
    List<DocumentSnapshot> _myDocCount = _myDoc.docs;
    return _myDocCount.length;
  }

  //This is to submit the post to the database and add it to the list of posts
  void _submitPost() async {
    recipeLength = await getCollectionLength();
    var data;
    final post = Provider.of<PostProvider>(context, listen: false);

    // Add the await keyword to wait for the get() method to complete
    var querySnapshot = await db.collection('users').doc(authUser!.uid).get();

    // Now you can use the data
    data = querySnapshot.data();

    Recipe recipe = Recipe(
      recipeName: _recipeName.currentState!.value!,
      ingredients: _ingredients.currentState!.value!.split(',').toList(),
      recipeId: _postId,
      minutes: int.parse(_minutes.currentState!.value!),
      nutrition: _nutrition.currentState!.value!
          .split(',')
          .map((e) => double.tryParse(e) ?? 0.0)
          .toList(),
      image: image,
      description: _description.currentState!.value!,
      tags: _tags.currentState!.value!.split(',').toList(),
      steps: _steps.currentState!.value!.split(',').toList(),
      canAdd: true,
      isFavorite: false,
    );
    generateId();

    setState(() {
      post.addPost(Post(
        //this is the poster ID

        posterID: authUser!.uid,
        posts: recipe,
        likedCount: 0,
        dislikedCount: 0,
        location: data['location'],
      ));
    });

    db.collection(r).doc(_postId.toString()).set(recipe.toJson());
    db.collection('posts').doc((recipeLength + 1).toString()).set({
      'posts': recipe.toJson(),
      'posterID': authUser!.uid,
      'location': data['location'],
      'likedCount': 0,
      'dislikedCount': 0,
    });

  }

  showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Post Added!'),
      backgroundColor: Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(
              children: [
                //This is the image picker
                if (imageFile != null)
                  Container(
                    color: Colors.red,
                    child: Center(
                        child: Image.file(
                          File(imageFile!.path!),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )),
                  ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: selectFile,
                  child: const Text('Select Image'),
                ),
                //THis is the recipe name
                TextFormField(
                  key: _recipeName,
                  decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Name of recipe',
                      icon: Icon(Icons.food_bank)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a recipe name';
                    }
                    return null;
                  },
                ),

                //This is the cook time
                TextFormField(
                  key: _minutes,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.timer),
                      labelText: 'Cook time',
                      hintText: 'How long to cook ex. 55 (minutes))'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a time';
                    }
                    return null;
                  },
                ),

                //this is the ingredients
                TextFormField(
                  key: _ingredients,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.food_bank_rounded),
                      labelText: 'Ingredients',
                      hintText: "ex. '3lbs tamales', comma separated "),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter atleast one ingredient';
                    }
                    return null;
                  },
                ),

                //This is the tags
                TextFormField(
                  key: _tags,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.tag),
                      labelText: 'Tags',
                      hintText: "ex. 'mexican', comma separated "),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter atleast one tag';
                    }
                    return null;
                  },
                ),

                //This is the steps
                TextFormField(
                  key: _steps,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.list),
                      labelText: 'Steps',
                      hintText: "ex. 'pour broth,', comma separated"),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter at least one step';
                    }
                    return null;
                  },
                ),

                //This is the description
                TextFormField(
                  key: _description,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.description),
                      labelText: 'Description',
                      hintText: 'Describe recipe'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),

                //This is the nutrition
                TextFormField(
                  key: _nutrition,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.inventory),
                      labelText: 'Nutrition',
                      hintText:
                      "ex. 51.0 (calories (#), total fat, sugar, sodium, protein, saturated fats), comma separated "),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter atleast one nutrition value';
                    }
                    return null;
                  },
                ),

                //This is the submit button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        var temp = await uploadFile();
                        setState(() {
                          _postId = generateId();
                          image = temp;
                        });
                        print(authUser!);
                        //THis is to submit the post with the user displayname
                        _submitPost();
                        showSnackBar();
                      },
                      child: const Text('Submit'),
                    ),
                    TextButton(
                      child: const Text("Reset"),
                      onPressed: () => {
                        _recipeName.currentState?.reset(),
                        _minutes.currentState?.reset(),
                        _description.currentState?.reset(),
                        _ingredients.currentState?.reset(),
                        _nutrition.currentState?.reset(),
                        _steps.currentState?.reset(),
                        _tags.currentState?.reset(),
                      },
                    ),
                  ],
                )
              ],
            )));
  }
}
