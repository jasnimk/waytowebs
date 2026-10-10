import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> sendOtp(String phoneNumber);
  Future<Either<Failure, UserEntity>> verifyOtp(String phoneNumber, String otp);
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user);
}
