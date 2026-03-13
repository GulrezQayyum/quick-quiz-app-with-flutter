// lib/domain/repositories/profile_repository.dart

import 'package:quizapp/domain/entities/profile_model.dart';

abstract class ProfileRepository {
  Future<UserProfile> fetchProfile();
  Future<void> saveProfile(UserProfile profile);
  Future<void> awardXP(int xp);
}