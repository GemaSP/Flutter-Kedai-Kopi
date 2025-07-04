import 'package:coffe_shop/features/auth/domain/entities/user_entity.dart';
import 'package:coffe_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:coffe_shop/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDatasource;

  AuthRepositoryImpl(this.remoteDatasource);

  @override
  Future<UserEntity> login(String email, String password) async {
    final user = await remoteDatasource.login(email, password);
    return UserEntity(uid: user.uid, email: user.email);
  }

  @override
  Future<UserEntity> register(String email, String password, String name) async {
    final user = await remoteDatasource.register(email, password, name);
    return UserEntity(uid:user.uid, email: user.email, name: user.name);
  }

  @override
  Future<void> resetPassword(String email) async {
    return remoteDatasource.resetPassword(email);
  }

  @override
  Future<void> logout() async {
    return remoteDatasource.logout();
  }
}