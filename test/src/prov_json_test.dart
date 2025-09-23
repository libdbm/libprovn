import 'package:test/test.dart';
import 'package:libprovn/libprovn.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  group('PROV-JSON Tests', () {
    late PROVJSONReader reader;
    late PROVJSONWriter writer;

    setUp(() {
      reader = PROVJSONReader();
      writer = PROVJSONWriter();
    });

    test('Simple entity JSON round-trip', () {
      final json = '''{
  "entity": {
    "ex:article": {}
  }
}''';

      final doc = reader.readDocument(json);
      expect(doc.expressions.length, equals(1));
      expect(doc.expressions.first, isA<EntityExpression>());

      final entity = doc.expressions.first as EntityExpression;
      expect(entity.identifier, equals('ex:article'));

      // Write back and verify structure
      final written = writer.writeDocument(doc);
      final doc2 = reader.readDocument(written);
      expect(doc2.expressions.length, equals(1));
    });

    test('Entity with attributes JSON round-trip', () {
      final json = '''{
  "prefix": {
    "ex": "http://example.org/",
    "dcterms": "http://purl.org/dc/terms/"
  },
  "entity": {
    "ex:article": {
      "dcterms:title": "Test Article",
      "ex:version": 1
    }
  }
}''';

      final doc = reader.readDocument(json);
      expect(doc.namespaces.length, equals(2));
      expect(doc.expressions.length, equals(1));

      final entity = doc.expressions.first as EntityExpression;
      expect(entity.attributes.length, equals(2));

      // Round-trip
      final written = writer.writeDocument(doc);
      final doc2 = reader.readDocument(written);
      expect(doc2.expressions.length, equals(1));
      expect((doc2.expressions.first as EntityExpression).attributes.length,
          equals(2));
    });

    test('Activity with times JSON', () {
      final json = '''{
  "activity": {
    "ex:writing": {
      "prov:startTime": "2024-01-01T09:00:00.000Z",
      "prov:endTime": "2024-01-10T17:00:00.000Z"
    }
  }
}''';

      final doc = reader.readDocument(json);
      expect(doc.expressions.length, equals(1));

      final activity = doc.expressions.first as ActivityExpression;
      expect(activity.identifier, equals('ex:writing'));
      expect(activity.from, isNotNull);
      expect(activity.to, isNotNull);

      // Round-trip
      final written = writer.writeDocument(doc);
      final doc2 = reader.readDocument(written);
      final activity2 = doc2.expressions.first as ActivityExpression;
      expect(activity2.from, equals(activity.from));
      expect(activity2.to, equals(activity.to));
    });

    test('Generation relationship JSON', () {
      final json = '''{
  "wasGeneratedBy": {
    "_:gen1": {
      "prov:entity": "ex:article",
      "prov:activity": "ex:writing",
      "prov:time": "2024-01-10T16:45:00.000Z"
    }
  }
}''';

      final doc = reader.readDocument(json);
      expect(doc.expressions.length, equals(1));

      final gen = doc.expressions.first as GenerationExpression;
      expect(gen.entityId, equals('ex:article'));
      expect(gen.activityId, equals('ex:writing'));
      expect(gen.datetime, isNotNull);
    });

    test('Complete document JSON round-trip', () {
      final json = '''{
  "prefix": {
    "ex": "http://example.org/",
    "foaf": "http://xmlns.com/foaf/0.1/"
  },
  "entity": {
    "ex:article": {
      "foaf:title": "Test Article"
    }
  },
  "agent": {
    "ex:author": {
      "foaf:name": "Alice"
    }
  },
  "activity": {
    "ex:writing": {
      "prov:startTime": "2024-01-01T09:00:00.000Z",
      "prov:endTime": "2024-01-10T17:00:00.000Z"
    }
  },
  "wasGeneratedBy": {
    "_:gen1": {
      "prov:entity": "ex:article",
      "prov:activity": "ex:writing",
      "prov:time": "2024-01-10T16:45:00.000Z"
    }
  },
  "wasAttributedTo": {
    "_:attr1": {
      "prov:entity": "ex:article",
      "prov:agent": "ex:author"
    }
  },
  "wasAssociatedWith": {
    "_:assoc1": {
      "prov:activity": "ex:writing",
      "prov:agent": "ex:author"
    }
  }
}''';

      final doc = reader.readDocument(json);
      expect(doc.namespaces.length, equals(2));
      expect(doc.expressions.length, equals(6));

      // Count expression types
      var entities = 0, agents = 0, activities = 0;
      var generations = 0, attributions = 0, associations = 0;

      for (final expr in doc.expressions) {
        switch (expr) {
          case EntityExpression():
            entities++;
          case AgentExpression():
            agents++;
          case ActivityExpression():
            activities++;
          case GenerationExpression():
            generations++;
          case AttributionExpression():
            attributions++;
          case AssociationExpression():
            associations++;
        }
      }

      expect(entities, equals(1));
      expect(agents, equals(1));
      expect(activities, equals(1));
      expect(generations, equals(1));
      expect(attributions, equals(1));
      expect(associations, equals(1));

      // Round-trip
      final written = writer.writeDocument(doc);
      final doc2 = reader.readDocument(written);
      expect(doc2.expressions.length, equals(doc.expressions.length));
    });

    test('Bundle JSON round-trip', () {
      final json = '''{
  "bundle": {
    "ex:revisions": {
      "entity": {
        "ex:article_v2": {}
      },
      "wasDerivedFrom": {
        "_:deriv1": {
          "prov:generatedEntity": "ex:article_v2",
          "prov:usedEntity": "ex:article"
        }
      }
    }
  }
}''';

      final doc = reader.readDocument(json);
      expect(doc.expressions.length, equals(1));
      expect(doc.expressions.first, isA<BundleExpression>());

      final bundle = doc.expressions.first as BundleExpression;
      expect(bundle.identifier, equals('ex:revisions'));
      expect(bundle.expressions.length, equals(2));

      // Round-trip
      final written = writer.writeDocument(doc);
      final doc2 = reader.readDocument(written);
      final bundle2 = doc2.expressions.first as BundleExpression;
      expect(bundle2.expressions.length, equals(2));
    });

    test('PROV-N to JSON conversion', () {
      final provn = '''document
  prefix ex <http://example.org/>

  entity(ex:article, [ex:title="Test"])
  agent(ex:author, [ex:name="Alice"])
  wasAttributedTo(ex:article, ex:author)
endDocument''';

      // Parse PROV-N
      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult, isNot(isA<Failure>()));

      final doc = parseResult.value;

      // Convert to JSON
      final json = writer.writeDocument(doc);
      expect(json, contains('"entity"'));
      expect(json, contains('"agent"'));
      expect(json, contains('"wasAttributedTo"'));

      // Parse JSON back
      final doc2 = reader.readDocument(json);
      expect(doc2.expressions.length, equals(3));

      // Convert back to PROV-N
      final provnWriter = PROVNWriter();
      final provn2 = provnWriter.writeDocument(doc2);
      expect(provn2, contains('entity(ex:article'));
      expect(provn2, contains('agent(ex:author'));
      expect(provn2, contains('wasAttributedTo'));
    });

    test('JSON to PROV-N conversion', () {
      final json = '''{
  "prefix": {
    "ex": "http://example.org/"
  },
  "entity": {
    "ex:data": {
      "ex:value": 42
    }
  },
  "activity": {
    "ex:process": {}
  },
  "wasGeneratedBy": {
    "_:gen": {
      "prov:entity": "ex:data",
      "prov:activity": "ex:process"
    }
  }
}''';

      // Parse JSON
      final doc = reader.readDocument(json);
      expect(doc.expressions.length, equals(3));

      // Convert to PROV-N
      final provnWriter = PROVNWriter();
      final provn = provnWriter.writeDocument(doc);
      expect(provn, contains('prefix ex <http://example.org/>'));
      expect(provn, contains('entity(ex:data'));
      expect(provn, contains('activity(ex:process'));
      expect(provn, contains('wasGeneratedBy'));

      // Parse PROV-N back
      final parseResult = PROVNDocumentParser.parse(provn);
      expect(parseResult, isNot(isA<Failure>()));

      final doc2 = parseResult.value;
      expect(doc2.expressions.length, equals(3));
    });

    test('All relation types JSON', () {
      final json = '''{
  "wasDerivedFrom": {
    "_:d1": {
      "prov:generatedEntity": "ex:e2",
      "prov:usedEntity": "ex:e1"
    }
  },
  "wasInformedBy": {
    "_:c1": {
      "prov:informed": "ex:a2",
      "prov:informant": "ex:a1"
    }
  },
  "wasStartedBy": {
    "_:s1": {
      "prov:activity": "ex:act",
      "prov:trigger": "ex:entity",
      "prov:time": "2024-01-01T00:00:00.000Z"
    }
  },
  "wasEndedBy": {
    "_:e1": {
      "prov:activity": "ex:act",
      "prov:trigger": "ex:entity",
      "prov:time": "2024-01-01T01:00:00.000Z"
    }
  },
  "wasInvalidatedBy": {
    "_:i1": {
      "prov:entity": "ex:old",
      "prov:activity": "ex:delete"
    }
  },
  "specializationOf": {
    "_:sp1": {
      "prov:specificEntity": "ex:specific",
      "prov:generalEntity": "ex:general"
    }
  },
  "alternateOf": {
    "_:alt1": {
      "prov:alternate1": "ex:v1",
      "prov:alternate2": "ex:v2"
    }
  },
  "hadMember": {
    "_:mem1": {
      "prov:collection": "ex:set",
      "prov:entity": "ex:item"
    }
  },
  "wasInfluencedBy": {
    "_:inf1": {
      "prov:influencee": "ex:e1",
      "prov:influencer": "ex:e2"
    }
  },
  "actedOnBehalfOf": {
    "_:del1": {
      "prov:delegate": "ex:bob",
      "prov:responsible": "ex:alice"
    }
  }
}''';

      final doc = reader.readDocument(json);
      expect(doc.expressions.length, equals(10));

      // Verify each type
      final types = <Type>{};
      for (final expr in doc.expressions) {
        types.add(expr.runtimeType);
      }

      expect(types, contains(DerivationExpression));
      expect(types, contains(CommunicationExpression));
      expect(types, contains(StartExpression));
      expect(types, contains(EndExpression));
      expect(types, contains(InvalidationExpression));
      expect(types, contains(SpecializationExpression));
      expect(types, contains(AlternateExpression));
      expect(types, contains(MembershipExpression));
      expect(types, contains(InfluenceExpression));
      expect(types, contains(DelegationExpression));

      // Round-trip
      final written = writer.writeDocument(doc);
      final doc2 = reader.readDocument(written);
      expect(doc2.expressions.length, equals(10));
    });
  });
}
