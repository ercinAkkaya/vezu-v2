import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vezu/features/onboarding/domain/usecases/complete_onboarding.dart';

class OnboardingCubit extends Cubit<int> {
  OnboardingCubit(this._completeOnboardingUseCase) : super(0);

  final CompleteOnboardingUseCase _completeOnboardingUseCase;

  void setPage(int index) {
    if (index != state) {
      emit(index);
    }
  }

  Future<void> completeOnboarding() {
    return _completeOnboardingUseCase();
  }
}
