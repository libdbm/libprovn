import 'package:libprovn/libprovn.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('Special characters in identifiers', () {
    test('Identifiers with forward slashes parse correctly', () {
      final provn = 'entity(ex:2011/01/document)';
      final result = PROVNExpressionsParser.parse(provn);

      expect(result is Success, isTrue);
      final expr = (result as Success).value.first as EntityExpression;
      expect(expr.identifier, equals('ex:2011/01/document'));
    });

    test('Identifiers with dots parse correctly', () {
      final provn = 'entity(ex:Overview.html)';
      final result = PROVNExpressionsParser.parse(provn);

      expect(result is Success, isTrue);
      final expr = (result as Success).value.first as EntityExpression;
      expect(expr.identifier, equals('ex:Overview.html'));
    });

    test('Identifiers with hash symbols parse correctly', () {
      final provn = 'entity(ex:entity#123)';
      final result = PROVNExpressionsParser.parse(provn);

      expect(result is Success, isTrue);
      final expr = (result as Success).value.first as EntityExpression;
      expect(expr.identifier, equals('ex:entity#123'));
    });

    test('Identifiers starting with digits parse correctly', () {
      final provn = 'entity(ex:2011OctDec)';
      final result = PROVNExpressionsParser.parse(provn);

      expect(result is Success, isTrue);
      final expr = (result as Success).value.first as EntityExpression;
      expect(expr.identifier, equals('ex:2011OctDec'));
    });

    test('Complex identifier with multiple special chars', () {
      final provn = 'entity(w3:2011/01/prov-wg-charter#section2)';
      final result = PROVNExpressionsParser.parse(provn);

      expect(result is Success, isTrue);
      final expr = (result as Success).value.first as EntityExpression;
      expect(expr.identifier, equals('w3:2011/01/prov-wg-charter#section2'));
    });

    test('Special characters roundtrip correctly', () {
      final original = 'entity(ex:path/to/file.html#fragment)';
      final parseResult = PROVNExpressionsParser.parse(original);

      expect(parseResult is Success, isTrue);
      final expr = (parseResult as Success).value.first;

      final writer = PROVNWriter();
      final written = writer.writeExpression(expr).trim();

      expect(written, equals(original));
    });

    test('Special characters in full document', () {
      final provn = '''document
prefix ex <http://example.org/>
prefix w3 <http://www.w3.org/>
entity(w3:2011/01/prov-wg-charter)
entity(ex:Overview.html)
entity(ex:item#123)
endDocument''';

      final result = PROVNDocumentParser.parse(provn);
      expect(result is Success, isTrue);

      final doc = (result as Success).value;
      expect(doc.expressions.length, equals(3));
      expect((doc.expressions[0] as EntityExpression).identifier,
          equals('w3:2011/01/prov-wg-charter'));
      expect((doc.expressions[1] as EntityExpression).identifier,
          equals('ex:Overview.html'));
      expect((doc.expressions[2] as EntityExpression).identifier,
          equals('ex:item#123'));
    });
  });

  group('PROV-N to JSON roundtrip with special characters', () {
    test('Forward slashes preserve through JSON roundtrip', () {
      final provn = '''document
prefix ex <http://example.org/>
entity(ex:2011/01/file)
endDocument''';

      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult is Success, isTrue);
      final doc = (parseResult as Success).value;

      final jsonWriter = PROVJSONWriter();
      final json = jsonWriter.writeDocument(doc);

      final jsonReader = PROVJSONReader();
      final docFromJson = jsonReader.readDocument(json);

      expect(docFromJson.expressions.length, equals(1));
      expect((docFromJson.expressions[0] as EntityExpression).identifier,
          equals('ex:2011/01/file'));
    });

    test('Dots preserve through JSON roundtrip', () {
      final provn = '''document
prefix ex <http://example.org/>
entity(ex:file.html)
endDocument''';

      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult is Success, isTrue);
      final doc = (parseResult as Success).value;

      final jsonWriter = PROVJSONWriter();
      final json = jsonWriter.writeDocument(doc);

      final jsonReader = PROVJSONReader();
      final docFromJson = jsonReader.readDocument(json);

      expect(docFromJson.expressions.length, equals(1));
      expect((docFromJson.expressions[0] as EntityExpression).identifier,
          equals('ex:file.html'));
    });

    test('Hash symbols preserve through JSON roundtrip', () {
      final provn = '''document
prefix ex <http://example.org/>
entity(ex:item#fragment)
endDocument''';

      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult is Success, isTrue);
      final doc = (parseResult as Success).value;

      final jsonWriter = PROVJSONWriter();
      final json = jsonWriter.writeDocument(doc);

      final jsonReader = PROVJSONReader();
      final docFromJson = jsonReader.readDocument(json);

      expect(docFromJson.expressions.length, equals(1));
      expect((docFromJson.expressions[0] as EntityExpression).identifier,
          equals('ex:item#fragment'));
    });
  });
}
