//This is the recipe class
class Recipe {
  String recipeName;
  int recipeId;
  int minutes;
  List<double> nutrition;
  List<String> ingredients;
  List<String> steps;
  List<String> tags;
  String description;
  String? image;
  bool? isFavorite;
  bool? canAdd;
  List<String>? reviews = [];
  String? location;
  Recipe(
      {required this.recipeName,
        required this.recipeId,
        required this.minutes,
        required this.nutrition,
        required this.ingredients,
        required this.steps,
        required this.tags,
        required this.description,
        this.image,
        this.isFavorite,
        this.canAdd,
        this.location});

  //this is the method that converts the json data to a recipe object
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
        recipeName: json['recipeName'],
        recipeId: json['recipeID'],
        minutes: json['minutes'],
        nutrition: (json['nutrition'] is List)
            ? json['nutrition']
            .map((e) => double.tryParse(e.toString()) ?? 0.0)
            .toList()
            .cast<double>()
            : [],
        ingredients: json['ingredients'] is List
            ? json['ingredients'].cast<String>()
            : [],
        steps: json['steps'] is List ? json['steps'].cast<String>() : [],
        tags: json['tags'] is List ? json['tags'].cast<String>() : [],
        description: json['description'],
        image: json['image'],
        isFavorite: json['isFavorite'],
        canAdd: json['canAdd'],
        location: json['location']);
  }

  //this is the method that converts the recipe object to json data
  Map<String, dynamic> toJson() {
    return {
      'recipeName': recipeName,
      'recipeID': recipeId,
      'minutes': minutes,
      'nutrition': nutrition,
      'ingredients': ingredients,
      'steps': steps,
      'tags': tags,
      'description': description,
      'image': image,
    };
  }
}
