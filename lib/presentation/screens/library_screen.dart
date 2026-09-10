// lib/presentation/screens/library_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../data/models/models.dart';
import '../../data/storage_service.dart';

class LibraryScreen extends StatefulWidget {
  final List<ExerciseModel> currentExercises;

  const LibraryScreen({super.key, required this.currentExercises});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Map<String, dynamic>> _available = [];
  final List<ExerciseModel> _selectedToAdd = [];
  final ImagePicker _picker = ImagePicker();

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedLibrary = prefs.getString('custom_exercise_library');

    if (savedLibrary != null) {
      final List decoded = jsonDecode(savedLibrary);
      setState(() {
        _available = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } else {
      setState(() {
        _available = AppConstants.masterExerciseLibrary
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      });
      _saveLibrary();
    }
  }

  Future<void> _saveLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_exercise_library', jsonEncode(_available));
  }

  Future<void> _launchYouTubeUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    }
  }

  void _showExerciseDialog(
      {Map<String, dynamic>? existingExercise, int? editIndex}) {
    TextEditingController nameController =
        TextEditingController(text: existingExercise?['name'] ?? '');
    TextEditingController setsController = TextEditingController(
        text: existingExercise?['sets'] ?? '3 sets of 10');
    TextEditingController videoUrlController =
        TextEditingController(text: existingExercise?['videoUrl'] ?? '');
    String? selectedImagePath = existingExercise?['mediaPath'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          title: Text(existingExercise == null
              ? "Create Custom Exercise"
              : "Edit Exercise"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: "Exercise Name (e.g. Lunges)"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: setsController,
                  decoration: const InputDecoration(
                      labelText: "Sets & Reps (e.g. 3 sets of 10)"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: videoUrlController,
                  decoration: const InputDecoration(
                      labelText: "YouTube / Video URL (Optional)"),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final XFile? image = await _picker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            setStateDialog(() {
                              selectedImagePath = image.path;
                            });
                          }
                        },
                        icon: const Icon(Icons.image),
                        label: Text(
                            selectedImagePath == null ? "Add Image" : "Change"),
                      ),
                    ),
                    if (selectedImagePath != null) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          setStateDialog(() {
                            selectedImagePath = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700]),
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.white),
                        label: const Text("Remove",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ],
                ),
                if (selectedImagePath != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(selectedImagePath!),
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final oldName = existingExercise?['name'];
                  setState(() {
                    final updatedData = {
                      'name': nameController.text.trim(),
                      'sets': setsController.text.isNotEmpty
                          ? setsController.text.trim()
                          : '3 sets of 10',
                      'mediaPath': selectedImagePath,
                      'videoUrl': videoUrlController.text.trim().isNotEmpty
                          ? videoUrlController.text.trim()
                          : null,
                    };

                    if (editIndex != null) {
                      _available[editIndex] = updatedData;
                    } else {
                      _available.add(updatedData);
                    }
                  });
                  await _saveLibrary();

                  // Automatically propagate edits across all stored profiles and schedule days
                  if (editIndex != null && oldName != null) {
                    final storage = StorageService();
                    final profiles = await storage.loadProfiles();
                    bool changed = false;
                    for (var profile in profiles) {
                      profile.schedule.forEach((day, exercises) {
                        for (int i = 0; i < exercises.length; i++) {
                          if (exercises[i].name == oldName) {
                            exercises[i] = ExerciseModel(
                              id: exercises[i].id,
                              name: nameController.text.trim(),
                              sets: setsController.text.isNotEmpty
                                  ? setsController.text.trim()
                                  : exercises[i].sets,
                              mediaPath: selectedImagePath,
                              videoUrl:
                                  videoUrlController.text.trim().isNotEmpty
                                      ? videoUrlController.text.trim()
                                      : null,
                            );
                            changed = true;
                          }
                        }
                      });
                    }
                    if (changed) {
                      await storage.saveProfiles(profiles);
                    }
                  }

                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
              child: Text(existingExercise == null ? "Add" : "Save"),
            )
          ],
        );
      }),
    );
  }

  void _confirmDelete(String exerciseName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Exercise"),
        content: Text("Are you sure you want to delete '$exerciseName'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _available.removeWhere((e) => e['name'] == exerciseName);
                _selectedToAdd.removeWhere((e) => e.name == exerciseName);
              });
              _saveLibrary();
              Navigator.pop(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSelection(bool? val, Map<String, dynamic> ex, int index) {
    setState(() {
      if (val == true) {
        _selectedToAdd.add(ExerciseModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() +
              index.toString(),
          name: ex['name'] as String,
          sets: ex['sets'] as String,
          mediaPath: ex['mediaPath'] as String?,
          videoUrl: ex['videoUrl'] as String?,
        ));
      } else {
        _selectedToAdd.removeWhere((e) => e.name == ex['name']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredExercises = _available.where((ex) {
      final name = ex['name'] as String;
      return name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Exercises"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.pop(context, _selectedToAdd),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: filteredExercises.isEmpty
                ? const Center(
                    child: Text("No exercises found.",
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      final ex = filteredExercises[index];
                      final String name = ex['name'] as String;
                      final String sets = ex['sets'] as String;
                      final bool hasMedia = ex['mediaPath'] != null;
                      final bool hasVideo = ex['videoUrl'] != null &&
                          (ex['videoUrl'] as String).isNotEmpty;
                      final isSelected =
                          _selectedToAdd.any((e) => e.name == name);

                      final masterIndex = _available
                          .indexWhere((element) => element['name'] == name);

                      return ListTile(
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (val) => _toggleSelection(val, ex, index),
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(name)),
                            if (hasMedia) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.image,
                                  size: 16, color: Colors.grey),
                            ],
                            if (hasVideo) ...[
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () => _launchYouTubeUrl(ex['videoUrl']),
                                child: const Icon(Icons.video_library,
                                    size: 20, color: Colors.redAccent),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(sets),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.blueAccent),
                              onPressed: () => _showExerciseDialog(
                                  existingExercise: ex, editIndex: masterIndex),
                              tooltip: "Edit Exercise",
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              onPressed: () => _confirmDelete(name),
                              tooltip: "Delete Exercise",
                            ),
                          ],
                        ),
                        onTap: () => _toggleSelection(!isSelected, ex, index),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExerciseDialog(),
        tooltip: "Create Custom Exercise",
        child: const Icon(Icons.add),
      ),
    );
  }
}
