// lib/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/models.dart';
import '../../data/storage_service.dart';
import 'week_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storage = StorageService();
  List<ProfileModel> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final loaded = await _storage.loadProfiles();
    setState(() => _profiles = loaded);
  }

  void _createNewProfile() {
    TextEditingController controller = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("New Profile Name"),
            content: TextField(controller: controller),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")),
              TextButton(
                onPressed: () {
                  final newProfile = ProfileModel(
                    name: controller.text.trim().isNotEmpty
                        ? controller.text.trim()
                        : 'User',
                    schedule: {},
                    dayLabels: {},
                    dayIcons: {},
                  );
                  setState(() => _profiles.add(newProfile));
                  _storage.saveProfiles(_profiles);
                  Navigator.pop(context);
                },
                child: const Text("Create"),
              )
            ],
          );
        });
  }

  void _confirmDeleteProfile(ProfileModel profile) {
    // First warning dialog
    showDialog(
      context: context,
      builder: (context1) => AlertDialog(
        title: const Text("Delete Profile"),
        content: Text(
            "Are you sure you want to delete the profile '${profile.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context1),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context1);
              // Trigger second final warning
              _showFinalDeleteWarning(profile);
            },
            child: const Text("Continue",
                style: TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteWarning(ProfileModel profile) {
    // Second warning dialog
    showDialog(
      context: context,
      builder: (context2) => AlertDialog(
        title: const Text("⚠️ Final Warning"),
        content: Text(
            "This action cannot be undone. All workout routines, schedules, and data for '${profile.name}' will be permanently erased. Delete anyway?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context2),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context2);
              setState(() {
                _profiles.removeWhere((p) => p.name == profile.name);
              });
              _storage.saveProfiles(_profiles);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text("Profile '${profile.name}' has been deleted.")),
              );
            },
            child: const Text(
              "Delete Permanently",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _updateProfile(ProfileModel updated) {
    int index = _profiles.indexWhere((p) => p.name == updated.name);
    if (index != -1) {
      _profiles[index] = updated;
      _storage.saveProfiles(_profiles);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Profile")),
      body: _profiles.isEmpty
          ? const Center(
              child: Text("No profiles found. Create one below!",
                  style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: _profiles.length,
              itemBuilder: (context, index) {
                final profile = _profiles[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title:
                      Text(profile.name, style: const TextStyle(fontSize: 18)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          SharePlus.instance.share(
                            ShareParams(
                              text:
                                  "Check out my workout on My Fitness:\nProfile: ${profile.name}",
                            ),
                          );
                        },
                        tooltip: "Share Profile",
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent),
                        onPressed: () => _confirmDeleteProfile(profile),
                        tooltip: "Delete Profile",
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => WeekScreen(
                                profile: profile,
                                onProfileUpdated: _updateProfile)));
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewProfile,
        label: const Text("New Profile"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
