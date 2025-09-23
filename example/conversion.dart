import 'dart:convert';
import 'package:libprovn/libprovn.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  final jsonDocument = '''
{
  "prefix": {
    "ex": "http://example.org/",
    "prov": "http://www.w3.org/ns/prov#"
  },
  "entity": {
    "ex:article": {
      "prov:type": "Article",
      "ex:title": "Understanding Provenance",
      "ex:doi": "10.1234/example"
    },
    "ex:dataset": {
      "prov:type": "Dataset",
      "ex:format": "CSV",
      "ex:rows": 1000
    }
  },
  "activity": {
    "ex:research": {
      "prov:startTime": "2024-01-01T09:00:00",
      "prov:endTime": "2024-01-31T17:00:00",
      "ex:methodology": "Systematic Review"
    },
    "ex:analysis": {
      "prov:startTime": "2024-02-01T10:00:00",
      "prov:endTime": "2024-02-15T16:00:00"
    }
  },
  "agent": {
    "ex:author": {
      "prov:type": "Person",
      "ex:name": "Dr. Smith",
      "ex:orcid": "0000-0001-2345-6789"
    },
    "ex:institution": {
      "prov:type": "Organization",
      "ex:name": "Research Institute"
    }
  },
  "wasGeneratedBy": {
    "gen1": {
      "prov:entity": "ex:article",
      "prov:activity": "ex:research"
    },
    "gen2": {
      "prov:entity": "ex:dataset",
      "prov:activity": "ex:analysis"
    }
  },
  "used": {
    "use1": {
      "prov:activity": "ex:analysis",
      "prov:entity": "ex:dataset"
    }
  },
  "wasAttributedTo": {
    "attr1": {
      "prov:entity": "ex:article",
      "prov:agent": "ex:author"
    }
  },
  "wasAssociatedWith": {
    "assoc1": {
      "prov:activity": "ex:research",
      "prov:agent": "ex:author",
      "prov:role": "Principal Investigator"
    }
  },
  "actedOnBehalfOf": {
    "del1": {
      "prov:delegate": "ex:author",
      "prov:responsible": "ex:institution"
    }
  }
}
''';

  print('Converting PROV-JSON to PROV-N\n');
  print('Original PROV-JSON (abbreviated):');
  print('=' * 50);
  final json = jsonDecode(jsonDocument);
  print('Entities: ${(json['entity'] as Map).keys.join(', ')}');
  print('Activities: ${(json['activity'] as Map).keys.join(', ')}');
  print('Agents: ${(json['agent'] as Map).keys.join(', ')}\n');

  // Read PROV-JSON
  final reader = PROVJSONReader();
  final document = reader.readDocument(jsonDocument);

  print('Parsed document contains:');
  print('  - ${document.namespaces.length} namespaces');
  print('  - ${document.expressions.length} expressions\n');

  // Convert to PROV-N
  final writer = PROVNWriter();
  final provn = writer.writeDocument(document);

  print('Converted PROV-N:');
  print('=' * 50);
  print(provn);

  // Parse the PROV-N back to verify round-trip
  print('\nVerifying round-trip conversion...');
  final result = PROVNDocumentParser.parse(provn);

  if (result is Success) {
    final parsed = result.value;
    print('Successfully parsed generated PROV-N');
    print('  - Original expressions: ${document.expressions.length}');
    print('  - Reparsed expressions: ${parsed.expressions.length}');

    // Convert back to JSON
    final reloaded = PROVJSONWriter().writeDocument(parsed);
    final derived = jsonDecode(reloaded);

    print('\nRound-trip successful!');
    print(
        '  Entities preserved: ${(derived['entity'] as Map?)?.keys.join(', ') ?? 'none'}');
    print(
        '  Activities preserved: ${(derived['activity'] as Map?)?.keys.join(', ') ?? 'none'}');
    print(
        '  Agents preserved: ${(derived['agent'] as Map?)?.keys.join(', ') ?? 'none'}');
  } else {
    print('✗ Failed to parse generated PROV-N');
  }
}
