import 'package:vezu/features/auth/domain/entities/user_entity.dart';
import 'package:vezu/features/auth/domain/repositories/auth_repository.dart';

class UpdateUserProfileUseCase {
  UpdateUserProfileUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    String? firstName,
    String? lastName,
    String? gender,
    int? age,
    String? profilePhotoPath,
  }) {
    return _repository.updateUserProfile(
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      age: age,
      profilePhotoPath: profilePhotoPath,
    );
  }
}

