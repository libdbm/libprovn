import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
actedOnBehalfOf(ex:del1; ex:ag2, ex:ag1, ex:a, [prov:type="contract"])
actedOnBehalfOf(ex:ag1, ex:ag2)
actedOnBehalfOf(ex:ag1, ex:ag2, ex:a)
actedOnBehalfOf(ex:ag1, ex:ag2, -, [prov:type="delegation"])
actedOnBehalfOf(ex:ag2, ex:ag3, ex:a, [prov:type="contract"])
actedOnBehalfOf(ex:del1; ex:ag2, ex:ag3, ex:a, [prov:type="contract"])
 */
void main() {
  group('delegationGrammar', () {
    test('delegationWithAllComponents', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse(
          'actedOnBehalfOf(ex:optionalId; delegateId, agentId, activityId, [prov:type="contract"])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as DelegationExpression;
      print(e);
      expect(e.id, 'ex:optionalId');
      expect(e.delegateId, 'delegateId');
      expect(e.agentId, 'agentId');
      expect(e.activityId, 'activityId');
      expect(e.attributes.length, 1);
    });
  });
}
