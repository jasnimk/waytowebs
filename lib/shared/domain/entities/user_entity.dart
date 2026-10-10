import 'package:equatable/equatable.dart';
import '../../../core/constants/enums.dart';

class UserEntity extends Equatable {
  final String id;
  final String phoneNumber;
  final String? fullName;
  final String? email;
  final UserRole role;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final bool isActive;
  final bool credit30DaysEnabled;
  final bool credit90DaysEnabled;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.phoneNumber,
    this.fullName,
    this.email,
    required this.role,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.isActive = true,
    this.credit30DaysEnabled = false,
    this.credit90DaysEnabled = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        phoneNumber,
        fullName,
        email,
        role,
        address,
        city,
        state,
        pincode,
        isActive,
        credit30DaysEnabled,
        credit90DaysEnabled,
        createdAt,
      ];

  UserEntity copyWith({
    String? id,
    String? phoneNumber,
    String? fullName,
    String? email,
    UserRole? role,
    String? address,
    String? city,
    String? state,
    String? pincode,
    bool? isActive,
    bool? credit30DaysEnabled,
    bool? credit90DaysEnabled,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      isActive: isActive ?? this.isActive,
      credit30DaysEnabled: credit30DaysEnabled ?? this.credit30DaysEnabled,
      credit90DaysEnabled: credit90DaysEnabled ?? this.credit90DaysEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
