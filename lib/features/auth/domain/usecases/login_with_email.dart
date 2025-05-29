import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmail {
  final AuthRepository repository;

  LoginWithEmail(this.repository);

  Future<UserEntity> call(String email, String password) {
    return repository.login(email, password);
  }
}
