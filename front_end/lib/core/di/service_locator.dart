import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/store_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/store_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../domain/services/auth_service.dart';

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

  // Register auth service
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(
      storage: getIt<FlutterSecureStorage>(),
    ),
  );

  // Register repositories with optional auth
  getIt.registerLazySingleton<StoreRepository>(
    () => StoreRepositoryImpl(
      client: getIt<http.Client>(),
      authService: getIt<AuthService>(),
    ),
  );

  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      client: getIt<http.Client>(),
      authService: getIt<AuthService>(),
    ),
  );

  getIt.registerLazySingleton<RecipeRepository>(
    () => RecipeRepositoryImpl(
      client: getIt<http.Client>(),
      authService: getIt<AuthService>(),
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
