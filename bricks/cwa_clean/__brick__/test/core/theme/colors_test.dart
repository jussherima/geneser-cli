import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/core/theme/colors.dart';

void main() {
  test('AppColors light/dark factory', () {
    final l = AppColors.light();
    final d = AppColors.dark();
    expect(l.primary, isNotNull);
    expect(d.primary, isNotNull);
    expect(l.primary, equals(d.primary)); // même primary hex templatisé
  });
}
