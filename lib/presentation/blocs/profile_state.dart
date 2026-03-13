import 'package:flutter/material.dart';

import '../../domain/entities/profile_model.dart';
import 'package:quizapp/domain/entities/profile_model.dart';

abstract class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  ProfileLoaded(this.profile);
}

class ProfileEditing extends ProfileState {
  final UserProfile original;
  final UserProfile draft;

  ProfileEditing({
    required this.original,
    required this.draft,
  });
}

class ProfileSaving extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}



