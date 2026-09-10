import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../widgets/exercise_card.dart';
import 'library_screen.dart';

class DayScreen extends StatefulWidget {
  final String dayName;
  final ProfileModel profile;
  final Function(ProfileModel) onProfileUpdated;

  const DayScreen(
      {super.key,
      required this.dayName,
      required this.profile,
      required this.onProfileUpdated});

  @override
  State<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  bool _isEditMode = false;
  late List<ExerciseModel> _dayExercises;

  @override
  void initState() {
    super.initState();
    _dayExercises = widget.profile.schedule[widget.dayName] ?? [];
  }

  void _saveUpdates() {
    widget.profile.schedule[widget.dayName] = _dayExercises;
    widget.onProfileUpdated(widget.profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dayName),
        actions: [
          TextButton.icon(
            icon: Icon(_isEditMode ? Icons.done : Icons.edit,
                color: Colors.white),
            label: Text(_isEditMode ? "View Mode" : "Edit Mode",
                style: const TextStyle(color: Colors.white)),
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
          )
        ],
      ),
      body: _dayExercises.isEmpty
          ? const Center(child: Text("No training added for this day."))
          : ListView.builder(
              itemCount: _dayExercises.length,
              itemBuilder: (context, index) {
                return ExerciseCard(
                  exercise: _dayExercises[index],
                  isEditMode: _isEditMode,
                  onRemove: () {
                    setState(() => _dayExercises.removeAt(index));
                    _saveUpdates();
                  },
                );
              },
            ),
      floatingActionButton: _isEditMode
          ? FloatingActionButton.extended(
              onPressed: () async {
                final added = await Navigator.push<List<ExerciseModel>>(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            LibraryScreen(currentExercises: _dayExercises)));
                if (added != null && added.isNotEmpty) {
                  setState(() => _dayExercises.addAll(added));
                  _saveUpdates();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Training"),
            )
          : null,
    );
  }
}
