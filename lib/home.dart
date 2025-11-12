import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'receipts.dart';
import 'pantry_screen.dart';
import 'profile_screen.dart';
import 'recipe_api_service.dart';

class FitnessHomePage extends StatefulWidget {
  final String userName;
  final Map<String, dynamic> userData;
  const FitnessHomePage({
    super.key,
    required this.userName,
    required this.userData,
  });

  @override
  State<FitnessHomePage> createState() => _FitnessHomePageState();
}

class _FitnessHomePageState extends State<FitnessHomePage> {
  int _currentIndex = 0;
  int _waterCups = 0;
  List<Map<String, dynamic>> _randomRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadWaterIntake();
    _loadRandomRecipes();
  }

  Future<void> _loadWaterIntake() async {
    try {
      final cups = await RecipeApiService.getWaterIntake(widget.userData['id']);
      if (!mounted) return;
      setState(() {
        _waterCups = cups;
      });
    } catch (e) {
      debugPrint('Error loading water intake: $e');
    }
  }

  Future<void> _loadRandomRecipes() async {
    try {
      final allRecipes = await RecipeApiService.fetchRecipes(limit: 100);
      if (allRecipes.isNotEmpty) {
        final random = Random();
        final selectedRecipes = <Map<String, dynamic>>[];
        final indices = List<int>.generate(allRecipes.length, (i) => i)
          ..shuffle(random);
        for (int i = 0; i < 2 && i < allRecipes.length; i++) {
          selectedRecipes.add(allRecipes[indices[i]]);
        }
        if (!mounted) return;
        setState(() {
          _randomRecipes = selectedRecipes;
        });
      }
    } catch (e) {
      debugPrint('Error loading random recipes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return ReceiptsScreen(
          onBackPressed: () => setState(() => _currentIndex = 0),
        );
      case 2:
        return PantryScreen(userData: widget.userData);
      case 3:
        return ProfileScreen(userData: widget.userData);
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    String formattedDate = DateFormat('d MMMM, EEEE').format(DateTime.now());
    String greeting = _getGreeting();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          formattedDate,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.grey),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingSection(greeting),
              const SizedBox(height: 24),
              _buildMainCards(),
              const SizedBox(height: 24),
              _buildQuickTips(),
              const SizedBox(height: 24),
              _buildTodayRecipes(),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia, ${widget.userName}';
    if (hour < 18) return 'Boa tarde, ${widget.userName}';
    return 'Boa noite, ${widget.userName}';
  }

  Widget _buildGreetingSection(String greeting) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage:
                    widget.userData['photo'] != null &&
                        widget.userData['photo'].isNotEmpty
                    ? NetworkImage(widget.userData['photo'])
                    : null,
                child:
                    widget.userData['photo'] == null ||
                        widget.userData['photo'].isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 30,
                        color: Color(0xFF4CAF50),
                      )
                    : null,
              )
              .animate()
              .scale(begin: const Offset(0.8, 0.8))
              .fadeIn(duration: 600.ms),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                      greeting,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 200.ms)
                    .slideX(begin: -0.2, end: 0),
                Text(
                      'Bem-vindo ao seu app de nutrição!',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 400.ms)
                    .slideX(begin: -0.2, end: 0),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 1000.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildMainCards() {
    return Column(
      children: [
        SizedBox(
              width: double.infinity,
              child: _buildFeatureCard(
                icon: Icons.water_drop,
                title: 'Água',
                subtitle: '$_waterCups / 10 copos',
                color: Colors.blue,
                onTap: _showAddWaterDialog,
              ),
            )
            .animate()
            .fadeIn(duration: 600.ms, delay: 800.ms)
            .slideY(begin: 0.2, end: 0),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: _waterCups / 10,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ).animate().fadeIn(duration: 600.ms, delay: 900.ms),
      ],
    );
  }

  void _showAddWaterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Adicionar 1 copo de água'),
          content: const Text(
            'Você gostaria de adicionar 1 copo à sua contagem diária?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final newCups = await RecipeApiService.addWaterCup(
                    widget.userData['id'],
                  );
                  if (!mounted) return; // ✅ protege o context do State
                  setState(() {
                    _waterCups = newCups;
                  });

                  // ✅ usa o context principal e só navega se ainda estiver montado
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  debugPrint('Error adding water cup: $e');
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dicas Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 1000.ms),
        const SizedBox(height: 12),
        _buildTipCard(
              '🍎',
              'Coma uma maçã por dia!',
              'Frutas são essenciais para uma dieta equilibrada.',
            )
            .animate()
            .fadeIn(duration: 600.ms, delay: 1100.ms)
            .slideX(begin: -0.1, end: 0),
        const SizedBox(height: 8),
        _buildTipCard(
              '💧',
              'Beba pelo menos 2 litros de água por dia',
              'A hidratação adequada melhora o metabolismo.',
            )
            .animate()
            .fadeIn(duration: 600.ms, delay: 1200.ms)
            .slideX(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildTipCard(String emoji, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayRecipes() {
    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Receitas do Dia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 1300.ms),
              const SizedBox(height: 16),
              if (_randomRecipes.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                ..._randomRecipes.map((recipe) {
                  final ingredients = recipe['ingredientes'] ?? '';
                  final truncatedIngredients = ingredients.length > 50
                      ? '${ingredients.substring(0, 50)}...'
                      : ingredients;
                  return Column(
                    children: [
                      _buildRecipeItem(recipe, truncatedIngredients),
                      const SizedBox(height: 12),
                    ],
                  );
                }),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms, delay: 1400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildRecipeItem(Map<String, dynamic> recipe, String details) {
    return GestureDetector(
      onTap: () {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReceiptsScreen(
              selectedRecipe: {
                'name': recipe['receita'] ?? 'Receita',
                'ingredients': (recipe['ingredientes'] ?? '').split(', '),
                'description': recipe['modo_preparo'] ?? 'Sem descrição',
                'category': 'Receita',
                'calories': 300,
                'time': 30,
                'difficulty': 'Fácil',
                'image': '🍽️',
                'rating': 4.5,
              },
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.restaurant, size: 20, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe['receita'] ?? 'Receita',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  details,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF4CAF50),
      unselectedItemColor: Colors.grey,
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Receitas',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: 'Despensa'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
