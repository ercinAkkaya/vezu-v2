import 'package:vezu/features/auth/domain/entities/user_entity.dart';
import 'package:vezu/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  SignInWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call() {
    return _repository.signInWithGoogle();
  }
}

