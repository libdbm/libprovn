import 'package:test/test.dart';
import 'package:libprovn/libprovn.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  group('Edge Cases', () {
    group('DateTime Formats', () {
      test('All supported datetime formats', () {
        final formats = [
          '2024-01-15T10:00:00',
          '2024-01-15T10:00:00.000',
          '2024-01-15T10:00:00Z',
          '2024-01-15T10:00:00.000Z',
          '2024-01-15T10:00:00.123Z',
          '2024-01-15T10:00:00.999Z',
        ];

        for (final format in formats) {
          final provn =
              'document\nactivity(ex:a, $format, $format)\nendDocument';
          final result = PROVNDocumentParser.parse(provn);
          expect(result, isNot(isA<Failure>()),
              reason: 'Failed to parse: $format');
        }
      });

      test('DateTime round-trip preserves value', () {
        final provn = '''document
  activity(ex:a, 2024-01-15T10:00:00, 2024-01-15T11:30:00)
endDocument''';

        final result = PROVNDocumentParser.parse(provn);
        expect(result, isNot(isA<Failure>()));

        final doc = result.value;
        final activity = doc.expressions.first as ActivityExpression;

        expect(activity.from?.year, equals(2024));
        expect(activity.from?.month, equals(1));
        expect(activity.from?.day, equals(15));
        expect(activity.from?.hour, equals(10));
        expect(activity.from?.minute, equals(0));

        // Round-trip
        final writer = PROVNWriter();
        final written = writer.writeDocument(doc);
        final reparse = PROVNDocumentParser.parse(written);
        expect(reparse, isNot(isA<Failure>()));
      });
    });

    group('Namespace Declarations', () {
      test('Single namespace declaration', () {
        final provn = '''document
  prefix ex <http://example.org/>
  entity(ex:e1)
endDocument''';

        final result = PROVNDocumentParser.parse(provn);
        expect(result, isNot(isA<Failure>()));

        final doc = result.value;
        expect(doc.namespaces, hasLength(1));
        expect(doc.namespaces.first.prefix, equals('ex'));
        expect(doc.namespaces.first.uri, equals('http://example.org/'));
      });

      test('Multiple namespace declarations', () {
        final provn = '''document
  prefix ex <http://example.org/>
  prefix foaf <http://xmlns.com/foaf/0.1/>
  prefix dcterms <http://purl.org/dc/terms/>
  entity(ex:e1)
endDocument''';

        final result = PROVNDocumentParser.parse(provn);
        expect(result, isNot(isA<Failure>()));

        final doc = result.value;
        expect(doc.namespaces, hasLength(3));
      });

      test('Default namespace declaration', () {
        final provn = '''document
  default <http://example.org/>
  entity(e1)
endDocument''';

        final result = PROVNDocumentParser.parse(provn);
        expect(result, isNot(isA<Failure>()));

        final doc = result.value;
        expect(doc.namespaces, hasLength(1));
        expect(doc.namespaces.first.prefix, equals('default'));
      });

      test('Namespace round-trip', () {
        final provn = '''document
  prefix ex <http://example.org/>
  prefix foaf <http://xmlns.com/foaf/0.1/>
  entity(ex:e1)
endDocument''';

        final result = PROVNDocumentParser.parse(provn);
        final doc = result.value;

        final writer = PROVNWriter();
        final written = writer.writeDocument(doc);

        final reparse = PROVNDocumentParser.parse(written);
        expect(reparse, isNot(isA<Failure>()));

        final doc2 = reparse.value;
        expect(doc2.namespaces, hasLength(doc.namespaces.length));
      });
    });

    group('Derivation Expression', () {
      test('EBNF-compliant derivation with all parameters', () {
        final provn = '''document
  wasDerivedFrom(ex:e2, ex:e1, ex:a, ex:g, ex:u)
endDocument''';

        final result = PROVNDocumentParser.parse(provn);
        expect(result, isNot(isA<Failure>()));

        final doc = result.value;
        final deriv = doc.expressions.first as DerivationExpression;

        expect(deriv.generatedEntityId, equals('ex:e2'));
        expect(deriv.usedEntityId, equals('ex:e1'));
        expect(deriv.activityId, equals('ex:a'));
        expect(deriv.generationId, equals('ex:g'));
        expect(deriv.usageId, equals('ex:u'));
      });

      test('EBNF-compliant derivation with markers', () {
        final provn = '''document
  wasDerivedFrom(ex:e2, ex:e1, -, -, -)
endDocument''';

        final result = PROVNDocumentParser.parse(provn);
        expect(result, isNot(isA<Failure>()));

        final doc = result.value;
        final deriv = doc.expressions.first as DerivationExpression;

        expect(deriv.generatedEntityId, equals('ex:e2'));
        expect(deriv.usedEntityId, equals('ex:e1'));
        expect(deriv.activityId, isNull);
        expect(deriv.generationId, isNull);
        expect(deriv.usageId, isNull);
      });

      test('Partial derivation becomes extensibility expression', () {
        final provn = '''document
  wasDerivedFrom(ex:e2, ex:e1, ex:a)
endDocument''';

        final result = PROVNDocumentParser.parse(provn);
        expect(result, isNot(isA<Failure>()));

        final doc = result.value;
        // Per EBNF, partial optional parameters should parse as extensibility
        expect(doc.expressions.first, isA<ExtensibilityExpression>());

        final ext = doc.expressions.first as ExtensibilityExpression;
        expect(ext.name, equals('wasDerivedFrom'));
        expect(ext.arguments, equals(['ex:e2', 'ex:e1', 'ex:a']));
      });
    });

    group('Attribute Values', () {
      test('String attributes with special characters', () {
        final provn = r'''document
  entity(ex:e1, [
    ex:desc="Line 1\nLine 2",
    ex:tab="Before\tAfter",
    ex:quote="He said \"Hello\"",
    ex:backslash="Path\\to\\file"
  ])
endDocument''';

        final result = PROVNDocumentParser.parse(provn);
        expect(result, isNot(isA<Failure>()));

        final doc = result.value;
        final entity = doc.expressions.first as EntityExpression;
        expect(entity.attributes, hasLength(4));
      });

      test('Numeric attributes', () {
        final provn = '''document
  entity(ex:e1, [
    ex:int=42,
    ex:negative=-17,
    ex:float=3.14,
    ex:scientific=1.23e-4
  ])
endDocument''';

        final result = PROVNDocumentParser.parse(provn);
        expect(result, isNot(isA<Failure>()));

        final doc = result.value;
        final entity = doc.expressions.first as EntityExpression;
        expect(entity.attributes, hasLength(4));
      });

      test('Mixed attribute types', () {
        final provn = '''document
  entity(ex:e1, [
    ex:name="Test Entity",
    ex:version=2,
    ex:count=100,
    ex:ratio=0.75
  ])
endDocument''';

        final result = PROVNDocumentParser.parse(provn);
        expect(result, isNot(isA<Failure>()));
      });
    });

    group('Bundle Support', () {
      test('Empty bundle', () {
        final provn = '''document
  bundle ex:b1
  endBundle
endDocument''';

        final result = PROVNDocumentParser.parse(provn);
        expect(result, isNot(isA<Failure>()));

        final doc = result.value;
        expect(doc.expressions, hasLength(1));
        expect(doc.expressions.first, isA<BundleExpression>());

        final bundle = doc.expressions.first as BundleExpression;
        expect(bundle.identifier, equals('ex:b1'));
        expect(bundle.expressions, isEmpty);
      });

      test('Bundle with namespaces', () {
        final provn = '''document
  bundle ex:b1
    prefix local <http://local.example/>
    entity(local:e1)
  endBundle
endDocument''';

        final result = PROVNDocumentParser.parse(provn);
        expect(result, isNot(isA<Failure>()));

        final doc = result.value;
        final bundle = doc.expressions.first as BundleExpression;
        expect(bundle.namespaces, hasLength(1));
        expect(bundle.expressions, hasLength(1));
      });

      test('Nested expressions in bundle', () {
        final provn = '''document
  bundle ex:b1
    entity(ex:e1)
    entity(ex:e2)
    wasDerivedFrom(ex:e2, ex:e1)
  endBundle
endDocument''';

        final result = PROVNDocumentParser.parse(provn);
        expect(result, isNot(isA<Failure>()));

        final doc = result.value;
        final bundle = doc.expressions.first as BundleExpression;
        expect(bundle.expressions, hasLength(3));
      });
    });

    group('Error Messages', () {
      test('Missing closing parenthesis shows helpful error', () {
        final provn = '''document
  entity(ex:e1
endDocument''';

        final result = PROVNDocumentParser.parse(provn);
        expect(result, isA<Failure>());

        final failure = result;
        expect(failure.message, contains('expected'));
      });

      test('Invalid namespace URI shows helpful error', () {
        final provn = '''document
  prefix ex <invalid uri
  entity(ex:e1)
endDocument''';

        final result = PROVNDocumentParser.parse(provn);
        expect(result, isA<Failure>());
      });

      test('Missing endDocument shows helpful error', () {
        final provn = '''document
  entity(ex:e1)''';

        final result = PROVNDocumentParser.parse(provn);
        expect(result, isA<Failure>());

        final failure = result;
        expect(failure.message, contains('endDocument expected'));
      });
    });

    group('Complex Round-trips', () {
      test('Document with all features round-trips correctly', () {
        final provn = '''document
  prefix ex <http://example.org/>
  prefix foaf <http://xmlns.com/foaf/0.1/>

  entity(ex:article, [foaf:title="Test Article"])
  agent(ex:author, [foaf:name="Alice"])
  activity(ex:writing, 2024-01-01T09:00:00Z, 2024-01-10T17:00:00Z)

  wasGeneratedBy(ex:article, ex:writing, 2024-01-10T16:45:00Z)
  wasAttributedTo(ex:article, ex:author)
  wasAssociatedWith(ex:writing, ex:author, -)

  specializationOf(ex:article, ex:document)
  alternateOf(ex:article, ex:article_v2)

  bundle ex:revisions
    entity(ex:article_v2)
    wasDerivedFrom(ex:article_v2, ex:article)
  endBundle
endDocument''';

        // Parse original
        final result = PROVNDocumentParser.parse(provn);
        expect(result, isNot(isA<Failure>()));

        final doc = result.value;

        // Write back
        final writer = PROVNWriter();
        final written = writer.writeDocument(doc);

        // Reparse
        final reparse = PROVNDocumentParser.parse(written);
        expect(reparse, isNot(isA<Failure>()));

        final doc2 = reparse.value;

        // Compare structure
        expect(doc2.namespaces, hasLength(doc.namespaces.length));
        expect(doc2.expressions, hasLength(doc.expressions.length));
      });
    });
  });
}
