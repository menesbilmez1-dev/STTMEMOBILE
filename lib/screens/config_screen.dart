import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import '../models/app_config.dart';
import '../l10n/app_localizations.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  @override
  Widget build(BuildContext context) {
    final entryProvider = context.watch<EntryProvider>();
    final config = entryProvider.config;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.currentConfigurationTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.serverAddressLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              entryProvider.serverUrl,
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.categoriesAndTypesTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (config != null)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addCategory(entryProvider),
                    tooltip: 'Add Category',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (config == null || config.categories.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(l10n.noConfigurationLoaded),
                ),
              )
            else
              _buildCategoriesList(entryProvider, config),
          ],
        ),
      ),
    );
  }
  Widget _buildCategoriesList(EntryProvider entryProvider, AppConfig config) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: config.categories.length,
      itemBuilder: (context, index) {
        final category = config.categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Category Name
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () => _editCategoryName(entryProvider, category),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        category.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                // Types
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: () => _editTypes(entryProvider, category),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: category.types.map((type) {
                        return Chip(
                          label: Text(type, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.blue.shade50,
                          padding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Actions
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCategory(entryProvider, category),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addCategory(EntryProvider entryProvider) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Category Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final newCategory = CategoryConfig(
                  name: nameController.text.trim(),
                  types: [],
                );
                final currentConfig = entryProvider.config!;
                final updatedCategories = List<CategoryConfig>.from(currentConfig.categories)
                  ..add(newCategory);
                entryProvider.updateLocalConfig(AppConfig(categories: updatedCategories));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }


  void _deleteCategory(EntryProvider entryProvider, CategoryConfig category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final currentConfig = entryProvider.config!;
              final updatedCategories = currentConfig.categories.where((c) => c != category).toList();
              entryProvider.updateLocalConfig(AppConfig(categories: updatedCategories));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editCategoryName(EntryProvider entryProvider, CategoryConfig category) {
    final nameController = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Category Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final trimmedName = nameController.text.trim();
              if (trimmedName.isNotEmpty) {
                final currentConfig = entryProvider.config!;
                final updatedCategories = currentConfig.categories.map((c) {
                  if (c == category) {
                    return CategoryConfig(name: trimmedName, types: List.from(c.types));
                  }
                  return c;
                }).toList();
                entryProvider.updateLocalConfig(AppConfig(categories: updatedCategories));
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editTypes(EntryProvider entryProvider, CategoryConfig category) {
    final typesController = TextEditingController();
    final currentTypes = List<String>.from(category.types);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Edit Types for ${category.name}'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: currentTypes.map((type) {
                      return Chip(
                        label: Text(type),
                        onDeleted: () {
                          setDialogState(() {
                            currentTypes.remove(type);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: typesController,
                    decoration: InputDecoration(
                      labelText: 'New Type',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          final trimmedValue = typesController.text.trim();
                          if (trimmedValue.isNotEmpty && !currentTypes.contains(trimmedValue)) {
                            setDialogState(() {
                              currentTypes.add(trimmedValue);
                              typesController.clear();
                            });
                          }
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      final trimmedValue = value.trim();
                      if (trimmedValue.isNotEmpty && !currentTypes.contains(trimmedValue)) {
                        setDialogState(() {
                          currentTypes.add(trimmedValue);
                          typesController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final currentConfig = entryProvider.config!;
                  final updatedCategories = currentConfig.categories.map((c) {
                    if (c == category) {
                      return CategoryConfig(name: c.name, types: List.from(currentTypes));
                    }
                    return c;
                  }).toList();
                  entryProvider.updateLocalConfig(AppConfig(categories: updatedCategories));
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

}
