import 'package:test/test.dart';
import 'package:libprovn/libprovn.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  group('Format Round-trip Tests', () {
    late PROVNWriter provnWriter;
    late PROVJSONReader jsonReader;
    late PROVJSONWriter jsonWriter;

    setUp(() {
      provnWriter = PROVNWriter();
      jsonReader = PROVJSONReader();
      jsonWriter = PROVJSONWriter();
    });

    test('PROV-N → JSON → PROV-N round-trip', () {
      final originalProvn = '''document
  prefix ex <http://example.org/>
  prefix foaf <http://xmlns.com/foaf/0.1/>

  entity(ex:article, [foaf:title="Test Article", ex:version=1])
  agent(ex:author, [foaf:name="Alice"])
  activity(ex:writing, 2024-01-01T09:00:00, 2024-01-10T17:00:00)

  wasGeneratedBy(ex:article, ex:writing, 2024-01-10T16:45:00)
  wasAttributedTo(ex:article, ex:author)
  wasAssociatedWith(ex:writing, ex:author, -)

  specializationOf(ex:article, ex:document)
  alternateOf(ex:article, ex:article_v2)
endDocument''';

      // Parse PROV-N
      final parseResult = PROVNDocumentParser.parse(originalProvn);
      expect(parseResult, isNot(isA<Failure>()));
      final doc1 = parseResult.value;

      // Convert to JSON
      final json = jsonWriter.writeDocument(doc1);
      expect(json, contains('"entity"'));
      expect(json, contains('"agent"'));
      expect(json, contains('"activity"'));

      // Parse JSON back to Document
      final doc2 = jsonReader.readDocument(json);
      expect(doc2.expressions.length, equals(doc1.expressions.length));
      expect(doc2.namespaces.length, equals(doc1.namespaces.length));

      // Convert back to PROV-N
      final provn2 = provnWriter.writeDocument(doc2);

      // Parse the regenerated PROV-N
      final parseResult2 = PROVNDocumentParser.parse(provn2);
      expect(parseResult2, isNot(isA<Failure>()));
      final doc3 = parseResult2.value;

      // Verify same number of expressions
      expect(doc3.expressions.length, equals(doc1.expressions.length));
      expect(doc3.namespaces.length, equals(doc1.namespaces.length));

      // Verify expression types are preserved
      final types1 = doc1.expressions.map((e) => e.runtimeType).toSet();
      final types3 = doc3.expressions.map((e) => e.runtimeType).toSet();
      expect(types3, equals(types1));
    });

    test('JSON → PROV-N → JSON round-trip', () {
      final originalJson = '''{
  "prefix": {
    "ex": "http://example.org/",
    "dcterms": "http://purl.org/dc/terms/"
  },
  "entity": {
    "ex:report": {
      "dcterms:title": "Annual Report",
      "ex:year": 2024
    },
    "ex:data": {
      "ex:size": 1024,
      "ex:format": "CSV"
    }
  },
  "activity": {
    "ex:analysis": {
      "prov:startTime": "2024-02-01T10:00:00.000Z",
      "prov:endTime": "2024-02-05T18:00:00.000Z",
      "ex:tool": "DataAnalyzer"
    }
  },
  "agent": {
    "ex:analyst": {
      "foaf:name": "Bob",
      "ex:department": "Research"
    }
  },
  "wasGeneratedBy": {
    "_:gen1": {
      "prov:entity": "ex:report",
      "prov:activity": "ex:analysis",
      "prov:time": "2024-02-05T17:30:00.000Z"
    }
  },
  "used": {
    "_:use1": {
      "prov:activity": "ex:analysis",
      "prov:entity": "ex:data",
      "prov:time": "2024-02-01T10:30:00.000Z"
    }
  },
  "wasAssociatedWith": {
    "_:assoc1": {
      "prov:activity": "ex:analysis",
      "prov:agent": "ex:analyst"
    }
  },
  "wasAttributedTo": {
    "_:attr1": {
      "prov:entity": "ex:report",
      "prov:agent": "ex:analyst"
    }
  }
}''';

      // Parse JSON
      final doc1 = jsonReader.readDocument(originalJson);
      expect(doc1.expressions.length,
          equals(8)); // 2 entities, 1 activity, 1 agent, 4 relations

      // Convert to PROV-N
      final provn = provnWriter.writeDocument(doc1);
      expect(provn, contains('entity(ex:report'));
      expect(provn, contains('entity(ex:data'));
      expect(provn, contains('activity(ex:analysis'));
      expect(provn, contains('agent(ex:analyst'));

      // Parse PROV-N back
      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult, isNot(isA<Failure>()));
      final doc2 = parseResult.value;

      // Convert back to JSON
      final json2 = jsonWriter.writeDocument(doc2);

      // Parse the regenerated JSON
      final doc3 = jsonReader.readDocument(json2);

      // Verify same structure
      expect(doc3.expressions.length, equals(doc1.expressions.length));
      expect(doc3.namespaces.length, equals(doc1.namespaces.length));

      // Count expression types
      int countType<T>(DocumentExpression doc) =>
          doc.expressions.whereType<T>().length;

      expect(countType<EntityExpression>(doc3),
          equals(countType<EntityExpression>(doc1)));
      expect(countType<ActivityExpression>(doc3),
          equals(countType<ActivityExpression>(doc1)));
      expect(countType<AgentExpression>(doc3),
          equals(countType<AgentExpression>(doc1)));
      expect(countType<GenerationExpression>(doc3),
          equals(countType<GenerationExpression>(doc1)));
      expect(countType<UsageExpression>(doc3),
          equals(countType<UsageExpression>(doc1)));
      expect(countType<AssociationExpression>(doc3),
          equals(countType<AssociationExpression>(doc1)));
      expect(countType<AttributionExpression>(doc3),
          equals(countType<AttributionExpression>(doc1)));
    });

    test('Complex document with all expression types round-trip', () {
      final complexProvn = '''document
  prefix ex <http://example.org/>
  prefix foaf <http://xmlns.com/foaf/0.1/>

  entity(ex:e1, [ex:attr="value1"])
  entity(ex:e2, [ex:attr="value2"])
  activity(ex:a1, 2024-01-01T00:00:00, 2024-01-01T01:00:00)
  activity(ex:a2, 2024-01-02T00:00:00, 2024-01-02T01:00:00)
  agent(ex:ag1, [foaf:name="Agent1"])
  agent(ex:ag2, [foaf:name="Agent2"])

  wasGeneratedBy(ex:e1, ex:a1, 2024-01-01T00:30:00)
  used(ex:a1, ex:e2, 2024-01-01T00:15:00)
  wasAttributedTo(ex:e1, ex:ag1)
  wasAssociatedWith(ex:a1, ex:ag1, -)
  actedOnBehalfOf(ex:ag2, ex:ag1, ex:a1)
  wasDerivedFrom(ex:e1, ex:e2)
  wasInformedBy(ex:a2, ex:a1)
  wasStartedBy(ex:a1, ex:e2, -, 2024-01-01T00:00:00)
  wasEndedBy(ex:a1, ex:e1, -, 2024-01-01T01:00:00)
  wasInvalidatedBy(ex:e2, ex:a2, 2024-01-02T00:30:00)
  specializationOf(ex:e1, ex:e2)
  alternateOf(ex:e1, ex:e2)
  hadMember(ex:e1, ex:e2)
  wasInfluencedBy(ex:e1, ex:e2)

  bundle ex:bundle1
    entity(ex:e3)
    wasDerivedFrom(ex:e3, ex:e1)
  endBundle
endDocument''';

      // Parse original PROV-N
      final parseResult = PROVNDocumentParser.parse(complexProvn);
      expect(parseResult, isNot(isA<Failure>()));
      final doc1 = parseResult.value;

      // PROV-N → JSON → PROV-N
      final json = jsonWriter.writeDocument(doc1);
      final doc2 = jsonReader.readDocument(json);
      final provn2 = provnWriter.writeDocument(doc2);
      final parseResult2 = PROVNDocumentParser.parse(provn2);
      expect(parseResult2, isNot(isA<Failure>()));
      final doc3 = parseResult2.value;

      // JSON → PROV-N → JSON
      final json2 = jsonWriter.writeDocument(doc3);
      final doc4 = jsonReader.readDocument(json2);

      // Verify expression counts
      expect(doc4.expressions.length, equals(doc1.expressions.length));

      // Verify all expression types are preserved
      final expectedTypes = {
        EntityExpression,
        ActivityExpression,
        AgentExpression,
        GenerationExpression,
        UsageExpression,
        AttributionExpression,
        AssociationExpression,
        DelegationExpression,
        DerivationExpression,
        CommunicationExpression,
        StartExpression,
        EndExpression,
        InvalidationExpression,
        SpecializationExpression,
        AlternateExpression,
        MembershipExpression,
        InfluenceExpression,
        BundleExpression,
      };

      final actualTypes = doc4.expressions.map((e) => e.runtimeType).toSet();
      expect(actualTypes.intersection(expectedTypes).length,
          equals(doc1.expressions.map((e) => e.runtimeType).toSet().length));
    });

    test('Attributes preservation during round-trip', () {
      final provnWithAttrs = '''document
  prefix ex <http://example.org/>

  entity(ex:data, [
    ex:string="Hello World",
    ex:integer=42,
    ex:float=3.14,
    ex:negative=-100,
    ex:quoted="Line with \\"quotes\\"",
    ex:special="Tab\\there"
  ])
endDocument''';

      // Parse PROV-N
      final parseResult = PROVNDocumentParser.parse(provnWithAttrs);
      expect(parseResult, isNot(isA<Failure>()));
      final doc1 = parseResult.value;

      // Get original entity
      final entity1 = doc1.expressions.first as EntityExpression;
      expect(entity1.attributes.length, equals(6));

      // Round-trip through JSON
      final json = jsonWriter.writeDocument(doc1);
      final doc2 = jsonReader.readDocument(json);
      final provn2 = provnWriter.writeDocument(doc2);
      final parseResult2 = PROVNDocumentParser.parse(provn2);
      expect(parseResult2, isNot(isA<Failure>()));
      final doc3 = parseResult2.value;

      // Verify attributes are preserved
      final entity3 = doc3.expressions.first as EntityExpression;
      expect(entity3.attributes.length, equals(entity1.attributes.length));

      // Check specific attribute values
      final stringAttrs = entity3.attributes
          .whereType<StringAttribute>()
          .where((a) => a.name == 'ex:string')
          .toList();
      expect(stringAttrs.length, equals(1));
      expect(stringAttrs.first.value, equals('Hello World'));

      final numAttrs = entity3.attributes
          .whereType<NumericAttribute>()
          .where((a) => a.name == 'ex:integer')
          .toList();
      expect(numAttrs.length, equals(1));
      expect(numAttrs.first.value, equals(42));
    });

    test('Bundle preservation during round-trip', () {
      final provnWithBundle = '''document
  prefix ex <http://example.org/>
  prefix local <http://local.example/>

  entity(ex:main)

  bundle ex:bundle1
    prefix local <http://local.bundle/>
    entity(local:e1)
    entity(local:e2)
    wasDerivedFrom(local:e2, local:e1)
  endBundle
endDocument''';

      // Parse PROV-N
      final parseResult = PROVNDocumentParser.parse(provnWithBundle);
      expect(parseResult, isNot(isA<Failure>()));
      final doc1 = parseResult.value;

      // Find bundle
      final bundle1 = doc1.expressions.whereType<BundleExpression>().first;
      expect(bundle1.expressions.length, equals(3));
      expect(bundle1.namespaces.length, equals(1));

      // Round-trip through JSON
      final json = jsonWriter.writeDocument(doc1);
      final doc2 = jsonReader.readDocument(json);
      final provn2 = provnWriter.writeDocument(doc2);
      final parseResult2 = PROVNDocumentParser.parse(provn2);
      expect(parseResult2, isNot(isA<Failure>()));
      final doc3 = parseResult2.value;

      // Verify bundle is preserved
      final bundle3 = doc3.expressions.whereType<BundleExpression>().first;
      expect(bundle3.identifier, equals(bundle1.identifier));
      expect(bundle3.expressions.length, equals(bundle1.expressions.length));
      expect(bundle3.namespaces.length, equals(bundle1.namespaces.length));
    });

    test('DateTime precision preservation', () {
      final provnWithDates = '''document
  activity(ex:a1, 2024-01-15T10:30:45, 2024-01-15T11:30:45)
  activity(ex:a2, 2024-01-15T10:30:45.123, 2024-01-15T11:30:45.999)
  wasGeneratedBy(ex:e1, ex:a1, 2024-01-15T10:45:30)
  wasGeneratedBy(ex:e2, ex:a2, 2024-01-15T10:45:30.500)
endDocument''';

      // Parse PROV-N
      final parseResult = PROVNDocumentParser.parse(provnWithDates);
      expect(parseResult, isNot(isA<Failure>()));
      final doc1 = parseResult.value;

      // Round-trip through JSON
      final json = jsonWriter.writeDocument(doc1);
      final doc2 = jsonReader.readDocument(json);
      final provn2 = provnWriter.writeDocument(doc2);
      final parseResult2 = PROVNDocumentParser.parse(provn2);
      expect(parseResult2, isNot(isA<Failure>()));
      final doc3 = parseResult2.value;

      // Verify activities preserve times
      final activities1 =
          doc1.expressions.whereType<ActivityExpression>().toList();
      final activities3 =
          doc3.expressions.whereType<ActivityExpression>().toList();

      expect(activities3.length, equals(activities1.length));
      for (var i = 0; i < activities1.length; i++) {
        expect(activities3[i].from, equals(activities1[i].from));
        expect(activities3[i].to, equals(activities1[i].to));
      }

      // Verify generation times
      final generations1 =
          doc1.expressions.whereType<GenerationExpression>().toList();
      final generations3 =
          doc3.expressions.whereType<GenerationExpression>().toList();

      expect(generations3.length, equals(generations1.length));
      for (var i = 0; i < generations1.length; i++) {
        expect(generations3[i].datetime, equals(generations1[i].datetime));
      }
    });

    test('Namespace preservation during round-trip', () {
      final provnWithNamespaces = '''document
  prefix ex <http://example.org/>
  prefix foaf <http://xmlns.com/foaf/0.1/>
  prefix dcterms <http://purl.org/dc/terms/>
  prefix prov <http://www.w3.org/ns/prov#>

  entity(ex:doc, [
    foaf:title="Document",
    dcterms:creator="Author",
    prov:type="Document"
  ])
endDocument''';

      // Parse PROV-N
      final parseResult = PROVNDocumentParser.parse(provnWithNamespaces);
      expect(parseResult, isNot(isA<Failure>()));
      final doc1 = parseResult.value;

      // Verify original namespaces
      expect(doc1.namespaces.length, equals(4));
      final nsMap1 = Map.fromEntries(
          doc1.namespaces.map((ns) => MapEntry(ns.prefix, ns.uri)));

      // Round-trip through JSON
      final json = jsonWriter.writeDocument(doc1);
      final doc2 = jsonReader.readDocument(json);
      final provn2 = provnWriter.writeDocument(doc2);
      final parseResult2 = PROVNDocumentParser.parse(provn2);
      expect(parseResult2, isNot(isA<Failure>()));
      final doc3 = parseResult2.value;

      // Verify namespaces are preserved
      expect(doc3.namespaces.length, equals(doc1.namespaces.length));
      final nsMap3 = Map.fromEntries(
          doc3.namespaces.map((ns) => MapEntry(ns.prefix, ns.uri)));

      expect(nsMap3, equals(nsMap1));
    });
  });
}
