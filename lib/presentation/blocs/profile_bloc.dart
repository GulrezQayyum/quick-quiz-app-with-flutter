// lib/presentation/blocs/profile_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizapp/domain/repositories/profile_repository.dart';
import 'package:quizapp/presentation/blocs/profile_event.dart';
import 'package:quizapp/presentation/blocs/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc({required ProfileRepository repository})
      : _repository = repository,
        super(ProfileLoading()) {
    on<LoadProfile>(_onLoadProfile);
    on<StartEditing>(_onStartEditing);
    on<CancelEditing>(_onCancelEditing);
    on<UpdateField>(_onUpdateField);
    on<ToggleCategory>(_onToggleCategory);
    on<SaveProfile>(_onSaveProfile);
    on<AwardXP>(_onAwardXP);
  }

  // ── Load ───────────────────────────────────────────────────
  Future<void> _onLoadProfile(
      LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final profile = await _repository.fetchProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // ── Start editing ──────────────────────────────────────────
  void _onStartEditing(StartEditing event, Emitter<ProfileState> emit) {
    if (state is ProfileLoaded) {
      final profile = (state as ProfileLoaded).profile;
      emit(ProfileEditing(original: profile, draft: profile));
    }
  }

  // ── Cancel editing ─────────────────────────────────────────
  void _onCancelEditing(CancelEditing event, Emitter<ProfileState> emit) {
    if (state is ProfileEditing) {
      final original = (state as ProfileEditing).original;
      emit(ProfileLoaded(original));
    }
  }

  // ── Update a single text field ─────────────────────────────
  void _onUpdateField(UpdateField event, Emitter<ProfileState> emit) {
    if (state is ProfileEditing) {
      final current = (state as ProfileEditing);
      final updated = switch (event.field) {
        'name'       => current.draft.copyWith(name: event.value),
        'bio'        => current.draft.copyWith(bio: event.value),
        'location'   => current.draft.copyWith(location: event.value),
        'avatarSeed' => current.draft.copyWith(avatarSeed: event.value),
        _            => current.draft,
      };
      emit(ProfileEditing(original: current.original, draft: updated));
    }
  }

  // ── Toggle a favourite category ────────────────────────────
  void _onToggleCategory(ToggleCategory event, Emitter<ProfileState> emit) {
    if (state is ProfileEditing) {
      final current = state as ProfileEditing;
      final list = List<String>.from(current.draft.favoriteCategories);

      if (list.contains(event.category)) {
        list.remove(event.category);
      } else {
        list.add(event.category);
      }

      emit(ProfileEditing(
        original: current.original,
        draft: current.draft.copyWith(favoriteCategories: list),
      ));
    }
  }

  // ── Save ───────────────────────────────────────────────────
  Future<void> _onSaveProfile(
      SaveProfile event, Emitter<ProfileState> emit) async {
    if (state is ProfileEditing) {
      final draft = (state as ProfileEditing).draft;
      emit(ProfileSaving());
      try {
        await _repository.saveProfile(draft);
        emit(ProfileLoaded(draft));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    }
  }

  // ── Award XP ───────────────────────────────────────────────
  Future<void> _onAwardXP(AwardXP event, Emitter<ProfileState> emit) async {
    try {
      await _repository.awardXP(event.xp);
      // Reload so profile screen reflects new XP instantly
      final updated = await _repository.fetchProfile();
      emit(ProfileLoaded(updated));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}