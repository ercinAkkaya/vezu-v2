import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vezu/features/auth/domain/entities/user_entity.dart';

class UserDataModel extends UserEntity {
  const UserDataModel({
    required super.id,
    super.firstName,
    super.lastName,
    super.email,
    super.registrationDate,
    super.gender,
    super.age,
    super.totalOutfitsCreated,
    super.subscriptionPlan,
    super.profilePhotoUrl,
    super.lastLoginDate,
    super.deviceToken,
    super.notificationEnabled,
    super.subscriptionStartDate,
    super.subscriptionEndDate,
  });

  factory UserDataModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      return UserDataModel(id: snapshot.id);
    }

    DateTime? dateFromTimestamp(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }
      if (value is DateTime) {
        return value;
      }
      return null;
    }

    return UserDataModel(
      id: snapshot.id,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      email: data['email'] as String?,
      registrationDate: dateFromTimestamp(data['registrationDate']),
      gender: data['gender'] as String?,
      age: (data['age'] as num?)?.toInt(),
      totalOutfitsCreated: (data['totalOutfitsCreated'] as num?)?.toInt(),
      subscriptionPlan: data['subscriptionPlan'] as String?,
      profilePhotoUrl: data['profilePhotoUrl'] as String?,
      lastLoginDate: dateFromTimestamp(data['lastLoginDate']),
      deviceToken: data['deviceToken'] as String?,
      notificationEnabled: data['notificationEnabled'] as bool?,
      subscriptionStartDate: dateFromTimestamp(data['subscriptionStartDate']),
      subscriptionEndDate: dateFromTimestamp(data['subscriptionEndDate']),
    );
  }

  Map<String, dynamic> toMap({bool isNewUser = false}) {
    Timestamp? timestampFromDate(DateTime? dateTime) {
      return dateTime == null ? null : Timestamp.fromDate(dateTime);
    }

    final map = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'gender': gender,
      'age': age,
      'totalOutfitsCreated': totalOutfitsCreated,
      'subscriptionPlan': subscriptionPlan,
      'profilePhotoUrl': profilePhotoUrl,
      'lastLoginDate': timestampFromDate(lastLoginDate),
      'deviceToken': deviceToken,
      'notificationEnabled': notificationEnabled,
      'subscriptionStartDate': timestampFromDate(subscriptionStartDate),
      'subscriptionEndDate': timestampFromDate(subscriptionEndDate),
    };

    if (isNewUser) {
      map['registrationDate'] = FieldValue.serverTimestamp();
    } else {
      map['registrationDate'] = timestampFromDate(registrationDate);
    }

    map.removeWhere((key, value) => value == null);

    return map;
  }

  @override
  UserDataModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    DateTime? registrationDate,
    String? gender,
    int? age,
    int? totalOutfitsCreated,
    String? subscriptionPlan,
    String? profilePhotoUrl,
    DateTime? lastLoginDate,
    String? deviceToken,
    bool? notificationEnabled,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
  }) {
    return UserDataModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      registrationDate: registrationDate ?? this.registrationDate,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      totalOutfitsCreated: totalOutfitsCreated ?? this.totalOutfitsCreated,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      deviceToken: deviceToken ?? this.deviceToken,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
    );
  }
}

