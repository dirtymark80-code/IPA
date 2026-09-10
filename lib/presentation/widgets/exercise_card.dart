// lib/presentation/widgets/exercise_card.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/models.dart';

class ExerciseCard extends StatefulWidget {
  final ExerciseModel exercise;
  final bool isEditMode;
  final VoidCallback onRemove;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.isEditMode,
    required this.onRemove,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  bool _isExpanded = false;

  Future<void> _launchYouTubeUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasVideo = widget.exercise.videoUrl != null &&
        widget.exercise.videoUrl!.isNotEmpty;
    final bool hasMedia = widget.exercise.mediaPath != null &&
        widget.exercise.mediaPath!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: const Color(0xFF1E1E1E),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.exercise.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Sets: ${widget.exercise.sets}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (hasVideo)
                    IconButton(
                      icon: const Icon(Icons.video_library,
                          color: Colors.redAccent, size: 28),
                      tooltip: "Open YouTube Tutorial",
                      onPressed: () =>
                          _launchYouTubeUrl(context, widget.exercise.videoUrl!),
                    ),
                  if (widget.isEditMode)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: widget.onRemove,
                    ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                if (hasMedia)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(widget.exercise.mediaPath!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Text(
                        "Error loading attached image",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  )
                else
                  const Text(
                    "No media attached.",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
