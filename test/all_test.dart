import 'package:test/test.dart';

import 'src/entity_expression_tests.dart' as entity_expression_test;
import 'src/activity_expression_tests.dart' as activity_expression_test;
import 'src/generation_expression_tests.dart' as generation_expression_test;
import 'src/usage_expression_tests.dart' as usage_expression_test;
import 'src/communication_expression_tests.dart'
    as communication_expression_test;
import 'src/start_expression_tests.dart' as start_expression_test;
import 'src/end_expression_tests.dart' as end_expression_test;
import 'src/invalidation_expression_tests.dart' as invalidation_expression_test;
import 'src/derivation_expression_tests.dart' as derivation_expression_test;
import 'src/agent_expression_tests.dart' as agent_expression_test;
import 'src/attribution_expression_tests.dart' as attribution_expression_test;
import 'src/delegation_expression_tests.dart' as delegation_expression_test;
import 'src/alternate_expression_tests.dart' as alternate_expression_test;
import 'src/specialization_expression_tests.dart'
    as specialization_expression_test;
import 'src/membership_expression_tests.dart' as membership_expression_test;
import 'src/extensibility_expression_tests.dart'
    as extensibility_expression_test;
import 'src/edge_cases_test.dart' as edge_cases_test;
import 'src/provn_roundtrip_test.dart' as provn_roundtrip_test;
import 'src/prov_json_test.dart' as prov_json_test;
import 'src/format_roundtrip_test.dart' as format_roundtrip_test;
import 'src/file_parsing_tests.dart' as file_parsing_test;

void main() {
  group('entity_expressions', entity_expression_test.main);
  group('activity_expressions', activity_expression_test.main);
  group('generation_expressions', generation_expression_test.main);
  group('usage_expressions', usage_expression_test.main);
  group('communication_expressions', communication_expression_test.main);
  group('start_expressions', start_expression_test.main);
  group('end_expressions', end_expression_test.main);
  group('invalidation_expressions', invalidation_expression_test.main);
  group('derivation_expressions', derivation_expression_test.main);
  group('agent_expressions', agent_expression_test.main);
  group('attribution_expressions', attribution_expression_test.main);
  group('delegation_expressions', delegation_expression_test.main);
  group('alternate_expressions', alternate_expression_test.main);
  group('specialization_expressions', specialization_expression_test.main);
  group('membership_expressions', membership_expression_test.main);
  group('extensibility_expressions', extensibility_expression_test.main);
  group('edge_cases', edge_cases_test.main);
  group('PROV-N round trip', provn_roundtrip_test.main);
  group('PROV-JSON parsing', prov_json_test.main);
  group('PROV-JSON <-> PROV-N round trip', format_roundtrip_test.main);
  group('file parsing tests', file_parsing_test.main);
}
