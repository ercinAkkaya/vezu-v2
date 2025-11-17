import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.registrationDate,
    this.gender,
    this.age,
    this.totalOutfitsCreated,
    this.subscriptionPlan,
    this.totalClothes,
    this.profilePhotoUrl,
    this.lastLoginDate,
    this.deviceToken,
    this.notificationEnabled,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.subscriptionPeriodStartDate,
    this.subscriptionPeriodEndDate,
    this.subscriptionLastRenewalDate,
    this.monthlyCombinationsUsed,
    this.monthlyCombinationsResetDate,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final DateTime? registrationDate;
  final String? gender;
  final int? age;
  final int? totalOutfitsCreated;
  final int? totalClothes;
  final String? subscriptionPlan;
  final String? profilePhotoUrl;
  final DateTime? lastLoginDate;
  final String? deviceToken;
  final bool? notificationEnabled;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final DateTime? subscriptionPeriodStartDate;
  final DateTime? subscriptionPeriodEndDate;
  final DateTime? subscriptionLastRenewalDate;
  final int? monthlyCombinationsUsed;
  final DateTime? monthlyCombinationsResetDate;

  UserEntity copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    DateTime? registrationDate,
    String? gender,
    int? age,
    int? totalOutfitsCreated,
    int? totalClothes,
    String? subscriptionPlan,
    String? profilePhotoUrl,
    DateTime? lastLoginDate,
    String? deviceToken,
    bool? notificationEnabled,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    DateTime? subscriptionPeriodStartDate,
    DateTime? subscriptionPeriodEndDate,
    DateTime? subscriptionLastRenewalDate,
    int? monthlyCombinationsUsed,
    DateTime? monthlyCombinationsResetDate,
  }) {
    return UserEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      registrationDate: registrationDate ?? this.registrationDate,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      totalOutfitsCreated: totalOutfitsCreated ?? this.totalOutfitsCreated,
      totalClothes: totalClothes ?? this.totalClothes,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      deviceToken: deviceToken ?? this.deviceToken,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      subscriptionPeriodStartDate: subscriptionPeriodStartDate ?? this.subscriptionPeriodStartDate,
      subscriptionPeriodEndDate: subscriptionPeriodEndDate ?? this.subscriptionPeriodEndDate,
      subscriptionLastRenewalDate: subscriptionLastRenewalDate ?? this.subscriptionLastRenewalDate,
      monthlyCombinationsUsed: monthlyCombinationsUsed ?? this.monthlyCombinationsUsed,
      monthlyCombinationsResetDate: monthlyCombinationsResetDate ?? this.monthlyCombinationsResetDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        registrationDate,
        gender,
        age,
        totalOutfitsCreated,
        totalClothes,
        subscriptionPlan,
        profilePhotoUrl,
        lastLoginDate,
        deviceToken,
        notificationEnabled,
        subscriptionStartDate,
        subscriptionEndDate,
        subscriptionPeriodStartDate,
        subscriptionPeriodEndDate,
        subscriptionLastRenewalDate,
        monthlyCombinationsUsed,
        monthlyCombinationsResetDate,
      ];
}

