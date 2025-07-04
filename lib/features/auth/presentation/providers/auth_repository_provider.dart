import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffe_shop/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:coffe_shop/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:coffe_shop/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(AuthRemoteDataSourceImpl()),
);
