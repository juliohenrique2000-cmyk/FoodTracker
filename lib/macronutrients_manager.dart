import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'database_service.dart';

// Classe para gerenciar macronutrientes
class MacronutrientsManager {
  static MacronutrientsManager? _instance;
  static MacronutrientsManager get instance {
    _instance ??= MacronutrientsManager._();
    return _instance!;
  }

  MacronutrientsManager._() {
    _logger = Logger('MacronutrientsManager');
  }

  late final Logger _logger;

  final ValueNotifier<MacronutrientsData> _dataNotifier = ValueNotifier(
    MacronutrientsData(),
  );

  ValueNotifier<MacronutrientsData> get dataNotifier => _dataNotifier;

  Future<void> loadActivitiesFromDatabase() async {
    try {
      final activities = await DatabaseService.instance.getAllActivities();
      updateFromActivities(activities);
    } catch (e) {
      _logger.severe('Erro ao carregar atividades do banco: $e');
    }
  }

  void updateFromActivities(List<Activity> activities) {
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFats = 0.0;

    for (var activity in activities) {
      totalProtein += activity.protein;
      totalCarbs += activity.carbs;
      totalFats += activity.fats;
    }

    _dataNotifier.value = MacronutrientsData(
      protein: totalProtein,
      carbs: totalCarbs,
      fats: totalFats,
    );
  }
}

class MacronutrientsData {
  final double protein;
  final double carbs;
  final double fats;

  MacronutrientsData({this.protein = 0.0, this.carbs = 0.0, this.fats = 0.0});

  // Metas diárias recomendadas (em gramas)
  static const double dailyProteinGoal = 150.0;
  static const double dailyCarbsGoal = 300.0;
  static const double dailyFatsGoal = 65.0;

  double get proteinProgress => protein / dailyProteinGoal;
  double get carbsProgress => carbs / dailyCarbsGoal;
  double get fatsProgress => fats / dailyFatsGoal;
}
