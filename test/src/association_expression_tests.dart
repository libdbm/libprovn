import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
wasAssociatedWith(ex:assoc; ex:a1, ex:ag1, ex:e1, [ex:param1="a", ex:param2="b"])
wasAssociatedWith(ex:a1, -, ex:e1)
wasAssociatedWith(ex:a1, ex:ag1)
wasAssociatedWith(ex:a1, ex:ag1, ex:e1)
wasAssociatedWith(ex:a1, ex:ag1, ex:e1, [ex:param1="a", ex:param2="b"])
wasAssociatedWith(ex:assoc; ex:a1, -, ex:e1)
 */
void main() {
  group('W3C Association Examples', () {
    test(
        'wasAssociatedWith(ex:assoc; ex:a1, ex:ag1, ex:e1, [ex:param1="a", ex:param2="b"])',
        () {
      final parser = PROVNExpressionsParser;
      final entities = parser.parse(
          'wasAssociatedWith(ex:assoc; ex:a1, ex:ag1, ex:e1, [ex:param1="a", ex:param2="b"])');
      expect(entities.value.length, 1);

      final e = entities.value[0] as AssociationExpression;
      expect(e.id, 'ex:assoc');
      expect(e.activityId, 'ex:a1');
      expect(e.agentId, 'ex:ag1');
      expect(e.planId, 'ex:e1');
      expect(e.attributes.length, 2);
      expect(e.attributes[0].name, 'ex:param1');
      expect(e.attributes[0].value, 'a');
      expect(e.attributes[1].name, 'ex:param2');
      expect(e.attributes[1].value, 'b');
    });
    test('wasAssociatedWith(ex:a1, -, ex:e1)', () {
      final parser = PROVNExpressionsParser;
      final entities = parser.parse('wasAssociatedWith(ex:a1, -, ex:e1)');
      expect(entities.value.length, 1);

      final e = entities.value[0] as AssociationExpression;
      expect(e.id, null);
      expect(e.activityId, 'ex:a1');
      expect(e.agentId, null);
      expect(e.planId, 'ex:e1');
      expect(e.attributes.length, 0);
    });
    test('wasAssociatedWith(ex:a1, ex:ag1)', () {
      final parser = PROVNExpressionsParser;
      final entities = parser.parse('wasAssociatedWith(ex:a1, ex:ag1)');
      expect(entities.value.length, 1);

      final e = entities.value[0] as AssociationExpression;
      expect(e.id, null);
      expect(e.activityId, 'ex:a1');
      expect(e.agentId, 'ex:ag1');
      expect(e.planId, null);
      expect(e.attributes.length, 0);
    });
  });
  group('associationGrammar', () {
    test('associationWithAllComponents', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse(
          'wasAssociatedWith(ex:assoc; activityId, agentId, planId, [ex:param1="a", ex:param2="b"])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as AssociationExpression;
      print(e);
      expect(e.id, 'ex:assoc');
      expect(e.activityId, 'activityId');
      expect(e.agentId, 'agentId');
      expect(e.planId, 'planId');
      expect(e.attributes.length, 2);
    });
  });
}
