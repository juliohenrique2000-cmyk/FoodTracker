import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'recipe_api_service.dart';
import 'home.dart';

class ReceiptsScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final Map<String, dynamic>? selectedRecipe;

  const ReceiptsScreen({super.key, this.onBackPressed, this.selectedRecipe});

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  String selectedCategory = 'Todas';
  final List<String> categories = [
    'Todas',
    'Refeições',
    'Sobremesas',
    'Favoritos',
  ];
  String searchQuery = '';

  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> favoriteRecipes = [];
  bool isLoading = true;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    if (widget.selectedRecipe != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRecipeDetails(widget.selectedRecipe!);
      });
    }
  }

  Future<void> _loadRecipes() async {
    try {
      // Fetch recipes for 'doce' and 'salgado' types
      final doceRecipes = await RecipeApiService.fetchRecipesByType('doce');
      final salgadoRecipes = await RecipeApiService.fetchRecipesByType(
        'salgado',
      );

      // Combine the results
      final fetchedRecipes = [...doceRecipes, ...salgadoRecipes];

      if (fetchedRecipes.isNotEmpty) {
        setState(() {
          recipes = fetchedRecipes
              .map((recipe) {
                return {
                  'name': recipe['receita'] ?? 'Receita sem nome',
                  'category': _mapTypeToCategory(recipe['tipo']),
                  'calories':
                      300, // Placeholder, as API doesn't provide calories
                  'time': 30, // Placeholder
                  'difficulty': 'Fácil', // Placeholder
                  'image': '🍽️', // Placeholder emoji
                  'rating': 4.5, // Placeholder
                  'ingredients': recipe['ingredientes']?.split(', ') ?? [],
                  'description': recipe['modo_preparo'] ?? 'Sem descrição',
                };
              })
              .where((recipe) => recipe != null)
              .cast<Map<String, dynamic>>()
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar receitas: $e')),
        );
      }
    }
  }

  String _mapTypeToCategory(String? tipo) {
    switch (tipo) {
      case 'doce':
        return 'Sobremesas';
      case 'salgado':
        return 'Jantar';
      default:
        return 'Almoço';
    }
  }

  final List<Map<String, dynamic>> staticRecipes = [
    {
      'name': 'Salada Caesar Clássica',
      'category': 'Almoço',
      'calories': 320,
      'time': 15,
      'difficulty': 'Fácil',
      'image': '🥗',
      'rating': 4.8,
      'ingredients': [
        'Alface',
        'Frango grelhado',
        'Croutons',
        'Queijo parmesão',
        'Molho caesar',
      ],
      'description':
          'Uma salada fresca e crocante com frango grelhado e molho caesar caseiro.',
    },
    {
      'name': 'Frango Grelhado com Legumes',
      'category': 'Jantar',
      'calories': 450,
      'time': 25,
      'difficulty': 'Médio',
      'image': '🍗',
      'rating': 4.6,
      'ingredients': [
        'Peito de frango',
        'Abobrinha',
        'Berinjela',
        'Pimentão',
        'Ervas',
      ],
      'description':
          'Frango suculento grelhado com legumes da estação, perfeito para uma refeição balanceada.',
    },
    {
      'name': 'Panqueca de Aveia',
      'category': 'Café da Manhã',
      'calories': 280,
      'time': 10,
      'difficulty': 'Fácil',
      'image': '🥞',
      'rating': 4.9,
      'ingredients': ['Aveia', 'Leite', 'Ovo', 'Banana', 'Canela'],
      'description':
          'Panquecas saudáveis e nutritivas para começar o dia com energia.',
    },
    {
      'name': 'Sopa de Legumes',
      'category': 'Almoço',
      'calories': 180,
      'time': 30,
      'difficulty': 'Fácil',
      'image': '🍲',
      'rating': 4.4,
      'ingredients': ['Cenoura', 'Batata', 'Abóbora', 'Cebola', 'Alho'],
      'description':
          'Sopa reconfortante e nutritiva, perfeita para dias frios.',
    },
    {
      'name': 'Iogurte com Frutas',
      'category': 'Lanches',
      'calories': 150,
      'time': 5,
      'difficulty': 'Fácil',
      'image': '🍓',
      'rating': 4.7,
      'ingredients': [
        'Iogurte natural',
        'Morangos',
        'Banana',
        'Granola',
        'Mel',
      ],
      'description':
          'Lanche rápido e saudável, rico em probióticos e vitaminas.',
    },
    {
      'name': 'Quinoa com Vegetais',
      'category': 'Vegetarianas',
      'calories': 380,
      'time': 20,
      'difficulty': 'Fácil',
      'image': '🥗',
      'rating': 4.5,
      'ingredients': ['Quinoa', 'Brócolis', 'Cenoura', 'Cebola roxa', 'Azeite'],
      'description':
          'Prato vegetariano completo e nutritivo, fonte de proteína vegetal.',
    },
  ];

  List<Map<String, dynamic>> get filteredRecipes {
    final baseRecipes = recipes.isNotEmpty ? recipes : staticRecipes;
    final categoryFiltered = selectedCategory == 'Todas'
        ? baseRecipes
        : selectedCategory == 'Refeições'
        ? baseRecipes
              .where(
                (recipe) =>
                    recipe['category'] == 'Almoço' ||
                    recipe['category'] == 'Jantar',
              )
              .toList()
        : selectedCategory == 'Favoritos'
        ? favoriteRecipes
        : baseRecipes
              .where((recipe) => recipe['category'] == selectedCategory)
              .toList();

    if (searchQuery.isEmpty) {
      return categoryFiltered;
    }

    return categoryFiltered.where((recipe) {
      final name = recipe['name'].toString().toLowerCase();
      final ingredients =
          (recipe['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString().toLowerCase())
              .join(' ') ??
          '';
      final query = searchQuery.toLowerCase();
      return name.contains(query) || ingredients.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Receitas',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) =>
                    const FitnessHomePage(userName: 'Usuário', userData: {}),
              ),
              (Route<dynamic> route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.grey),
            onPressed: () => _showCreateRecipeDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar receitas...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Categories Filter
          _buildCategoriesFilter(),

          // Create Recipe Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showCreateRecipeDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Criar Nova Receita'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Recipes List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      return _buildRecipeCard(recipe);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF4CAF50),
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF4CAF50)
                      : Colors.grey[300]!,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showRecipeDetails(recipe),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Recipe Image/Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    recipe['category'],
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: recipe['image'].startsWith('/')
                      ? Image.file(
                          File(recipe['image']),
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                        )
                      : Text(
                          recipe['image'],
                          style: const TextStyle(fontSize: 30),
                        ),
                ),
              ),

              const SizedBox(width: 16),

              // Recipe Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe['description'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.local_fire_department,
                          '${recipe['calories']} cal',
                          Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          Icons.access_time,
                          '${recipe['time']} min',
                          Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          Icons.star,
                          '${recipe['rating']}',
                          Colors.amber,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Café da Manhã':
        return Colors.orange;
      case 'Almoço':
        return Colors.green;
      case 'Jantar':
        return Colors.purple;
      case 'Lanches':
        return Colors.blue;
      case 'Sobremesas':
        return Colors.pink;
      case 'Vegetarianas':
        return Colors.teal;
      case 'Low Carb':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  void _showRecipeDetails(Map<String, dynamic> recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Tap to close area at the top
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: 40,
                  color: Colors.transparent,
                  child: const Center(
                    child: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              recipe['category'],
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: recipe['image'].startsWith('/')
                                ? Image.file(
                                    File(recipe['image']),
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  )
                                : Text(
                                    recipe['image'],
                                    style: const TextStyle(fontSize: 40),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe['name'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                recipe['category'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _getCategoryColor(recipe['category']),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Quick Info
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailCard(
                            Icons.local_fire_department,
                            'Calorias',
                            '${recipe['calories']} kcal',
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailCard(
                            Icons.access_time,
                            'Tempo',
                            '${recipe['time']} min',
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailCard(
                            Icons.trending_up,
                            'Dificuldade',
                            recipe['difficulty'],
                            Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Description
                    const Text(
                      'Descrição',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipe['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Ingredients
                    const Text(
                      'Ingredientes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...recipe['ingredients']
                        .map<Widget>(
                          (ingredient) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Color(0xFF4CAF50),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  ingredient,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),

                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: StatefulBuilder(
                            builder: (context, setState) {
                              final isFavorite = favoriteRecipes.any(
                                (fav) => fav['name'] == recipe['name'],
                              );
                              return ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    if (isFavorite) {
                                      favoriteRecipes.removeWhere(
                                        (fav) => fav['name'] == recipe['name'],
                                      );
                                    } else {
                                      favoriteRecipes.add(recipe);
                                    }
                                  });
                                  // Update the main state
                                  this.setState(() {});
                                },
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                ),
                                label: const Text('Favoritar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF4CAF50),
                                  side: const BorderSide(
                                    color: Color(0xFF4CAF50),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _shareRecipe(recipe),
                            icon: const Icon(Icons.share),
                            label: const Text('Compartilhar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateRecipeDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ingredientsController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedCategory = 'Almoço';
    File? selectedImage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Criar Nova Receita'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Picker Button
                ElevatedButton.icon(
                  onPressed: () async {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (image != null) {
                      setState(() {
                        selectedImage = File(image.path);
                      });
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Tirar Foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                  ),
                ),
                if (selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Image.file(
                      selectedImage!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Receita',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      [
                            'Almoço',
                            'Jantar',
                            'Sobremesas',
                            'Café da Manhã',
                            'Lanches',
                            'Vegetarianas',
                          ]
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    selectedCategory = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ingredientsController,
                  decoration: const InputDecoration(
                    labelText: 'Ingredientes (separados por vírgula)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Modo de Preparo',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    ingredientsController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  final newRecipe = {
                    'name': nameController.text,
                    'category': selectedCategory,
                    'calories': 300,
                    'time': 30,
                    'difficulty': 'Fácil',
                    'image': selectedImage != null
                        ? selectedImage!.path
                        : '🍽️',
                    'rating': 4.5,
                    'ingredients': ingredientsController.text.split(', '),
                    'description': descriptionController.text,
                  };

                  setState(() {
                    recipes.add(newRecipe);
                  });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Receita criada com sucesso!'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, preencha todos os campos.'),
                    ),
                  );
                }
              },
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );
  }

  void _shareRecipe(Map<String, dynamic> recipe) {
    final String recipeText =
        '''
${recipe['name']}

Categoria: ${recipe['category']}
Tempo: ${recipe['time']} min
Dificuldade: ${recipe['difficulty']}
Calorias: ${recipe['calories']} kcal

Ingredientes:
${recipe['ingredients'].join('\n')}

Modo de Preparo:
${recipe['description']}
    ''';

    Share.share(recipeText, subject: 'Receita: ${recipe['name']}');
  }

  Widget _buildDetailCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
