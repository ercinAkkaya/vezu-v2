import 'package:vezu/features/onboarding/domain/repositories/onboarding_repository.dart';

class CompleteOnboardingUseCase {
  CompleteOnboardingUseCase(this._repository);

  final OnboardingRepository _repository;

  Future<void> call() {
    return _repository.setOnboardingCompleted();
  }
}

