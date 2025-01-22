import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External Services
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    ),
  );
  
  getIt.registerLazySingleton<http.Client>(
    () => http.Client(),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      client: getIt<http.Client>(),
      storage: getIt<FlutterSecureStorage>(),
    ),
  );

  // Debug: Print all stored tokens
  final storage = getIt<FlutterSecureStorage>();
  try {
    final accessToken = await storage.read(key: 'access_token');
    final refreshToken = await storage.read(key: 'refresh_token');
    
    print('Debug - Stored Tokens:');
    print('Access Token: ${accessToken != null ? 'EXISTS' : 'NULL'}');
    print('Refresh Token: ${refreshToken != null ? 'EXISTS' : 'NULL'}');
  } catch (e) {
    print('Error reading tokens during service locator setup: $e');
  }

  // BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt<AuthRepository>(),
    ),
  );
}
