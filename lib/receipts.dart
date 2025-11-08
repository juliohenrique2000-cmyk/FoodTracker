import 'package:flutter/material.dart';
import 'recipe_api_service.dart';

class ReceiptsScreen extends StatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  String selectedCategory = 'Todas';
  final List<String> categories = [
    'Todas',
    'Café da Manhã',
    'Almoço',
    'Jantar',
    'Lanches',
    'Sobremesas',
    'Vegetarianas',
    'Low Carb',
  ];

  List<Map<String, dynamic>> recipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    try {
      final fetchedRecipes = await RecipeApiService.fetchRecipes();
      if (fetchedRecipes != null && fetchedRecipes.isNotEmpty) {
        setState(() {
          recipes = fetchedRecipes
              .map((recipe) {
                if (recipe == null) return null;
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
      case 'agridoce':
        return 'Lanches';
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
    if (selectedCategory == 'Todas') {
      return recipes.isNotEmpty ? recipes : staticRecipes;
    }
    return (recipes.isNotEmpty ? recipes : staticRecipes)
        .where((recipe) => recipe['category'] == selectedCategory)
        .toList();
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories Filter
          _buildCategoriesFilter(),

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
                  child: Text(
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
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
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
                      child: Text(
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
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border),
                      label: const Text('Favoritar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4CAF50),
                        side: const BorderSide(color: Color(0xFF4CAF50)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Preparar'),
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
      ),
    );
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
