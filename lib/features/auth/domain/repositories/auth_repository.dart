import 'package:vezu/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity?> getCurrentUser();
  Future<String?> getCachedUserId();
  Future<void> signOut();
  Future<UserEntity> updateUserProfile({
    String? firstName,
    String? lastName,
    String? gender,
    int? age,
    String? profilePhotoPath,
  });
}

