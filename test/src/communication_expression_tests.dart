import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
wasInformedBy(ex:inf1; ex:a1, ex:a2, [ex:param1="a", ex:param2="b"])
wasInformedBy(ex:a1, ex:a2)
wasInformedBy(ex:a1, ex:a2, [ex:param1="a", ex:param2="b"])
wasInformedBy(ex:i; ex:a1, ex:a2)
wasInformedBy(ex:i; ex:a1, ex:a2, [ex:param1="a", ex:param2="b"])
 */
void main() {
  group('communicationGrammar', () {
    test('communicationWithAllComponents', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse(
          'wasInformedBy(ex:optionalId; informedAgentId, informantId, [ex:param1="a", ex:param2="b"])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as CommunicationExpression;
      expect(e.id, 'ex:optionalId');
      expect(e.informedAgentId, 'informedAgentId');
      expect(e.informantId, 'informantId');
      expect(e.attributes.length, 2);
    });
  });
}
