import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Finder findTextContaining(String value) => find.byWidgetPredicate((widget) {
  final text = switch (widget) {
    Text(:final data, :final textSpan) => data ?? textSpan?.toPlainText(),
    SelectableText(:final data, :final textSpan) =>
      data ?? textSpan?.toPlainText(),
    _ => null,
  };
  return text?.contains(value) ?? false;
});

void expectNoTextOverlapOrClipping(
  WidgetTester tester,
  String screen, {
  Finder? within,
}) {
  final textFinder = find.byWidgetPredicate(
    (widget) => widget is Text || widget is SelectableText,
  );
  final content =
      within ??
      (find.byType(Scrollable).evaluate().isNotEmpty
          ? find.byType(Scrollable).first
          : null);
  final paragraphFinder = content == null
      ? textFinder
      : find.descendant(of: content, matching: textFinder);
  final paragraphs = paragraphFinder
      .evaluate()
      .map((element) => element.findRenderObject())
      .whereType<RenderParagraph>()
      .where((paragraph) => paragraph.attached && paragraph.hasSize)
      .toList();
  final bounds = paragraphs
      .map((paragraph) => paragraph.localToGlobal(Offset.zero) & paragraph.size)
      .toList();

  for (var index = 0; index < paragraphs.length; index++) {
    expect(
      paragraphs[index].didExceedMaxLines,
      isFalse,
      reason:
          '$screen contains clipped text: '
          '${paragraphs[index].text.toPlainText()}',
    );
    for (var other = index + 1; other < bounds.length; other++) {
      expect(
        bounds[index].overlaps(bounds[other]),
        isFalse,
        reason:
            '$screen has overlapping text: '
            '"${paragraphs[index].text.toPlainText()}" and '
            '"${paragraphs[other].text.toPlainText()}"',
      );
    }
  }
}
