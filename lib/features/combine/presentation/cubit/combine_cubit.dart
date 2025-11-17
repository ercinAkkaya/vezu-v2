import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:vezu/core/services/subscription_service.dart';
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
    FirebaseFirestore? firestore,
  }) : _watchWardrobeItemsUseCase = watchWardrobeItemsUseCase,
       _generateCombinationUseCase = generateCombinationUseCase,
       _authCubit = authCubit,
       _firestore = firestore ?? FirebaseFirestore.instance,
       super(const CombineState());

  final WatchWardrobeItemsUseCase _watchWardrobeItemsUseCase;
  final GenerateCombinationUseCase _generateCombinationUseCase;
  final AuthCubit _authCubit;
  final FirebaseFirestore _firestore;

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
    if (state.wardrobeItems.length < 10) {
      emit(state.copyWith(
        errorMessage: 'Kombin oluşturabilmek için garderobunuzda en az 10 kıyafet olmalı. Şu anda ${state.wardrobeItems.length} kıyafetiniz var.',
      ));
      return;
    }

    final userId = _authCubit.state.user?.id;
    if (userId == null) {
      emit(state.copyWith(errorMessage: 'Kullanıcı bilgisi bulunamadı.'));
      return;
    }

    // Limit kontrolü yap
    final subscriptionService = SubscriptionService.instance();
    final canCreate = await subscriptionService.canCreateCombination(userId: userId);

    if (!canCreate) {
      emit(
        state.copyWith(
          isGenerating: false,
          shouldShowPaywall: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isGenerating: true, resetError: true, resetPaywall: true));
    try {
      final plan = await _generateCombinationUseCase(
        GenerateCombinationParams(
          preference: state.preference,
          wardrobeItems: state.wardrobeItems,
        ),
      );

      // Kombin oluşturuldu, sayacı artır
      await subscriptionService.incrementCombinationCount(userId);

      emit(
        state.copyWith(
          isGenerating: false,
          plan: plan,
          hasSavedPlan: false,
        ),
      );
    } on Exception catch (error) {
      emit(state.copyWith(isGenerating: false, errorMessage: error.toString()));
    }
  }

  void clearPaywall() {
    emit(state.copyWith(resetPaywall: true));
  }

  @override
  Future<void> close() {
    _wardrobeSubscription?.cancel();
    return super.close();
  }

  Future<bool> saveCurrentPlan() async {
    final plan = state.plan;
    final userId = _authCubit.state.user?.id;
    if (plan == null || userId == null) {
      return false;
    }
    final wardrobeLookup = {
      for (final item in state.wardrobeItems) item.id: item,
    };
    emit(state.copyWith(isSavingPlan: true));
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_combinations')
          .doc();
      await docRef.set({
        'id': docRef.id,
        'theme': plan.theme,
        'theme_key': _normalizeKey(plan.theme),
        'mood': plan.mood,
        'summary': plan.summary,
        'styling_notes': plan.stylingNotes,
        'accessories': plan.accessories,
        'warnings': plan.warnings,
        'preference': state.preference.toMap(),
        'created_at': FieldValue.serverTimestamp(),
        'items': plan.items
            .map(
              (item) => {
                'wardrobe_item_id': item.wardrobeItemId,
                'slot': item.slot,
                'nickname': item.nickname,
                'pairing_reason': item.pairingReason,
                'styling_tip': item.stylingTip,
                'accent': item.accent,
                'image_url': wardrobeLookup[item.wardrobeItemId]?.imageUrl,
                'category': wardrobeLookup[item.wardrobeItemId]?.category ??
                    item.slot,
              },
            )
            .toList(),
      });
      emit(state.copyWith(isSavingPlan: false, hasSavedPlan: true));
      return true;
    } catch (_) {
      emit(state.copyWith(isSavingPlan: false));
      return false;
    }
  }
}

String _normalizeKey(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .trim()
      .replaceAll(RegExp(r'^_|_$'), '');
}
