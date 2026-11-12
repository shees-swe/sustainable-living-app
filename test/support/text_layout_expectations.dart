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
  final paragraphFinder = within == null
      ? textFinder
      : find.descendant(of: within, matching: textFinder);
  final paragraphs = paragraphFinder
      .evaluate()
      .map((element) => element.findRenderObject())
      .whereType<RenderParagraph>()
      .where((paragraph) => paragraph.attached && paragraph.hasSize)
      .toList();
  final visibleParagraphs = <(RenderParagraph, Rect)>[];
  for (final paragraph in paragraphs) {
    var rect = paragraph.localToGlobal(Offset.zero) & paragraph.size;
    final viewport = RenderAbstractViewport.maybeOf(paragraph);
    if (viewport is RenderBox) {
      final viewportBox = viewport as RenderBox;
      if (viewportBox.hasSize) {
        final viewportRect =
            viewportBox.localToGlobal(Offset.zero) & viewportBox.size;
        if (!rect.overlaps(viewportRect)) {
          continue;
        }
        rect = rect.intersect(viewportRect);
      }
    }
    if (rect.width > 0 && rect.height > 0) {
      visibleParagraphs.add((paragraph, rect));
    }
  }

  for (var index = 0; index < paragraphs.length; index++) {
    expect(
      paragraphs[index].didExceedMaxLines,
      isFalse,
      reason:
          '$screen contains clipped text: '
          '${paragraphs[index].text.toPlainText()}',
    );
  }
  for (var index = 0; index < visibleParagraphs.length; index++) {
    for (var other = index + 1; other < visibleParagraphs.length; other++) {
      expect(
        visibleParagraphs[index].$2.overlaps(visibleParagraphs[other].$2),
        isFalse,
        reason:
            '$screen has overlapping text: '
            '"${visibleParagraphs[index].$1.text.toPlainText()}" and '
            '"${visibleParagraphs[other].$1.text.toPlainText()}"',
      );
    }
  }
}
