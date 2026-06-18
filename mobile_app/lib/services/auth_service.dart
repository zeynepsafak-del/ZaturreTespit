import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        throw Exception('Geçersiz e-posta veya kullanıcı bulunamadı.');
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Yanlış şifre.');
      }
      throw Exception(e.message ?? 'Bir hata oluştu.');
    } catch (e) {
      throw Exception('Bilinmeyen bir hata oluştu: $e');
    }
  }

  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Şifre çok zayıf.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Bu e-posta zaten kullanımda.');
      }
      throw Exception(e.message ?? 'Bir hata oluştu.');
    } catch (e) {
      throw Exception('Bilinmeyen bir hata oluştu: $e');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
