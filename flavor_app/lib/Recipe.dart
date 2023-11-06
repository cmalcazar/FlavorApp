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
        this.canAdd});

  //this is the method that converts the json data to a recipe object
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
        recipeName: json['title'],
        recipeId: json['id'],
        minutes: json['minutes'],
        nutrition: json['nutrition'],
        ingredients: json['ingredients'],
        steps: json['steps'],
        tags: json['tags'],
        description: json['description'],
        image: json['image'],
        isFavorite: json['isFavorite'],
        canAdd: json['canAdd']);
  }

  //this is the method that converts the recipe object to json data
  Map<String, dynamic> toJson() {
    return {
      'title': recipeName,
      'id': recipeId,
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
