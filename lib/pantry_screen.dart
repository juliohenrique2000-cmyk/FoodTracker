import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

enum MealCategory { breakfast, lunch, dinner }

enum FoodType { drink, protein, carbohydrate, fruit, grain }

class PantryItem {
  final int? id;
  final String name;
  final String? photo;
  final List<MealCategory> categories;
  final FoodType type;

  PantryItem({
    this.id,
    required this.name,
    this.photo,
    required this.categories,
    required this.type,
  });

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'],
      name: json['name'],
      photo: json['photo'],
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map(
                (e) => MealCategory.values.firstWhere(
                  (cat) => cat.name == e.toString().toLowerCase(),
                  orElse: () => MealCategory.breakfast,
                ),
              )
              .toList() ??
          [],
      type: FoodType.values.firstWhere(
        (type) => type.name == json['type'].toString().toLowerCase(),
        orElse: () => FoodType.fruit,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'photo': photo,
      'categories': categories.map((e) => e.name.toUpperCase()).toList(),
      'type': type.name.toUpperCase(),
    };
  }
}

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  List<PantryItem> _pantryItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPantryItems();
  }

  Future<void> _loadPantryItems() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/pantry'),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _pantryItems = data.map((json) => PantryItem.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load pantry items');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar itens da despensa: $e')),
      );
    }
  }

  Future<void> _addPantryItem(PantryItem item) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/pantry'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      );
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        _loadPantryItems();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item adicionado com sucesso!')),
        );
      } else {
        throw Exception('Failed to add pantry item');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao adicionar item: $e')));
    }
  }

  Future<void> _editPantryItem(PantryItem item) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/pantry/${item.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        _loadPantryItems();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item editado com sucesso!')),
        );
      } else {
        throw Exception('Failed to edit pantry item');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao editar item: $e')));
    }
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AddPantryItemDialog(onItemAdded: _addPantryItem),
    );
  }

  void _showEditItemDialog(PantryItem item) {
    showDialog(
      context: context,
      builder: (context) =>
          AddPantryItemDialog(onItemAdded: _editPantryItem, itemToEdit: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Despensa',
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
            icon: const Icon(Icons.add, color: Color(0xFF4CAF50)),
            onPressed: _showAddItemDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pantryItems.isEmpty
          ? _buildEmptyState()
          : _buildPantryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.kitchen, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Sua despensa está vazia',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione alimentos para começar',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddItemDialog,
            icon: const Icon(Icons.add),
            label: const Text('Novo Alimento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPantryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pantryItems.length + 1,
      itemBuilder: (context, index) {
        if (index == _pantryItems.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: ElevatedButton.icon(
              onPressed: _showAddItemDialog,
              icon: const Icon(Icons.add),
              label: const Text('Novo Alimento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          );
        }
        final item = _pantryItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getTypeColor(item.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getTypeIcon(item.type),
                color: _getTypeColor(item.type),
              ),
            ),
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getTypeName(item.type)),
                Text(
                  'Categorias: ${item.categories.map((c) => _getCategoryName(c)).join(', ')}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditItemDialog(item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deletePantryItem(item),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deletePantryItem(PantryItem item) async {
    if (item.id == null) return;

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/pantry/${item.id}'),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        _loadPantryItems();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removido com sucesso!')),
        );
      } else {
        throw Exception('Failed to delete pantry item');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao remover item: $e')));
    }
  }

  Color _getTypeColor(FoodType type) {
    switch (type) {
      case FoodType.drink:
        return Colors.blue;
      case FoodType.protein:
        return Colors.red;
      case FoodType.carbohydrate:
        return Colors.orange;
      case FoodType.fruit:
        return Colors.green;
      case FoodType.grain:
        return Colors.brown;
    }
  }

  IconData _getTypeIcon(FoodType type) {
    switch (type) {
      case FoodType.drink:
        return Icons.local_drink;
      case FoodType.protein:
        return Icons.restaurant;
      case FoodType.carbohydrate:
        return Icons.restaurant_menu;
      case FoodType.fruit:
        return Icons.apple;
      case FoodType.grain:
        return Icons.grain;
    }
  }

  String _getTypeName(FoodType type) {
    switch (type) {
      case FoodType.drink:
        return 'Bebida';
      case FoodType.protein:
        return 'Proteína';
      case FoodType.carbohydrate:
        return 'Carboidrato';
      case FoodType.fruit:
        return 'Fruta';
      case FoodType.grain:
        return 'Grão';
    }
  }

  String _getCategoryName(MealCategory category) {
    switch (category) {
      case MealCategory.breakfast:
        return 'Café';
      case MealCategory.lunch:
        return 'Almoço';
      case MealCategory.dinner:
        return 'Janta';
    }
  }
}

class AddPantryItemDialog extends StatefulWidget {
  final Function(PantryItem) onItemAdded;
  final PantryItem? itemToEdit;

  const AddPantryItemDialog({
    super.key,
    required this.onItemAdded,
    this.itemToEdit,
  });

  @override
  State<AddPantryItemDialog> createState() => _AddPantryItemDialogState();
}

class _AddPantryItemDialogState extends State<AddPantryItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _photoController = TextEditingController();
  FoodType _selectedType = FoodType.fruit;
  final List<MealCategory> _selectedCategories = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      _nameController.text = widget.itemToEdit!.name;
      _photoController.text = widget.itemToEdit!.photo ?? '';
      _selectedType = widget.itemToEdit!.type;
      _selectedCategories.addAll(widget.itemToEdit!.categories);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _photoController.text = image.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao tirar foto: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.itemToEdit != null ? 'Editar Alimento' : 'Novo Alimento',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _photoController,
                      decoration: const InputDecoration(
                        labelText: 'Foto (URL opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: _pickImage,
                    tooltip: 'Tirar foto',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FoodType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: FoodType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Categorias:'),
              Wrap(
                spacing: 8,
                children: MealCategory.values.map((category) {
                  return FilterChip(
                    label: Text(_getCategoryName(category)),
                    selected: _selectedCategories.contains(category),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
          ),
          child: Text(widget.itemToEdit != null ? 'Editar' : 'Adicionar'),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final item = PantryItem(
        id: widget.itemToEdit?.id,
        name: _nameController.text,
        photo: _photoController.text.isEmpty ? null : _photoController.text,
        categories: _selectedCategories,
        type: _selectedType,
      );
      widget.onItemAdded(item);
      Navigator.of(context).pop();
    }
  }

  String _getTypeName(FoodType type) {
    switch (type) {
      case FoodType.drink:
        return 'Bebida';
      case FoodType.protein:
        return 'Proteína';
      case FoodType.carbohydrate:
        return 'Carboidrato';
      case FoodType.fruit:
        return 'Fruta';
      case FoodType.grain:
        return 'Grão';
    }
  }

  String _getCategoryName(MealCategory category) {
    switch (category) {
      case MealCategory.breakfast:
        return 'Café';
      case MealCategory.lunch:
        return 'Almoço';
      case MealCategory.dinner:
        return 'Janta';
    }
  }
}
