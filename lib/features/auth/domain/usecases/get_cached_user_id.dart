import 'package:vezu/features/auth/domain/repositories/auth_repository.dart';

class GetCachedUserIdUseCase {
  GetCachedUserIdUseCase(this._repository);

  final AuthRepository _repository;

  Future<String?> call() {
    return _repository.getCachedUserId();
  }
}

