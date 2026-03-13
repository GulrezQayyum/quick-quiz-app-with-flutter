import 'package:quizapp/domain/repositories/quiz_repository.dart';
import 'package:quizapp/data/datasources/quiz_remote_data_source.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource remoteDataSource;

  QuizRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> startQuiz() async {
    // For now just forward to datasource
    await remoteDataSource.fetchQuiz();
  }
}
