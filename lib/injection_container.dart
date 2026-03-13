import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:quizapp/data/datasources/quiz_remote_data_source.dart';
import 'package:quizapp/domain/repositories/quiz_repository_impl.dart';
import 'package:quizapp/domain/repositories/quiz_repository.dart';
import 'package:quizapp/domain/repositories/profile_repository.dart';
import 'package:quizapp/domain/usecases/start_quiz.dart';
import 'package:quizapp/presentation/blocs/quiz_bloc.dart';
import 'package:quizapp/presentation/blocs/profile_bloc.dart';
import 'package:quizapp/presentation/blocs/profile_event.dart';

import 'data/datasources/profile_remote_data_source.dart';
import 'domain/entities/quiz_settings.dart';
import 'domain/repositories/profile_repository_imp.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // -------------------------
  // Blocs
  // -------------------------
  sl.registerFactory(() => QuizBloc(startQuiz: sl()));

  sl.registerFactory(
        () => ProfileBloc(repository: sl())..add(LoadProfile()),
  );

  // -------------------------
  // Use cases
  // -------------------------

  // ✅ Register StartQuizImpl AS StartQuiz so QuizBloc can resolve it
  sl.registerLazySingleton<StartQuiz>(
        () => StartQuizImpl(repository: sl()),
  );

  // -------------------------
  // Repositories
  // -------------------------
  sl.registerLazySingleton<QuizRepository>(
        () => QuizRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(remoteDatasource: sl()),
  );

  // -------------------------
  // Data sources
  // -------------------------
  sl.registerLazySingleton<QuizRemoteDataSource>(
        () => QuizRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton(
        () => ProfileRemoteDatasource(),
  );

  // -------------------------
  // External
  // -------------------------
  sl.registerLazySingleton(() => http.Client());
}

// ── StartQuiz implementation ─────────────────────────────────────
class StartQuizImpl implements StartQuiz {
  final QuizRepository repository;

  StartQuizImpl({required this.repository});

  @override
  Future<void> call(QuizSettings settings) async {
    // Delegate to repository if needed, or just a no-op for now
  }
}