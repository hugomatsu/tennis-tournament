import 'package:tennis_tournament/features/auth/data/auth_repository.dart';
import 'package:tennis_tournament/features/auth/domain/auth_user.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Stream<AuthUser?> authStateChanges() {
    return Stream.value(const AuthUser(uid: 'test_user_id', email: 'test@example.com'));
  }

  @override
  AuthUser? get currentUser => const AuthUser(uid: 'test_user_id', email: 'test@example.com');

  @override
  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    // No-op
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    // No-op
  }

  @override
  Future<void> signOut() async {
    // No-op
  }
}
