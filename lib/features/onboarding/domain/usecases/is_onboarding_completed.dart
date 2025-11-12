import 'package:vezu/features/onboarding/domain/repositories/onboarding_repository.dart';

class IsOnboardingCompletedUseCase {
  IsOnboardingCompletedUseCase(this._repository);

  final OnboardingRepository _repository;

  Future<bool> call() {
    return _repository.isOnboardingCompleted();
  }
}

