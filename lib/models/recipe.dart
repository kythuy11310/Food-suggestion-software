class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.image,
    required this.ingredients,
    required this.shortInstructions,
    this.category = '',
  });

  final String id;
  final String name;
  final String image;
  final List<String> ingredients;
  final String shortInstructions;
  final String category;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'image': image,
      'ingredients': ingredients,
      'shortInstructions': shortInstructions,
      'category': category,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      ingredients: List<String>.from(json['ingredients'] as List<dynamic>),
      shortInstructions: json['shortInstructions'] as String,
      category: json['category'] as String? ?? '',
    );
  }
}
