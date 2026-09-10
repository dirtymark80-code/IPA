// lib/presentation/screens/week_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../data/models/models.dart';
import 'day_screen.dart';

class WeekScreen extends StatefulWidget {
  final ProfileModel profile;
  final Function(ProfileModel) onProfileUpdated;

  const WeekScreen({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
  });

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  // Master list of available custom icons
  final Map<String, IconData> iconChoices = {
    'calendar': Icons.calendar_today,
    'dumbbell': Icons.fitness_center,
    'run': Icons.directions_run,
    'bike': Icons.directions_bike,
    'rest': Icons.bedtime,
    'arm': Icons.sports_mma,
    'chest': Icons.accessibility_new,
    'heart': Icons.favorite,
    'bolt': Icons.bolt,
  };

  void _editDay(BuildContext context, String day) {
    TextEditingController labelController =
        TextEditingController(text: widget.profile.dayLabels[day] ?? '');
    String currentIcon = widget.profile.dayIcons[day] ?? 'calendar';

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Customize $day"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: labelController,
                    decoration: const InputDecoration(
                      labelText: "Custom Text (e.g., Legs Day)",
                      hintText: "Leave blank for default",
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text("Select an Icon:"),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: iconChoices.entries.map((entry) {
                      final isSelected = entry.key == currentIcon;
                      return InkWell(
                        onTap: () {
                          setStateDialog(() => currentIcon = entry.key);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.redAccent.withValues(alpha: 0.2)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.redAccent
                                  : Colors.grey.shade800,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(entry.value,
                              color:
                                  isSelected ? Colors.redAccent : Colors.white),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.profile.dayLabels[day] =
                          labelController.text.trim();
                      widget.profile.dayIcons[day] = currentIcon;
                    });
                    widget.onProfileUpdated(widget.profile);
                    Navigator.pop(context);
                  },
                  child: const Text("Save",
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardSize = (screenWidth - 64) / 3;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.profile.name}'s Training"),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.fitness_center),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                "Tip: Long-press a day card to customize its icon and name.",
                style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                    fontSize: 13),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16.0,
                runSpacing: 16.0,
                children: AppConstants.daysOfWeek.map((day) {
                  final exerciseCount =
                      (widget.profile.schedule[day] ?? []).length;
                  return _buildDayCard(context, day, exerciseCount, cardSize);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      // The copyright bar is cleanly separated here
      bottomNavigationBar: Container(
        color: const Color(0xFFD32F2F),
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: const Text(
          "Copyright Ahmed S. Barwari ©",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDayCard(
      BuildContext context, String day, int exerciseCount, double size) {
    final bool hasExercises = exerciseCount > 0;

    // Check for custom icons and labels
    final String customLabel = widget.profile.dayLabels[day] ?? '';
    final String iconKey = widget.profile.dayIcons[day] ??
        (hasExercises ? 'dumbbell' : 'calendar');

    final IconData displayIcon = iconChoices[iconKey] ?? Icons.calendar_today;
    final String subtitleText =
        customLabel.isNotEmpty ? customLabel : "$exerciseCount workouts";

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DayScreen(
                dayName: day,
                profile: widget.profile,
                onProfileUpdated: (updatedProfile) {
                  setState(() {}); // Refresh grid when returning from DayScreen
                  widget.onProfileUpdated(updatedProfile);
                },
              ),
            ),
          );
        },
        onLongPress: () => _editDay(context, day), // Triggers customizer dialog
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasExercises
                  ? Colors.redAccent.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                displayIcon,
                color: hasExercises || iconKey != 'calendar'
                    ? Colors.redAccent
                    : Colors.grey.shade600,
                size: 28,
              ),
              const SizedBox(height: 12),
              Text(
                day.substring(0, 3).toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  subtitleText,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: hasExercises || customLabel.isNotEmpty
                        ? Colors.white70
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
