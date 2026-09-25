import 'package:get_it/get_it.dart';
import 'package:stt_merve/services/api_service.dart';
import 'package:stt_merve/services/database_service.dart';
import 'package:stt_merve/services/speech_service.dart';
import 'package:stt_merve/services/speech_parser_service.dart';
import 'package:stt_merve/services/haptic_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Services
  final dbService = DatabaseService();
  await dbService.init();
  sl.registerSingleton<DatabaseService>(dbService);

  sl.registerLazySingleton<ApiService>(() => ApiService(baseUrl: sl<DatabaseService>().getServerUrl()));
  sl.registerLazySingleton<SpeechService>(() => SpeechService());
  sl.registerLazySingleton<SpeechParserService>(() => SpeechParserService());
  sl.registerLazySingleton<HapticService>(() => HapticService());
}
