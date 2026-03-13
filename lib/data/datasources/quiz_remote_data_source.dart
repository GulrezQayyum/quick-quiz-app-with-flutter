import 'package:http/http.dart' as http;

abstract class QuizRemoteDataSource {
  Future<void> fetchQuiz();
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final http.Client client;

  QuizRemoteDataSourceImpl({required this.client});

  @override
  Future<void> fetchQuiz() async {
    // TODO: implement API call
    print("Fetching quiz from API...");
  }
}
