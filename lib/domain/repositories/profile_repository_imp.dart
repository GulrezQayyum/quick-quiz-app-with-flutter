// lib/data/repositories/profile_repository_impl.dart
import 'package:quizapp/data/datasources/profile_remote_data_source.dart';
import 'package:quizapp/domain/entities/profile_model.dart';
import 'package:quizapp/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource remoteDatasource;

  ProfileRepositoryImpl({required this.remoteDatasource});

  @override
  Future<UserProfile> fetchProfile() async {
    final data = await remoteDatasource.fetchProfile();
    return UserProfile.fromMap(data);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await remoteDatasource.saveProfile(profile.toMap());
  }

  @override
  Future<void> awardXP(int xp) async {
    await remoteDatasource.awardXP(xp); // delegate to datasource (which has _auth & _firestore)
  }
}