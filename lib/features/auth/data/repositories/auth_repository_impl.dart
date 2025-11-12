import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vezu/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:vezu/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:vezu/features/auth/data/models/user_data_model.dart';
import 'package:vezu/features/auth/domain/entities/user_entity.dart';
import 'package:vezu/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required FirebaseMessaging messaging,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _messaging = messaging;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final FirebaseMessaging _messaging;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = _remoteDataSource.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    final userData = await _remoteDataSource.fetchUser(firebaseUser.uid);
    return userData ??
        UserDataModel(
          id: firebaseUser.uid,
          email: firebaseUser.email,
          firstName: firebaseUser.displayName,
          profilePhotoUrl: firebaseUser.photoURL,
        );
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      final credential = await _remoteDataSource.signInWithGoogleCredential();
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'USER_NULL',
          message: 'Firebase kullanıcı bilgileri alınamadı.',
        );
      }

      final deviceToken = await _messaging.getToken();
      final now = DateTime.now();

      final existingUser = await _remoteDataSource.fetchUser(firebaseUser.uid);

      final names = _splitDisplayName(firebaseUser.displayName);

      final userModel = (existingUser ??
              UserDataModel(
                id: firebaseUser.uid,
              ))
          .copyWith(
        firstName: names.$1,
        lastName: names.$2,
        email: firebaseUser.email,
        profilePhotoUrl: existingUser?.profilePhotoUrl ?? firebaseUser.photoURL,
        lastLoginDate: now,
        deviceToken: deviceToken,
        notificationEnabled: existingUser?.notificationEnabled ?? true,
        totalOutfitsCreated: existingUser?.totalOutfitsCreated ?? 0,
        registrationDate: existingUser?.registrationDate ?? now,
        gender: existingUser?.gender,
        age: existingUser?.age,
        subscriptionPlan: existingUser?.subscriptionPlan ?? 'free',
        subscriptionStartDate: existingUser?.subscriptionStartDate,
        subscriptionEndDate: existingUser?.subscriptionEndDate,
      );

      await _remoteDataSource.saveUser(
        userModel,
        isNewUser: existingUser == null,
      );

      await _localDataSource.cacheUserId(userModel.id);

      return userModel;
    } on FirebaseAuthException {
      rethrow;
    } catch (error, stackTrace) {
      log('Google ile giriş sırasında hata oluştu', error: error, stackTrace: stackTrace);
      throw Exception('Google ile giriş başarısız: ${error.toString()}');
    }
  }

  @override
  Future<String?> getCachedUserId() {
    return _localDataSource.getCachedUserId();
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
    await _localDataSource.clearCachedUserId();
  }

  @override
  Future<UserEntity> updateUserProfile({
    String? firstName,
    String? lastName,
    String? gender,
    int? age,
    String? profilePhotoPath,
  }) async {
    final firebaseUser = _remoteDataSource.currentUser;
    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'USER_NULL',
        message: 'Oturum açmış kullanıcı bulunamadı.',
      );
    }

    final currentUser =
        await _remoteDataSource.fetchUser(firebaseUser.uid) ??
            UserDataModel(id: firebaseUser.uid);

    String? uploadedPhotoUrl;
    if (profilePhotoPath != null) {
      uploadedPhotoUrl = await _remoteDataSource.uploadProfilePhoto(
        firebaseUser.uid,
        profilePhotoPath,
      );
    }

    final updatedUser = currentUser.copyWith(
      firstName: firstName ?? currentUser.firstName,
      lastName: lastName ?? currentUser.lastName,
      gender: gender ?? currentUser.gender,
      age: age ?? currentUser.age,
      profilePhotoUrl: uploadedPhotoUrl ?? currentUser.profilePhotoUrl,
    );

    await _remoteDataSource.saveUser(
      updatedUser,
      isNewUser: false,
    );

    return updatedUser;
  }

  (String?, String?) _splitDisplayName(String? displayName) {
    if (displayName == null || displayName.trim().isEmpty) {
      return (null, null);
    }

    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return (parts.first, null);
    }

    final firstName = parts.first;
    final lastName = parts.sublist(1).join(' ');
    return (firstName, lastName);
  }
}

