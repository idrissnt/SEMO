// void registerAuthDependencies() {
//   // Register use cases
//   sl.registerFactory(() => AuthUseCases(
//         authRepository: sl<UserAuthRepository>(),
//       ));

//   // Register BLoCs
//   sl.registerFactory(() => AuthBloc(
//         authUseCases: sl<AuthUseCases>(),
//       ));
// }
