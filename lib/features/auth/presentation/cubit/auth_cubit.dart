import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:vezu/core/services/subscription_service.dart';
import 'package:vezu/features/auth/domain/entities/user_entity.dart';
import 'package:vezu/features/auth/domain/usecases/get_cached_user_id.dart';
import 'package:vezu/features/auth/domain/usecases/get_current_user.dart';
import 'package:vezu/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:vezu/features/auth/domain/usecases/sign_out.dart';
import 'package:vezu/features/auth/domain/usecases/update_user_profile.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required GetCachedUserIdUseCase getCachedUserIdUseCase,
    required SignOutUseCase signOutUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
  })  : _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _getCachedUserIdUseCase = getCachedUserIdUseCase,
        _signOutUseCase = signOutUseCase,
        _updateUserProfileUseCase = updateUserProfileUseCase,
        super(const AuthState());

  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final GetCachedUserIdUseCase _getCachedUserIdUseCase;
  final SignOutUseCase _signOutUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;

  void incrementTotalClothes() {
    final currentUser = state.user;
    if (currentUser == null) {
      return;
    }
    final updatedUser = currentUser.copyWith(
      totalClothes: (currentUser.totalClothes ?? 0) + 1,
    );
    emit(state.copyWith(user: updatedUser));
  }

  void decrementTotalClothes() {
    final currentUser = state.user;
    if (currentUser == null) {
      return;
    }
    final currentCount = currentUser.totalClothes ?? 0;
    final updatedUser = currentUser.copyWith(
      totalClothes: currentCount > 0 ? currentCount - 1 : 0,
    );
    emit(state.copyWith(user: updatedUser));
  }

  Future<void> checkAuthStatus() async {
    emit(state.copyWith(status: AuthStatus.loading, resetError: true));
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        // Mevcut kullanıcı için RevenueCat'ten subscription senkronizasyonu yap
        // Bu sayede abonelik bitmiş veya yenilenmiş durumlar güncellenir
        try {
          await SubscriptionService.instance().syncSubscriptionFromRevenueCat(user.id);
          // Subscription güncellendikten sonra kullanıcı bilgilerini yeniden çek
          final updatedUser = await _getCurrentUserUseCase();
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: updatedUser ?? user,
              cachedUserId: updatedUser?.id ?? user.id,
            ),
          );
        } catch (subscriptionError) {
          // Subscription senkronizasyonu başarısız olsa bile kullanıcı giriş yapmış sayılır
          // Sadece mevcut kullanıcı bilgilerini göster
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
              cachedUserId: user.id,
            ),
          );
        }
        return;
      }

      final cachedId = await _getCachedUserIdUseCase();
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          cachedUserId: cachedId,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(status: AuthStatus.loading, resetError: true));
    try {
      final user = await _signInWithGoogleUseCase();
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          cachedUserId: user.id,
        ),
      );
    } on PlatformException catch (error) {
      // Google Sign-In platform hatalarını yakala
      String errorMessage = 'Google ile giriş başarısız.';
      
      if (error.code == 'sign_in_failed') {
        // Hata kodu 10: DEVELOPER_ERROR - genellikle SHA-1 fingerprint sorunu
        if (error.message?.contains('10') == true) {
          errorMessage = 'Google ile giriş yapılandırma hatası.\n\n'
              'Çözüm:\n'
              '1. Google Play Console\'da App Signing bölümünden SHA-1 fingerprint\'ini alın\n'
              '2. Firebase Console > Project Settings > Your apps > Android app\'e gidin\n'
              '3. SHA-1 certificate fingerprint\'i ekleyin\n'
              '4. Yeni google-services.json dosyasını indirip projeye ekleyin';
        } else {
          errorMessage = 'Google ile giriş başarısız: ${error.message ?? "Bilinmeyen hata"}';
        }
      } else {
        errorMessage = 'Google ile giriş başarısız: ${error.message ?? error.code}';
      }
      
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: errorMessage,
        ),
      );
    } on FirebaseAuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.message ?? 'Google ile giriş sırasında bir hata oluştu.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Google ile giriş başarısız: ${error.toString()}',
        ),
      );
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(status: AuthStatus.loading, resetError: true));
    try {
      await _signOutUseCase();
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? gender,
    int? age,
    String? profilePhotoPath,
  }) async {
    emit(state.copyWith(isUpdatingProfile: true, resetError: true));
    try {
      final user = await _updateUserProfileUseCase(
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        age: age,
        profilePhotoPath: profilePhotoPath,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          cachedUserId: user.id,
          isUpdatingProfile: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isUpdatingProfile: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// Kullanıcı bilgilerini Firebase'den yeniden yükler
  /// Abonelik güncellemesi gibi durumlarda kullanılır
  Future<void> refreshUser() async {
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        // RevenueCat'ten subscription senkronizasyonu yap
        // Bu sayede abonelik durumu güncel kalır
        try {
          await SubscriptionService.instance().syncSubscriptionFromRevenueCat(user.id);
          // Subscription güncellendikten sonra kullanıcı bilgilerini yeniden çek
          final updatedUser = await _getCurrentUserUseCase();
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: updatedUser ?? user,
              cachedUserId: updatedUser?.id ?? user.id,
            ),
          );
        } catch (subscriptionError) {
          // Subscription senkronizasyonu başarısız olsa bile mevcut kullanıcı bilgilerini göster
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
              cachedUserId: user.id,
            ),
          );
        }
      }
    } catch (error) {
      // Hata durumunda mevcut state'i koru
      // Sessizce başarısız ol, kullanıcıyı rahatsız etme
    }
  }
}

