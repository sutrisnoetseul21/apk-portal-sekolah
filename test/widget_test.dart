import 'package:flutter_test/flutter_test.dart';
import 'package:apk_portal_smpn1_sampang/main.dart';
import 'package:apk_portal_smpn1_sampang/core/config/app_config.dart';

void main() {
  testWidgets('SmartSchoolApp splash screen renders smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SmartSchoolApp());

    // Memverifikasi teks nama sekolah pada Splash Screen
    expect(find.text(AppConfig.appName), findsOneWidget);
  });
}
