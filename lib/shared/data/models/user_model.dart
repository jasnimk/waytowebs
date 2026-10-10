import '../../domain/entities/user_entity.dart';
import '../../../core/constants/enums.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phoneNumber,
    super.fullName,
    super.email,
    required super.role,
    super.address,
    super.city,
    super.state,
    super.pincode,
    super.isActive,
    super.credit30DaysEnabled,
    super.credit90DaysEnabled,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.customer,
      ),
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      credit30DaysEnabled: json['credit_30_days_enabled'] as bool? ?? false,
      credit90DaysEnabled: json['credit_90_days_enabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'email': email,
      'role': role.name,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'is_active': isActive,
      'credit_30_days_enabled': credit30DaysEnabled,
      'credit_90_days_enabled': credit90DaysEnabled,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      phoneNumber: entity.phoneNumber,
      fullName: entity.fullName,
      email: entity.email,
      role: entity.role,
      address: entity.address,
      city: entity.city,
      state: entity.state,
      pincode: entity.pincode,
      isActive: entity.isActive,
      credit30DaysEnabled: entity.credit30DaysEnabled,
      credit90DaysEnabled: entity.credit90DaysEnabled,
      createdAt: entity.createdAt,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      phoneNumber: phoneNumber,
      fullName: fullName,
      email: email,
      role: role,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
      isActive: isActive,
      credit30DaysEnabled: credit30DaysEnabled,
      credit90DaysEnabled: credit90DaysEnabled,
      createdAt: createdAt,
    );
  }
}
