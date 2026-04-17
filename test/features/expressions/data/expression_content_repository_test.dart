import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:speech_club/features/expressions/data/expression_content_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads English-source expression content from assets', () async {
    final ExpressionContentRepository repository =
        ExpressionContentRepository();

    final bundle = await repository.loadEnglishSource();

    expect(bundle.version, 1);
    expect(bundle.items.length, 100);
    expect(bundle.items.first.id, 'expr_en_001');
    expect(bundle.items.first.sourceLocale, 'en');
    expect(bundle.items.first.kind, 'idiom');
  });

  test('loads Chinese-source expression content from assets', () async {
    final ExpressionContentRepository repository =
        ExpressionContentRepository();

    final bundle = await repository.loadChineseSource();

    expect(bundle.version, 1);
    expect(bundle.items.length, 100);
    expect(bundle.items.first.id, 'expr_zh_001');
    expect(bundle.items.first.sourceLocale, 'zh');
    expect(bundle.items.first.kind, 'chengyu');
    expect(bundle.items.first.text.zh, '勇敢迈出第一步');
    expect(bundle.items.first.text.en, 'Take the first step bravely');
  });

  test('resolves expression text by locale', () async {
    final ExpressionContentRepository repository =
        ExpressionContentRepository();

    final bundle = await repository.loadEnglishSource();
    final firstItem = bundle.items.first;

    expect(firstItem.text.forLocale(const Locale('en')), 'Break the ice');
    expect(firstItem.text.forLocale(const Locale('zh')), '打破僵局');
  });
}
