import 'package:vezu/features/auth/domain/entities/user_entity.dart';
import 'package:vezu/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity?> call() {
    return _repository.getCurrentUser();
  }
}

