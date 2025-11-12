part of 'auth_cubit.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  failure,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.cachedUserId,
    this.errorMessage,
    this.isUpdatingProfile = false,
  });

  final AuthStatus status;
  final UserEntity? user;
  final String? cachedUserId;
  final String? errorMessage;
  final bool isUpdatingProfile;

  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? cachedUserId,
    String? errorMessage,
    bool resetError = false,
    bool? isUpdatingProfile,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      cachedUserId: cachedUserId ?? this.cachedUserId,
      errorMessage: resetError ? null : errorMessage ?? this.errorMessage,
      isUpdatingProfile: isUpdatingProfile ?? this.isUpdatingProfile,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        cachedUserId,
        errorMessage,
        isUpdatingProfile,
      ];
}

