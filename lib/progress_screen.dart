import 'package:flutter/material.dart';
import 'database_service.dart';
import 'macronutrients_manager.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<Activity> _activities = [];
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  String? _selectedActivityType;
  double _totalCalories = 0.0;

  final Map<String, double> _caloriesPerMinute = {
    'Corrida': 10.0,
    'Caminhada': 5.0,
    'Natação': 8.0,
    'Ciclismo': 7.0,
    'Musculação': 6.0,
    'Yoga': 3.0,
    'Dança': 6.5,
    'Futebol': 8.5,
    'Basquete': 9.0,
    'Tênis': 7.5,
  };

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  @override
  void dispose() {
    _activityController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    try {
      final activities = await DatabaseService.instance.getAllActivities();
      setState(() {
        _activities = activities;
        _totalCalories = activities.fold(
          0.0,
          (sum, activity) => sum + activity.calories,
        );
      });
    } catch (e) {
      debugPrint('Erro ao carregar atividades: $e');
    }
  }

  Future<void> _addActivity() async {
    if (_activityController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _selectedActivityType == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, preencha todos os campos'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final duration = int.tryParse(_durationController.text);
    if (duration == null || duration <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Duração deve ser um número válido'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final caloriesPerMinute = _caloriesPerMinute[_selectedActivityType!] ?? 5.0;
    final totalCalories = caloriesPerMinute * duration;

    // Calcular macronutrientes baseado no tipo de atividade
    final Map<String, Map<String, double>> macroNutrients = {
      'Corrida': {'protein': 0.5, 'carbs': 2.0, 'fats': 0.3},
      'Caminhada': {'protein': 0.3, 'carbs': 1.2, 'fats': 0.2},
      'Natação': {'protein': 0.8, 'carbs': 1.5, 'fats': 0.4},
      'Ciclismo': {'protein': 0.6, 'carbs': 2.5, 'fats': 0.3},
      'Musculação': {'protein': 1.2, 'carbs': 0.8, 'fats': 0.2},
      'Yoga': {'protein': 0.2, 'carbs': 0.5, 'fats': 0.1},
      'Dança': {'protein': 0.4, 'carbs': 1.8, 'fats': 0.3},
      'Futebol': {'protein': 0.7, 'carbs': 2.2, 'fats': 0.4},
      'Basquete': {'protein': 0.8, 'carbs': 2.8, 'fats': 0.5},
      'Tênis': {'protein': 0.6, 'carbs': 2.0, 'fats': 0.3},
    };

    final macros =
        macroNutrients[_selectedActivityType!] ??
        {'protein': 0.4, 'carbs': 1.0, 'fats': 0.2};
    final protein = macros['protein']! * duration;
    final carbs = macros['carbs']! * duration;
    final fats = macros['fats']! * duration;

    final newActivity = Activity(
      name: _activityController.text,
      type: _selectedActivityType!,
      duration: duration,
      calories: totalCalories,
      protein: protein,
      carbs: carbs,
      fats: fats,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    try {
      final activityId = await DatabaseService.instance.insertActivity(
        newActivity,
      );

      setState(() {
        final activityWithId = newActivity.copyWith(id: activityId);
        _activities.add(activityWithId);
        _totalCalories += totalCalories;
      });

      _activityController.clear();
      _durationController.clear();
      _selectedActivityType = null;

      // Atualizar macronutrientes na tela inicial
      MacronutrientsManager.instance.updateFromActivities(_activities);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Atividade adicionada! ${totalCalories.round()} calorias',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar atividade'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeActivity(int index) async {
    try {
      final activity = _activities[index];
      if (activity.id != null) {
        await DatabaseService.instance.deleteActivity(activity.id!);
      }

      setState(() {
        _totalCalories -= activity.calories;
        _activities.removeAt(index);
      });

      // Atualizar macronutrientes na tela inicial
      MacronutrientsManager.instance.updateFromActivities(_activities);
    } catch (e) {
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao remover atividade'),
          backgroundColor: Colors.red,
        ),
      );
     }
    }
  }

  Future<void> _toggleActivityCompletion(int index) async {
    try {
      final activity = _activities[index];
      final updatedActivity = activity.copyWith(
        isCompleted: !activity.isCompleted,
      );

      if (activity.id != null) {
        await DatabaseService.instance.updateActivity(updatedActivity);
      }

      setState(() {
        _activities[index] = updatedActivity;
      });

      // Atualizar macronutrientes na tela inicial
      MacronutrientsManager.instance.updateFromActivities(_activities);
    } catch (e) {
      if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao atualizar atividade'),
          backgroundColor: Colors.red,
        ),
      );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Progresso',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de calorias totais
            _buildTotalCaloriesCard(),

            const SizedBox(height: 24),

            // Formulário para adicionar atividades
            _buildAddActivityForm(),

            const SizedBox(height: 24),

            // Lista de atividades
            _buildActivitiesList(),

            const SizedBox(height: 24),

            // Dicas de progresso
            _buildProgressTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCaloriesCard() {
    final completedActivities = _activities.where((a) => a.isCompleted).length;
    final progressPercentage = _activities.isEmpty
        ? 0.0
        : completedActivities / _activities.length;

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
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calorias Estimadas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '${_totalCalories.round()} cal',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso: $completedActivities/${_activities.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progressPercentage * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAddActivityForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adicionar Atividade',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Campo de nome da atividade
          TextField(
            controller: _activityController,
            decoration: InputDecoration(
              labelText: 'Nome da Atividade',
              hintText: 'Ex: Corrida matinal',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.fitness_center),
            ),
          ),

          const SizedBox(height: 16),

          // Dropdown para tipo de atividade
          DropdownButtonFormField<String>(
            initialValue: _selectedActivityType,
            decoration: InputDecoration(
              labelText: 'Tipo de Atividade',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.category),
            ),
            items: _caloriesPerMinute.keys.map((String type) {
              return DropdownMenuItem<String>(value: type, child: Text(type));
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedActivityType = newValue;
              });
            },
          ),

          const SizedBox(height: 16),

          // Campo de duração
          TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Duração (minutos)',
              hintText: '30',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.timer),
            ),
          ),

          const SizedBox(height: 20),

          // Botão adicionar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addActivity,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Atividade'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList() {
    if (_activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(Icons.fitness_center, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhuma atividade cadastrada',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione suas atividades para calcular as calorias',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Atividades do Dia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${_activities.length} atividade${_activities.length != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _activities.length,
            itemBuilder: (context, index) {
              final activity = _activities[index];
              return _buildActivityItem(activity, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Activity activity, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: activity.isCompleted ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: activity.isCompleted ? Colors.green[300]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: activity.isCompleted,
            onChanged: (bool? value) {
              _toggleActivityCompletion(index);
            },
            activeColor: const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activity.isCompleted
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                  : const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.fitness_center,
              color: activity.isCompleted
                  ? const Color(0xFF4CAF50)
                  : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: activity.isCompleted
                        ? Colors.green[800]
                        : Colors.black87,
                    decoration: activity.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${activity.type} • ${activity.duration} min • ${activity.calories.round()} cal',
                  style: TextStyle(
                    fontSize: 12,
                    color: activity.isCompleted
                        ? Colors.green[600]
                        : Colors.grey[600],
                    decoration: activity.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeActivity(index),
            icon: Icon(
              Icons.delete_outline,
              color: activity.isCompleted ? Colors.green[400] : Colors.red[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Dicas para seu Progresso',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildTipItem(
            '🏃‍♂️ Mantenha consistência',
            'Pratique atividades regularmente para melhores resultados',
          ),
          const SizedBox(height: 8),
          _buildTipItem(
            '⚖️ Equilibre sua dieta',
            'Combine exercícios com uma alimentação saudável',
          ),
          const SizedBox(height: 8),
          _buildTipItem(
            '📊 Acompanhe seu progresso',
            'Registre suas atividades para ver sua evolução',
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.split(' ')[0], style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.substring(2),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
