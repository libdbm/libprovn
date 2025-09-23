import 'package:test/test.dart';
import 'package:libprovn/libprovn.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  group('Round-trip Tests', () {
    late PROVNWriter writer;

    setUp(() {
      writer = PROVNWriter();
    });

    test('Simple entity round-trip', () {
      final provn = '''document
  entity(ex:article)
endDocument''';

      // Parse the original
      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult, isNot(isA<Failure>()));

      final doc = parseResult.value;

      // Write it back
      final written = writer.writeDocument(doc);

      // Parse the written version
      final parseResult2 = PROVNDocumentParser.parse(written);
      expect(parseResult2, isNot(isA<Failure>()));

      final doc2 = parseResult2.value;

      // Compare the documents
      expect(doc2.expressions.length, equals(doc.expressions.length));
      expect(doc2.expressions.first.runtimeType,
          equals(doc.expressions.first.runtimeType));

      final entity1 = doc.expressions.first as EntityExpression;
      final entity2 = doc2.expressions.first as EntityExpression;
      expect(entity2.identifier, equals(entity1.identifier));
    });

    test('Entity with attributes round-trip', () {
      final provn = '''document
  entity(ex:article, [dcterms:title="Test Article", ex:version=1])
endDocument''';

      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult, isNot(isA<Failure>()));

      final doc = parseResult.value;
      final written = writer.writeDocument(doc);

      final parseResult2 = PROVNDocumentParser.parse(written);
      expect(parseResult2, isNot(isA<Failure>()));

      final doc2 = parseResult2.value;

      final entity1 = doc.expressions.first as EntityExpression;
      final entity2 = doc2.expressions.first as EntityExpression;

      expect(entity2.identifier, equals(entity1.identifier));
      expect(entity2.attributes.length, equals(entity1.attributes.length));
    });

    test('Multiple expressions round-trip', () {
      final provn = '''document
  entity(ex:article)
  agent(ex:alice)
  wasAttributedTo(ex:article, ex:alice)
endDocument''';

      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult, isNot(isA<Failure>()));

      final doc = parseResult.value;
      final written = writer.writeDocument(doc);

      final parseResult2 = PROVNDocumentParser.parse(written);
      expect(parseResult2, isNot(isA<Failure>()));

      final doc2 = parseResult2.value;

      expect(doc2.expressions.length, equals(3));
      expect(doc2.expressions[0], isA<EntityExpression>());
      expect(doc2.expressions[1], isA<AgentExpression>());
      expect(doc2.expressions[2], isA<AttributionExpression>());
    });

    test('Document with namespaces round-trip', () {
      final provn = '''document
  prefix ex <http://example.org/>
  prefix dcterms <http://purl.org/dc/terms/>

  entity(ex:article, [dcterms:title="Test"])
endDocument''';

      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult, isNot(isA<Failure>()));

      final doc = parseResult.value;
      final written = writer.writeDocument(doc);

      final parseResult2 = PROVNDocumentParser.parse(written);
      expect(parseResult2, isNot(isA<Failure>()));

      final doc2 = parseResult2.value;

      expect(doc2.namespaces.length, equals(doc.namespaces.length));
      for (var i = 0; i < doc.namespaces.length; i++) {
        expect(doc2.namespaces[i].prefix, equals(doc.namespaces[i].prefix));
        expect(doc2.namespaces[i].uri, equals(doc.namespaces[i].uri));
      }
    });

    test('Activity with times round-trip', () {
      final provn = '''document
  activity(ex:edit, 2024-01-15T10:00:00, 2024-01-15T11:30:00)
endDocument''';

      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult, isNot(isA<Failure>()));

      final doc = parseResult.value;
      final written = writer.writeDocument(doc);

      final parseResult2 = PROVNDocumentParser.parse(written);
      expect(parseResult2, isNot(isA<Failure>()));

      final doc2 = parseResult2.value;

      final activity1 = doc.expressions.first as ActivityExpression;
      final activity2 = doc2.expressions.first as ActivityExpression;

      expect(activity2.identifier, equals(activity1.identifier));
      expect(activity2.from, equals(activity1.from));
      expect(activity2.to, equals(activity1.to));
    });

    test('Generation expression round-trip', () {
      final provn = '''document
  wasGeneratedBy(ex:entity, ex:activity, 2024-01-15T10:00:00)
endDocument''';

      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult, isNot(isA<Failure>()));

      final doc = parseResult.value;
      final written = writer.writeDocument(doc);

      final parseResult2 = PROVNDocumentParser.parse(written);
      expect(parseResult2, isNot(isA<Failure>()));

      final doc2 = parseResult2.value;

      final gen1 = doc.expressions.first as GenerationExpression;
      final gen2 = doc2.expressions.first as GenerationExpression;

      expect(gen2.entityId, equals(gen1.entityId));
      expect(gen2.activityId, equals(gen1.activityId));
      expect(gen2.datetime, equals(gen1.datetime));
    });

    test('Derivation with optional fields round-trip', () {
      // EBNF-compliant: all three optional parameters must be present
      final provn = '''document
  wasDerivedFrom(ex:e2, ex:e1, ex:activity, -, -)
endDocument''';

      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult, isNot(isA<Failure>()));

      final doc = parseResult.value;
      final written = writer.writeDocument(doc);

      final parseResult2 = PROVNDocumentParser.parse(written);
      expect(parseResult2, isNot(isA<Failure>()));

      final doc2 = parseResult2.value;

      // Both should be DerivationExpression with EBNF-compliant format
      expect(doc.expressions.first, isA<DerivationExpression>());
      expect(doc2.expressions.first, isA<DerivationExpression>());

      final deriv1 = doc.expressions.first as DerivationExpression;
      final deriv2 = doc2.expressions.first as DerivationExpression;

      expect(deriv2.generatedEntityId, equals(deriv1.generatedEntityId));
      expect(deriv2.usedEntityId, equals(deriv1.usedEntityId));
      expect(deriv2.activityId, equals(deriv1.activityId));
    });

    test('Bundle round-trip', () {
      final provn = '''document
  bundle ex:bundle1
    entity(ex:bundledEntity)
    agent(ex:bundledAgent)
  endBundle
endDocument''';

      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult, isNot(isA<Failure>()));

      final doc = parseResult.value;
      final written = writer.writeDocument(doc);

      final parseResult2 = PROVNDocumentParser.parse(written);
      expect(parseResult2, isNot(isA<Failure>()));

      final doc2 = parseResult2.value;

      expect(doc2.expressions.length, equals(1));
      expect(doc2.expressions.first, isA<BundleExpression>());

      final bundle1 = doc.expressions.first as BundleExpression;
      final bundle2 = doc2.expressions.first as BundleExpression;

      expect(bundle2.identifier, equals(bundle1.identifier));
      expect(bundle2.expressions.length, equals(bundle1.expressions.length));
    });

    test('Complex document round-trip', () {
      final provn = '''document
  prefix ex <http://example.org/>
  prefix foaf <http://xmlns.com/foaf/0.1/>

  entity(ex:article, [foaf:title="Test Article"])
  agent(ex:author, [foaf:name="Alice"])
  activity(ex:writing, 2024-01-01T09:00:00, 2024-01-10T17:00:00)

  wasGeneratedBy(ex:article, ex:writing, 2024-01-10T16:45:00)
  wasAttributedTo(ex:article, ex:author)
  wasAssociatedWith(ex:writing, ex:author, -)

  specializationOf(ex:article, ex:document)
  alternateOf(ex:article, ex:article_v2)

  bundle ex:revisions
    entity(ex:article_v2)
    wasDerivedFrom(ex:article_v2, ex:article)
  endBundle
endDocument''';

      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult, isNot(isA<Failure>()));

      final doc = parseResult.value;
      final written = writer.writeDocument(doc);

      final parseResult2 = PROVNDocumentParser.parse(written);
      expect(parseResult2, isNot(isA<Failure>()));

      final doc2 = parseResult2.value;

      // Verify structure is preserved
      expect(doc2.namespaces.length, equals(doc.namespaces.length));
      expect(doc2.expressions.length, equals(doc.expressions.length));

      // Check each expression type is preserved
      for (var i = 0; i < doc.expressions.length; i++) {
        expect(doc2.expressions[i].runtimeType,
            equals(doc.expressions[i].runtimeType));
      }
    });

    test('Expression list round-trip', () {
      final expressions = [
        EntityExpression('ex:e1', []),
        AgentExpression('ex:ag1', []),
        ActivityExpression('ex:act1', [], null, null),
      ];

      final written = writer.writeExpressions(expressions);
      final parseResult = PROVNExpressionsParser.parse(written);

      expect(parseResult, isNot(isA<Failure>()));
      final parsed = parseResult.value;

      expect(parsed.length, equals(3));
      expect(parsed[0], isA<EntityExpression>());
      expect(parsed[1], isA<AgentExpression>());
      expect(parsed[2], isA<ActivityExpression>());
    });
  });

  group('Edge Cases', () {
    late PROVNWriter writer;

    setUp(() {
      writer = PROVNWriter();
    });

    test('Empty document round-trip', () {
      final provn = '''document
endDocument''';

      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult, isNot(isA<Failure>()));

      final doc = parseResult.value;
      final written = writer.writeDocument(doc);

      final parseResult2 = PROVNDocumentParser.parse(written);
      expect(parseResult2, isNot(isA<Failure>()));

      final doc2 = parseResult2.value;
      expect(doc2.expressions.isEmpty, isTrue);
      expect(doc2.namespaces.isEmpty, isTrue);
    });

    test('String attributes with special characters round-trip', () {
      final provn = '''document
  entity(ex:test, [ex:desc="Line 1\\nLine 2\\tTabbed", ex:quoted="\\"quoted\\""])
endDocument''';

      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult, isNot(isA<Failure>()));

      final doc = parseResult.value;
      final written = writer.writeDocument(doc);

      final parseResult2 = PROVNDocumentParser.parse(written);
      expect(parseResult2, isNot(isA<Failure>()));

      final doc2 = parseResult2.value;
      final entity1 = doc.expressions.first as EntityExpression;
      final entity2 = doc2.expressions.first as EntityExpression;

      expect(entity2.attributes.length, equals(entity1.attributes.length));
      // Note: String content comparison would need careful handling of escaped characters
    });

    test('Numeric attributes round-trip', () {
      final provn = '''document
  entity(ex:data, [ex:count=42, ex:ratio=3.14, ex:negative=-17])
endDocument''';

      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult, isNot(isA<Failure>()));

      final doc = parseResult.value;
      final written = writer.writeDocument(doc);

      final parseResult2 = PROVNDocumentParser.parse(written);
      expect(parseResult2, isNot(isA<Failure>()));

      final doc2 = parseResult2.value;
      final entity1 = doc.expressions.first as EntityExpression;
      final entity2 = doc2.expressions.first as EntityExpression;

      expect(entity2.attributes.length, equals(entity1.attributes.length));
    });
  });
}
