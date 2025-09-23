import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
wasAttributedTo(ex:attr; e, ag, [ex:license='cc:attributionURL' ])
wasAttributedTo(e, ag)
wasAttributedTo(e, ag, [ex:license='cc:attributionURL' ])
 */
void main() {
  group('attributionGrammar', () {
    test('attributionWithAllComponents', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse(
          'wasAttributedTo(ex:attr; entityId, agentId, [ex:license="cc:attributionURL" ])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as AttributionExpression;
      print(e);
      expect(e.id, 'ex:attr');
      expect(e.entityId, 'entityId');
      expect(e.agentId, 'agentId');
      expect(e.attributes.length, 1);
    });
  });
}
