import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../services/profile_service.dart';
import '../services/data_service.dart';
import '../utils/design_system.dart';

class StartScreen extends StatefulWidget {
  final VoidCallback onStart;

  const StartScreen({
    super.key,
    required this.onStart,
  });

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final ProfileService _profileService = ProfileService();
  final DataService _dataService = DataService();

  final List<String> _defaultCategories = [
    "nature", "science", "animals", "anthropology", "places", 
    "sociology", "art", "mathematics", "games", "technology", 
    "music", "human sexuality"
  ];

  final Set<String> _selectedCategories = {};
  final List<String> _customCategories = [];
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];

  @override
  void initState() {
    super.initState();
    // Default select a few categories
    _selectedCategories.addAll(['nature', 'science', 'technology']);
    // Lazy load full category list for search
    _dataService.loadCategoryNames();
  }

  void _onCategorySearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    
    // Search within available category names from memory cache
    final results = _dataService.allCategoryNames
        .where((cat) => cat.toLowerCase().contains(lowerQuery))
        .take(10) // Limit to 10 autocompletions
        .toList();

    setState(() {
      _searchResults = results;
    });
  }

  void _addCustomCategory(String cat) {
    if (!_customCategories.contains(cat)) {
      setState(() {
        _customCategories.add(cat);
        _selectedCategories.add(cat);
        _searchResults = [];
        _searchController.clear();
      });
    }
  }

  void _proceedToFeed() async {
    // Apply scores for selected categories
    for (final cat in _selectedCategories) {
      final isDefault = _defaultCategories.contains(cat);
      // Default categories get 1000 score, custom get 5000
      _profileService.categoryScores[cat] = isDefault ? 1000 : 5000;
    }

    // Save profile to database
    await _profileService.saveProfile();
    widget.onStart();
  }

  String _translateCategory(String cat) {
    switch (cat) {
      case 'nature': return S.of(context).nature;
      case 'science': return S.of(context).science;
      case 'animals': return S.of(context).animals;
      case 'anthropology': return S.of(context).anthropology;
      case 'places': return S.of(context).places;
      case 'sociology': return S.of(context).sociology;
      case 'art': return S.of(context).art;
      case 'mathematics': return S.of(context).mathematics;
      case 'games': return S.of(context).games;
      case 'technology': return S.of(context).technology;
      case 'music': return S.of(context).music;
      case 'human sexuality': return S.of(context).humanSexuality;
      default: return cat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final themeData = Theme.of(context);

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  S.of(context).appTitle,
                  style: themeData.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Wikipedia, doomscroll style.',
                  style: themeData.textTheme.titleMedium?.copyWith(
                    color: colors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  S.of(context).dataSetupDescription,
                  style: themeData.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 24),
                
                // Picker Title
                Text(
                  S.of(context).chooseInterests,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                
                // Wrap of default interests
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _defaultCategories.map((cat) {
                            final isSelected = _selectedCategories.contains(cat);
                            return FilterChip(
                              label: Text(_translateCategory(cat)),
                              selected: isSelected,
                              selectedColor: AppColors.primary.withValues(alpha: 0.2),
                              checkmarkColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? AppColors.primary : colors.divider,
                                ),
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedCategories.add(cat);
                                  } else {
                                    _selectedCategories.remove(cat);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        
                        // Custom categories wrap
                        if (_customCategories.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(S.of(context).customInterests, style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _customCategories.map((cat) {
                              final isSelected = _selectedCategories.contains(cat);
                              return InputChip(
                                label: Text(cat),
                                selected: isSelected,
                                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedCategories.add(cat);
                                    } else {
                                      _selectedCategories.remove(cat);
                                    }
                                  });
                                },
                                onDeleted: () {
                                  setState(() {
                                    _customCategories.remove(cat);
                                    _selectedCategories.remove(cat);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // Category Search bar
                        Text(
                          S.of(context).searchCategories,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: S.of(context).searchHint,
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: colors.surfaceBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: _onCategorySearch,
                        ),
                        
                        // Search autocompletion list
                        if (_searchResults.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: colors.surfaceBackground,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final cat = _searchResults[index];
                                return ListTile(
                                  title: Text(cat),
                                  trailing: const Icon(Icons.add, color: AppColors.primary),
                                  onTap: () => _addCustomCategory(cat),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 20),
                        
                        Text(
                          S.of(context).adultWarning,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textDimmed,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    onPressed: _proceedToFeed,
                    child: Text(
                      S.of(context).continueButton,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
