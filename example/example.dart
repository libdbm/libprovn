import 'package:libprovn/libprovn.dart';

void main() {
  print('Creating a PROV document programmatically...\n');

  // Create entities
  final dataFile = EntityExpression('ex:data_file', [
    StringAttribute('prov:type', 'File'),
    StringAttribute('ex:path', '/data/input.csv'),
    NumericAttribute('ex:size', 1024),
  ]);

  final results = EntityExpression('ex:results', [
    StringAttribute('prov:type', 'Dataset'),
    StringAttribute('ex:format', 'JSON'),
  ]);

  // Create activities
  final processing = ActivityExpression(
    'ex:processing',
    [StringAttribute('ex:algorithm', 'ML-Pipeline')],
    DateTime(2024, 1, 15, 9, 0),
    DateTime(2024, 1, 15, 10, 30),
  );

  final validation = ActivityExpression(
    'ex:validation',
    [],
    DateTime(2024, 1, 15, 10, 45),
    DateTime(2024, 1, 15, 11, 0),
  );

  // Create agents
  final scientist = AgentExpression('ex:scientist', [
    StringAttribute('prov:type', 'Person'),
    StringAttribute('foaf:name', 'Dr. Jane Doe'),
    StringAttribute('ex:email', 'jane.doe@example.org'),
  ]);

  final organization = AgentExpression('ex:lab', [
    StringAttribute('prov:type', 'Organization'),
    StringAttribute('foaf:name', 'Research Lab'),
  ]);

  // Create relationships
  final generation = GenerationExpression(
    null,
    'ex:results',
    'ex:processing',
    DateTime(2024, 1, 15, 10, 30),
    [],
  );

  final usage = UsageExpression(
    null,
    'ex:data_file',
    'ex:processing',
    DateTime(2024, 1, 15, 9, 0),
    [],
  );

  final attribution = AttributionExpression(
    null,
    'ex:results',
    'ex:scientist',
    [],
  );

  final association = AssociationExpression(
    null,
    'ex:processing',
    'ex:scientist',
    null,
    [StringAttribute('prov:role', 'operator')],
  );

  final delegation = DelegationExpression(
    '_:del1',
    'ex:scientist',
    'ex:lab',
    '',
    [],
  );

  // Create document with namespaces
  final document = DocumentExpression(
    [
      Namespace('ex', 'http://example.org/'),
      Namespace('prov', 'http://www.w3.org/ns/prov#'),
      Namespace('foaf', 'http://xmlns.com/foaf/0.1/'),
    ],
    [
      dataFile,
      results,
      processing,
      validation,
      scientist,
      organization,
      generation,
      usage,
      attribution,
      association,
      delegation,
    ],
  );

  // Write to PROV-N format
  print('PROV-N Output:');
  print('=' * 50);
  print(PROVNWriter().writeDocument(document));

  // Write to PROV-JSON format
  print('\nPROV-JSON Output:');
  print('=' * 50);
  print(PROVJSONWriter().writeDocument(document));
}
