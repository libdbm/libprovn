import 'package:libprovn/libprovn.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('mentionOf expression', () {
    test('Basic mentionOf parses correctly', () {
      final provn = 'mentionOf(ex:specific, ex:general, ex:bundle)';
      final result = PROVNExpressionsParser.parse(provn);

      expect(result is Success, isTrue);
      final expr = (result as Success).value.first as MentionOfExpression;
      expect(expr.specific, equals('ex:specific'));
      expect(expr.general, equals('ex:general'));
      expect(expr.bundle, equals('ex:bundle'));
    });

    test('mentionOf in full document', () {
      final provn = '''document
prefix ex <http://example.org/>
prefix tr <http://www.w3.org/TR/2011/>
entity(ex:bundle1, [ prov:type='prov:Bundle' ])
mentionOf(tr:WD-prov-dm-20111215, tr:WD-prov-dm-20111215, ex:bundle1)
endDocument''';

      final result = PROVNDocumentParser.parse(provn);
      expect(result is Success, isTrue);

      final doc = (result as Success).value;
      expect(doc.expressions.length, equals(2));

      final mentionExpr = doc.expressions[1] as MentionOfExpression;
      expect(mentionExpr.specific, equals('tr:WD-prov-dm-20111215'));
      expect(mentionExpr.general, equals('tr:WD-prov-dm-20111215'));
      expect(mentionExpr.bundle, equals('ex:bundle1'));
    });

    test('mentionOf writes correctly to PROV-N', () {
      final expr = MentionOfExpression('ex:e1', 'ex:e2', 'ex:b1');
      final writer = PROVNWriter();
      final provn = writer.writeExpression(expr).trim();

      expect(provn, equals('mentionOf(ex:e1, ex:e2, ex:b1)'));
    });

    test('mentionOf writes correctly to PROV-JSON', () {
      final doc = DocumentExpression([Namespace('ex', 'http://example.org/')],
          [MentionOfExpression('ex:specific', 'ex:general', 'ex:bundle')]);

      final writer = PROVJSONWriter();
      final json = writer.writeDocument(doc);

      expect(json, contains('"mentionOf"'));
      expect(json, contains('"prov:specificEntity": "ex:specific"'));
      expect(json, contains('"prov:generalEntity": "ex:general"'));
      expect(json, contains('"prov:bundle": "ex:bundle"'));
    });

    test('mentionOf reads correctly from PROV-JSON', () {
      final json = '''
{
  "prefix": {
    "ex": "http://example.org/"
  },
  "mentionOf": {
    "_:id0": {
      "prov:specificEntity": "ex:specific",
      "prov:generalEntity": "ex:general",
      "prov:bundle": "ex:bundle"
    }
  }
}
''';

      final reader = PROVJSONReader();
      final doc = reader.readDocument(json);

      expect(doc.expressions.length, equals(1));
      final expr = doc.expressions[0] as MentionOfExpression;
      expect(expr.specific, equals('ex:specific'));
      expect(expr.general, equals('ex:general'));
      expect(expr.bundle, equals('ex:bundle'));
    });

    test('mentionOf roundtrips PROV-N → JSON → PROV-N', () {
      final original = '''document
prefix ex <http://example.org/>
entity(ex:bundle1)
mentionOf(ex:e1, ex:e2, ex:bundle1)
endDocument''';

      final parseResult = PROVNDocumentParser.parse(original);
      expect(parseResult is Success, isTrue);
      final doc1 = (parseResult as Success).value;

      final jsonWriter = PROVJSONWriter();
      final json = jsonWriter.writeDocument(doc1);

      final jsonReader = PROVJSONReader();
      final doc2 = jsonReader.readDocument(json);

      expect(doc2.expressions.length, equals(2));
      final mentionExpr = doc2.expressions[1] as MentionOfExpression;
      expect(mentionExpr.specific, equals('ex:e1'));
      expect(mentionExpr.general, equals('ex:e2'));
      expect(mentionExpr.bundle, equals('ex:bundle1'));

      final provnWriter = PROVNWriter();
      final roundtripped = provnWriter.writeDocument(doc2);

      // Parse both to compare structure
      final reparsedResult = PROVNDocumentParser.parse(roundtripped);
      expect(reparsedResult is Success, isTrue);
      final reparsed = (reparsedResult as Success).value;

      expect(reparsed.expressions.length, equals(doc1.expressions.length));
    });

    test('mentionOf roundtrips JSON → PROV-N → JSON', () {
      final originalJson = '''
{
  "prefix": {
    "ex": "http://example.org/"
  },
  "mentionOf": {
    "_:id0": {
      "prov:specificEntity": "ex:e1",
      "prov:generalEntity": "ex:e2",
      "prov:bundle": "ex:b1"
    }
  }
}
''';

      final reader = PROVJSONReader();
      final doc1 = reader.readDocument(originalJson);

      final provnWriter = PROVNWriter();
      final provn = provnWriter.writeDocument(doc1);

      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult is Success, isTrue);
      final doc2 = (parseResult as Success).value;

      final jsonWriter = PROVJSONWriter();
      final roundtrippedJson = jsonWriter.writeDocument(doc2);

      final doc3 = reader.readDocument(roundtrippedJson);
      expect(doc3.expressions.length, equals(1));
      final expr = doc3.expressions[0] as MentionOfExpression;
      expect(expr.specific, equals('ex:e1'));
      expect(expr.general, equals('ex:e2'));
      expect(expr.bundle, equals('ex:b1'));
    });

    test('mentionOf equality works correctly', () {
      final expr1 = MentionOfExpression('ex:e1', 'ex:e2', 'ex:b1');
      final expr2 = MentionOfExpression('ex:e1', 'ex:e2', 'ex:b1');
      final expr3 = MentionOfExpression('ex:e1', 'ex:e2', 'ex:b2');

      expect(expr1, equals(expr2));
      expect(expr1, isNot(equals(expr3)));
    });

    test('mentionOf toString works correctly', () {
      final expr = MentionOfExpression('ex:e1', 'ex:e2', 'ex:b1');
      expect(expr.toString(), equals('mentionOf(ex:e1, ex:e2, ex:b1)'));
    });
  });
}
