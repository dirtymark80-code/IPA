import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/models.dart';

class StorageService {
  static const String _profilesKey = 'profiles_data';

  Future<List<ProfileModel>> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_profilesKey);
    if (data == null) return [];

    List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => ProfileModel.fromJson(e)).toList();
  }

  Future<void> saveProfiles(List<ProfileModel> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList =
        profiles.map((e) => e.toJson()).toList();
    await prefs.setString(_profilesKey, jsonEncode(jsonList));
  }
}
