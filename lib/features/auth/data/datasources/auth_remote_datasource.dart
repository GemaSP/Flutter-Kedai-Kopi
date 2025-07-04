import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:coffe_shop/features/auth/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String email, String password, String name);
  Future<void> resetPassword(String email);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  @override
  Future<UserEntity> login(String email, String password) async {
    final result = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user!;
    return UserEntity(uid: user.uid, email: user.email ?? '');
  }

  @override
  Future<UserEntity> register(
    String email,
    String password,
    String name,
  ) async {
    final result = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user!;
    // Set display name ke Firebase user
    await user.updateDisplayName(name);
    await _firebaseDatabase.ref('users/${user.uid}').set({
      'nama': name,
      'email': email,
      'role': 2,
      'hp' : 0,
      'status': 1,
      'foto' : 'default.jpg',
      'created_at': DateTime.now().toIso8601String(),
    });
    return UserEntity(uid: user.uid, email: user.email ?? '', name: name);
  }

  @override
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
