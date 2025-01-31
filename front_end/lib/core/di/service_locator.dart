import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/store_model.dart';
import '../../core/config/app_config.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/store_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/store_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../domain/services/auth_service.dart';
import 'dart:developer' as developer;
import '../utils/logger.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  try {
    // Initialize logger
    final logger = AppLogger();
    await logger.initialize();

    logger.debug('Setting up service locator');

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

    // Config
    getIt.registerLazySingleton<AppConfig>(
      () => AppConfig(),
    );

    // Register Hive box
    try {
      logger.debug('Getting Hive box in service locator');
      final storeBox = await Hive.openBox<StoreModel>('stores');
      logger.debug('Successfully got Hive box in service locator');
      getIt.registerLazySingleton<Box<StoreModel>>(() => storeBox);
    } catch (e, stackTrace) {
      logger.error('Error getting Hive box in service locator',
          error: e, stackTrace: stackTrace);
      rethrow;
    }

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

    // Register repositories
    getIt.registerLazySingleton<StoreRepository>(
      () => StoreRepositoryImpl(
        client: getIt<http.Client>(),
        storeBox: getIt<Box<StoreModel>>(),
      ),
    );

    getIt.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(
        client: getIt<http.Client>(),
      ),
    );

    getIt.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(
        client: getIt<http.Client>(),
      ),
    );

    getIt.registerLazySingleton<RecipeRepository>(
      () => RecipeRepositoryImpl(
        client: getIt<http.Client>(),
      ),
    );

    // Debug: Log stored tokens
    final storage = getIt<FlutterSecureStorage>();
    try {
      final accessToken = await storage.read(key: 'access_token');
      final refreshToken = await storage.read(key: 'refresh_token');

      logger.debug('Stored Tokens', error: {
        'Access Token': accessToken != null ? 'EXISTS' : 'NULL',
        'Refresh Token': refreshToken != null ? 'EXISTS' : 'NULL',
      });
    } catch (e, stackTrace) {
      logger.error('Error reading tokens during service locator setup',
          error: e, stackTrace: stackTrace);
    }

    // BLoCs
    getIt.registerFactory<AuthBloc>(
      () => AuthBloc(
        authRepository: getIt<AuthRepository>(),
      ),
    );
  } catch (e, stackTrace) {
    // Use developer.log for critical initialization errors
    developer.log(
      'Critical error in service locator setup',
      name: 'ServiceLocator',
      error: e,
      stackTrace: stackTrace,
      level: 1000, // Error level
    );
    rethrow;
  }
}
