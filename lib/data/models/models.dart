// lib/data/models/models.dart

class ExerciseModel {
  final String id;
  final String name;
  final String sets;
  final String? mediaPath;
  final String? videoUrl;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.sets,
    this.mediaPath,
    this.videoUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sets': sets,
        'mediaPath': mediaPath,
        'videoUrl': videoUrl,
      };

  factory ExerciseModel.fromJson(Map<String, dynamic> json) => ExerciseModel(
        id: json['id'] as String,
        name: json['name'] as String,
        sets: json['sets'] as String,
        mediaPath: json['mediaPath'] as String?,
        videoUrl: json['videoUrl'] as String?,
      );
}

class ProfileModel {
  String name;
  Map<String, List<ExerciseModel>> schedule;
  Map<String, String> dayLabels;
  Map<String, String> dayIcons;

  ProfileModel({
    required this.name,
    required this.schedule,
    required this.dayLabels,
    required this.dayIcons,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'schedule': schedule
            .map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
        'dayLabels': dayLabels,
        'dayIcons': dayIcons,
      };

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    var rawSchedule = json['schedule'] as Map<String, dynamic>? ?? {};
    Map<String, List<ExerciseModel>> parsedSchedule = {};
    rawSchedule.forEach((key, value) {
      var list = (value as List)
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList();
      parsedSchedule[key] = list;
    });

    return ProfileModel(
      name: json['name'] as String? ?? 'User',
      schedule: parsedSchedule,
      dayLabels: Map<String, String>.from(json['dayLabels'] ?? {}),
      dayIcons: Map<String, String>.from(json['dayIcons'] ?? {}),
    );
  }
}
