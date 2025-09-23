# libprovn

[![pub package](https://img.shields.io/pub/v/libprovn.svg)](https://pub.dev/packages/libprovn)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.1.0-blue)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A comprehensive Dart library for parsing and writing W3C PROV-N (Provenance Notation) and PROV-JSON formats. This 
library provides bidirectional conversion between PROV-N and PROV-JSON with full W3C specification support.

## Features

- **Full PROV-N Parser**: Parse W3C PROV-N notation into structured Dart objects
- **PROV-JSON Support**: Read and write PROV-JSON format
- **Bidirectional Conversion**: Convert between PROV-N and PROV-JSON formats
- **W3C Compliant**: Implements the complete W3C PROV-N specification
- **Type-Safe**: Strongly typed expression classes for all PROV constructs
- **Extensible**: Support for custom PROV extensions

### Supported PROV Expression Types

- **Basic Elements**: Entity, Activity, Agent
- **Relationships**: Generation, Usage, Derivation, Attribution, Association, Delegation, Communication
- **Qualified Relations**: Start, End, Invalidation
- **Collections**: Membership
- **Advanced**: Specialization, Alternate, Influence
- **Bundles**: Named sets of provenance descriptions
- **Extensions**: Support for custom qualified names

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  libprovn: ^0.1.0
```

Then run:

```bash
dart pub get
```

## Usage

### Parsing PROV-N

```dart
import 'package:libprovn/provenance.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  final provn = '''
document
  prefix ex <http://example.org/>

  entity(ex:dataset, [ex:type="dataset"])
  activity(ex:analysis, 2023-01-15T10:00:00, 2023-01-15T11:30:00)
  agent(ex:researcher, [ex:name="Dr. Smith"])

  wasGeneratedBy(ex:dataset, ex:analysis)
  wasAttributedTo(ex:dataset, ex:researcher)
endDocument
''';

  final result = PROVNDocumentParser.parse(provn);

  if (result is Success) {
    final document = result.value;
    print('Parsed ${document.expressions.length} expressions');

    for (final expr in document.expressions) {
      switch (expr) {
        case EntityExpression(:final identifier):
          print('Entity: $identifier');
        case ActivityExpression(:final identifier):
          print('Activity: $identifier');
        case AgentExpression(:final identifier):
          print('Agent: $identifier');
        default:
          print('Expression: ${expr.runtimeType}');
      }
    }
  }
}
```

### Writing PROV-N

```dart
import 'package:libprovn/provenance.dart';

void main() {
  // Create PROV expressions
  final entity = EntityExpression('ex:dataset', [
    StringAttribute('ex:type', 'dataset')
  ]);

  final activity = ActivityExpression(
    'ex:analysis',
    [],
    DateTime.parse('2023-01-15T10:00:00'),
    DateTime.parse('2023-01-15T11:30:00'),
  );

  final agent = AgentExpression('ex:researcher', [
    StringAttribute('ex:name', 'Dr. Smith')
  ]);

  // Create document
  final document = DocumentExpression([
    Namespace('ex', 'http://example.org/')
  ], [
    entity,
    activity,
    agent,
  ]);

  // Write to PROV-N
  final writer = PROVNWriter();
  final provnText = writer.writeDocument(document);
  print(provnText);
}
```

### Converting between PROV-N and PROV-JSON

```dart
import 'package:libprovn/provenance.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  // Parse PROV-N
  final provn = '''
document
  prefix ex <http://example.org/>
  entity(ex:data)
  activity(ex:process)
  used(ex:process, ex:data)
endDocument
''';

  final result = PROVNDocumentParser.parse(provn);
  if (result is Success) {
    final document = result.value;

    // Convert to JSON
    final jsonWriter = PROVJSONWriter();
    final jsonString = jsonWriter.writeDocument(document);
    print('PROV-JSON:\n$jsonString');

    // Read JSON back
    final jsonReader = PROVJSONReader();
    final documentFromJson = jsonReader.readDocument(jsonString);

    // Convert back to PROV-N
    final provnWriter = PROVNWriter();
    final provnText = provnWriter.writeDocument(documentFromJson);
    print('PROV-N:\n$provnText');
  }
}
```

## Command Line Tool

The package includes a command-line tool for converting between PROV-N and PROV-JSON:

```bash
# Convert PROV-N to PROV-JSON
dart run libprovn:provn document.provn -o document.json

# Convert PROV-JSON to PROV-N
dart run libprovn:provn document.json -o document.provn

# Specify formats explicitly
dart run libprovn:provn -f provn -t json input.txt -o output.json

# Print to stdout
dart run libprovn:provn document.provn
```

## API Documentation

### Core Classes

#### `DocumentExpression`
Represents a complete PROV document with namespaces and expressions.

#### `EntityExpression`
Represents an entity in the provenance model.

#### `ActivityExpression`
Represents an activity that uses and generates entities.

#### `AgentExpression`
Represents an agent (person, organization, or software).

### Parsers

#### `PROVNDocumentParser`
Static parser for complete PROV-N documents.

#### `PROVNExpressionsParser`
Static parser for lists of PROV-N expressions without document wrapper.

### Writers

#### `PROVNWriter`
Writes PROV expressions to PROV-N format.

#### `PROVJSONWriter`
Writes PROV expressions to PROV-JSON format.

### Readers

#### `PROVJSONReader`
Reads PROV-JSON format into PROV expressions.

## Development

### Running Tests

```bash
dart test
```

### Running Specific Test Suites

```bash
# Test entity parsing
dart test test/src/entity_expression_tests.dart

# Test JSON conversion
dart test test/json_test.dart

# Test round-trip conversion
dart test test/format_roundtrip_test.dart
```

### Linting

```bash
dart analyze
dart format .
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## References

- [W3C PROV-N Specification](https://www.w3.org/TR/prov-n/)
- [W3C PROV-JSON Format](https://www.w3.org/Submission/2013/SUBM-prov-json-20130424/)
- [W3C PROV Overview](https://www.w3.org/TR/prov-overview/)

## Acknowledgments

Built with [PetitParser](https://pub.dev/packages/petitparser) for robust parsing capabilities.