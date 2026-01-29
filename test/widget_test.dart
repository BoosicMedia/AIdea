import 'package:flutter_test/flutter_test.dart';

import 'package:helloworld/main.dart';

void main() {
  testWidgets('AIdea app smoke test', (tester) async {
    await tester.pumpWidget(const AIdeaApp());
    expect(find.text('AIdea.'), findsWidgets);
  });
}
