import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String _profileKey = 'profile';

class ProfileData {
  final String name;
  final String photoUrl;
  final String novaMessage;

  const ProfileData({
    this.name = '',
    this.photoUrl = '',
    this.novaMessage = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'photoUrl': photoUrl,
        'novaMessage': novaMessage,
      };

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      name: json['name'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      novaMessage: json['novaMessage'] as String? ?? '',
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileData> {
  ProfileNotifier() : super(_load());

  static ProfileData _load() {
    try {
      final raw = Hive.box('finora_state').get(_profileKey);
      if (raw == null) return const ProfileData();
      return ProfileData.fromJson(
          Map<String, dynamic>.from(raw as Map));
    } catch (_) {
      return const ProfileData();
    }
  }

  void _save() {
    try {
      Hive.box('finora_state').put(_profileKey, state.toJson());
    } catch (_) {
      // Never crash on storage failure.
    }
  }

  void updateProfile({
    String? name,
    String? photoUrl,
    String? novaMessage,
  }) {
    state = ProfileData(
      name: name ?? state.name,
      photoUrl: photoUrl ?? state.photoUrl,
      novaMessage: novaMessage ?? state.novaMessage,
    );
    _save();
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileData>((ref) {
  return ProfileNotifier();
});
