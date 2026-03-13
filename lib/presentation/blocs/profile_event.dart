import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizapp/presentation/blocs/profile_state.dart';

import '../../domain/repositories/profile_repository_imp.dart';
import '../../domain/repositories/profile_repository_imp.dart' as _repository;


abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class StartEditing extends ProfileEvent {}

class CancelEditing extends ProfileEvent {}

class SaveProfile extends ProfileEvent {}

class UpdateField extends ProfileEvent {
  final String field;
  final String value;
  UpdateField(this.field, this.value);
}

class ToggleCategory extends ProfileEvent {
  final String category;
  ToggleCategory(this.category);
}

class AwardXP extends ProfileEvent {
  final int xp;
  AwardXP(this.xp);
}