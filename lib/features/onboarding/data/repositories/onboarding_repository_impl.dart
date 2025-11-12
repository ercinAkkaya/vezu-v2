import 'package:vezu/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:vezu/features/onboarding/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._localDataSource);

  final OnboardingLocalDataSource _localDataSource;

  @override
  Future<bool> isOnboardingCompleted() {
    return _localDataSource.isOnboardingCompleted();
  }

  @override
  Future<void> setOnboardingCompleted() {
    return _localDataSource.setOnboardingCompleted();
  }
}

