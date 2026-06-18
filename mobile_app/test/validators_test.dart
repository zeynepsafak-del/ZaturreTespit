import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/utils/validators.dart';

void main() {
  group('Validators Testleri', () {
    test('Boş alan kontrol testi', () {
      expect(Validators.validateEmail(''), 'Lütfen e-posta adresinizi girin');
      expect(Validators.validateEmail(null), 'Lütfen e-posta adresinizi girin');

      expect(Validators.validatePassword(''), 'Lütfen şifrenizi girin');
      expect(Validators.validatePassword(null), 'Lütfen şifrenizi girin');

      expect(Validators.validateName(''), 'Lütfen adınızı girin');
      expect(Validators.validateName(null), 'Lütfen adınızı girin');
    });

    test('Geçersiz e-posta formatı testi', () {
      expect(Validators.validateEmail('gecersiz_email'), 'Geçerli bir e-posta adresi girin');
      expect(Validators.validateEmail('test@.com'), 'Geçerli bir e-posta adresi girin');
      expect(Validators.validateEmail('test@com'), 'Geçerli bir e-posta adresi girin');

      expect(Validators.validateEmail('gecerli@email.com'), null);
    });
  });
}
