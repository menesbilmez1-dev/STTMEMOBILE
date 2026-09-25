import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import '../l10n/app_localizations.dart';

class EntryEditorSheet extends StatefulWidget {
  const EntryEditorSheet({super.key, required this.initialValue});

  final String initialValue;

  @override
  State<EntryEditorSheet> createState() => _EntryEditorSheetState();
}

class _EntryEditorSheetState extends State<EntryEditorSheet> {
  late TextEditingController _controller;
  String _selectedCategory = '';
  String _selectedType = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final config = entryProvider.config;

    // Default values if no config is loaded
    final categories = config?.categories ?? [];

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.editEntryTitle,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: l10n.textLabel,
                  ),
                ),
                const SizedBox(height: 16),
                if (categories.isNotEmpty) ...[
                  Text(l10n.selectCategory),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategory.isEmpty 
                        ? (categories.isNotEmpty ? categories[0].name : '') 
                        : _selectedCategory,
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.name,
                        child: Text(cat.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value ?? '';
                        _selectedType = ''; // Reset type when category changes
                      });
                      setSheetState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_selectedCategory.isNotEmpty) ...[
                    Text(l10n.selectType),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedType.isEmpty 
                          ? (categories.firstWhere((c) => c.name == _selectedCategory).types.isNotEmpty 
                             ? categories.firstWhere((c) => c.name == _selectedCategory).types[0] 
                             : '') 
                          : _selectedType,
                      items: categories
                          .firstWhere((c) => c.name == _selectedCategory)
                          .types
                          .map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value ?? '';
                        });
                        setSheetState(() {});
                      },
                    ),
                  ],
                ] else ...[
                  Text(l10n.configMissingError),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (_selectedCategory.isEmpty || _selectedType.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.selectCategoryAndTypeError)),
                          );
                          return;
                        }
                        await entryProvider.addEntryWithDetails(
                          value: _controller.text,
                          category: _selectedCategory,
                          type: _selectedType,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text(l10n.save),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
