import 'package:flutter_test/flutter_test.dart';
import 'package:smart_finance_app/app.dart';

void main() {
  testWidgets('App loads cleanly without UI', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartFinanceApp());

    // Memverifikasi teks placeholder muncul (berarti aplikasi tidak crash)
    expect(find.text('Providers & Themes Setup Selesai!'), findsOneWidget);
  });
}
