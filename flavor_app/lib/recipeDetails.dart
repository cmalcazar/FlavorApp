import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class recipeDetails extends StatelessWidget {
  final Map<String, dynamic> recipe;

  recipeDetails(this.recipe);

  @override
  Widget build(BuildContext context) {
    final List<dynamic> ingredients = recipe['ingredients'];
    final List<dynamic> steps = recipe['steps'];
    String ifnull =
        'https://firebasestorage.googleapis.com/v0/b/recipeapp-3ab43.appspot.com/o/images%2F1000_F_251955356_FAQH0U1y1TZw3ZcdPGybwUkH90a3VAhb.jpg?alt=media&token=091b00f6-a4a8-4a4a-b66f-60e8978fb471&_gl=1*1dfhnga*_ga*MTM5MTUxODI4My4xNjk4NTE4MjUw*_ga_CW55HF8NVT*MTY5OTM1MTA4OS40MS4xLjE2OTkzNTQ2MzMuMTAuMC4w';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipe['recipeName']?.toString()?.toUpperCase()?.trim() ?? ' ',
          style: GoogleFonts.lato(),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Image.network(
                recipe['image'] ?? ifnull,
                fit: BoxFit.cover,
              ),
              // Display recipe description, ingredients, and steps
              Column(
                crossAxisAlignment:CrossAxisAlignment.start,
                children: [
                  // Recipe Description
              Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',),
                  ),
                  Text(
                    recipe['description'] ?? 'No description available',
                    style: GoogleFonts.lato(fontSize: 16),
                  ),
                  ],
              ),
              ),
                  // Ingredients
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0,bottom: 5.0),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ingredients:', style: GoogleFonts.lato(fontSize: 30, fontWeight: FontWeight.bold,)),
                      Container(
                          width: 360,
                          child:Divider(
                        thickness: 4,
                        color: Colors.red[500],
                            height: 5,
                      ),
                      ),
                      SizedBox(height: 8),
                      for (var ingredient in ingredients) Text(ingredient,style: GoogleFonts.lato()),
                    ],
                  ),
                  ),
                  // Steps
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0,bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text('Instructions:', style: GoogleFonts.lato(fontSize: 30, fontWeight: FontWeight.bold,)),
                        Container(
                            width: 360,
                        child:Divider(
                          thickness: 4,
                          color: Colors.red[500],
                          height: 5,
                        ),
                        ),
                        SizedBox(height: 10),
                      for (var i = 0; i < steps.length; i++)
                        Text('${i + 1}. ${steps[i]}',style: GoogleFonts.lato(),),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}