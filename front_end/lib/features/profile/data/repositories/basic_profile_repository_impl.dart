import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import 'package:semo/core/utils/result.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';
import 'package:semo/features/profile/domain/repositories/profile_repository.dart';
import 'package:semo/features/profile/domain/exceptions/profile_exceptions.dart';
import 'package:semo/core/services/token_service.dart';
import 'package:semo/features/profile/data/repositories/services/base_profile_service.dart';

/// Implementation of the BasicProfileRepository interface that delegates to specialized services
class BasicProfileRepositoryImpl implements BasicProfileRepository {
  final BaseProfileService _profileService;

  BasicProfileRepositoryImpl({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  }) : _profileService = BaseProfileService(
          dio: dio,
          tokenService: TokenService(
            dio: dio,
            storage: secureStorage,
          ),
        );

  @override
  Future<Result<User, BasicProfileException>> getCurrentUser() async {
    try {
      final user = await _profileService.getCurrentUser();
      return Result.success(user);
    } catch (e) {
      return Result.failure(BasicProfileException(e.toString()));
    }
  }

  @override
  Future<Result<User, BasicProfileException>> updateUserProfile({
    required String firstName,
    required String lastName,
    String? email,
    String? profilePhotoUrl,
    String? phoneNumber,
  }) async {
    try {
      final user = await _profileService.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        profilePhotoUrl: profilePhotoUrl,
        phoneNumber: phoneNumber,
      );
      return Result.success(user);
    } catch (e) {
      return Result.failure(BasicProfileException(e.toString()));
    }
  }

  @override
  Future<Result<bool, BasicProfileException>> deleteAccount() async {
    try {
      final result = await _profileService.deleteAccount();
      return Result.success(result);
    } catch (e) {
      return Result.failure(BasicProfileException(e.toString()));
    }
  }
}
