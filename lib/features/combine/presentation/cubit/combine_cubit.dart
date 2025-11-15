import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vezu/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vezu/features/combine/domain/entities/combination_plan.dart';
import 'package:vezu/features/combine/domain/entities/combination_preference.dart';
import 'package:vezu/features/combine/domain/usecases/generate_combination.dart';
import 'package:vezu/features/wardrobe/domain/entities/clothing_item.dart';
import 'package:vezu/features/wardrobe/domain/usecases/watch_wardrobe_items.dart';

part 'combine_state.dart';

class CombineCubit extends Cubit<CombineState> {
  CombineCubit({
    required WatchWardrobeItemsUseCase watchWardrobeItemsUseCase,
    required GenerateCombinationUseCase generateCombinationUseCase,
    required AuthCubit authCubit,
  }) : _watchWardrobeItemsUseCase = watchWardrobeItemsUseCase,
       _generateCombinationUseCase = generateCombinationUseCase,
       _authCubit = authCubit,
       super(const CombineState());

  final WatchWardrobeItemsUseCase _watchWardrobeItemsUseCase;
  final GenerateCombinationUseCase _generateCombinationUseCase;
  final AuthCubit _authCubit;

  StreamSubscription<List<ClothingItem>>? _wardrobeSubscription;
  String? _currentUserId;

  void initialize() {
    final uid = _authCubit.state.user?.id;
    if (uid == null || uid.isEmpty) {
      return;
    }
    if (_currentUserId == uid) {
      return;
    }
    _currentUserId = uid;
    _wardrobeSubscription?.cancel();
    emit(state.copyWith(isWardrobeLoading: true));
    _wardrobeSubscription =
        _watchWardrobeItemsUseCase(WatchWardrobeItemsParams(uid: uid)).listen(
          (items) {
            emit(
              state.copyWith(
                wardrobeItems: items,
                isWardrobeLoading: false,
                resetError: true,
              ),
            );
          },
          onError: (error, stackTrace) {
            emit(
              state.copyWith(
                isWardrobeLoading: false,
                errorMessage: 'wardrobeLoadError',
              ),
            );
          },
        );
  }

  void selectOccasion(String occasion) {
    emit(
      state.copyWith(preference: state.preference.copyWith(occasion: occasion)),
    );
  }

  void selectDressCode(String dressCode) {
    emit(
      state.copyWith(
        preference: state.preference.copyWith(dressCode: dressCode),
      ),
    );
  }

  void selectWeather(String weather) {
    emit(
      state.copyWith(preference: state.preference.copyWith(weather: weather)),
    );
  }

  void selectVibe(String vibe) {
    emit(state.copyWith(preference: state.preference.copyWith(vibe: vibe)));
  }

  void toggleAccessories(bool value) {
    emit(
      state.copyWith(
        preference: state.preference.copyWith(includeAccessories: value),
      ),
    );
  }

  void toggleBoldColors(bool value) {
    emit(
      state.copyWith(
        preference: state.preference.copyWith(allowBoldColors: value),
      ),
    );
  }

  void updateCustomPrompt(String prompt) {
    emit(
      state.copyWith(
        preference: state.preference.copyWith(customPrompt: prompt.trim()),
      ),
    );
  }

  Future<void> generateCombination() async {
    if (state.isGenerating) {
      return;
    }
    if (state.wardrobeItems.isEmpty) {
      emit(state.copyWith(errorMessage: 'Garderobunda en az 1 parça olmalı.'));
      return;
    }
    emit(state.copyWith(isGenerating: true, resetError: true));
    try {
      final plan = await _generateCombinationUseCase(
        GenerateCombinationParams(
          preference: state.preference,
          wardrobeItems: state.wardrobeItems,
        ),
      );
      emit(state.copyWith(isGenerating: false, plan: plan));
    } on Exception catch (error) {
      emit(state.copyWith(isGenerating: false, errorMessage: error.toString()));
    }
  }

  @override
  Future<void> close() {
    _wardrobeSubscription?.cancel();
    return super.close();
  }
}
