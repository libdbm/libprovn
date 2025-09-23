import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
wasEndedBy(ex:end; ex:act2, ex:trigger, ex:act3,  2011-11-16T16:00:00, [ex:param="a"])
wasEndedBy(ex:act2, ex:trigger, -, -)
wasEndedBy(ex:act2, ex:trigger, -, 2011-11-16T16:00:00)
wasEndedBy(ex:act2, -, -, 2011-11-16T16:00:00)
wasEndedBy(ex:act2, -, -, 2011-11-16T16:00:00, [ex:param="a"])
wasEndedBy(ex:end; ex:act2)
wasEndedBy(ex:end; ex:act2, ex:trigger, -, 2011-11-16T16:00:00)
 */
void main() {
  group('endGrammar', () {
    test('endWithName', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('wasEndedBy(foo)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as EndExpression;
      expect(e.activityId, 'foo');
      expect(e.attributes.length, 0);
    });
    test('endWithOptionalName', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('wasEndedBy(foo; bar)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as EndExpression;
      expect(e.id, 'foo');
      expect(e.activityId, 'bar');
      expect(e.attributes.length, 0);
    });
    test('endWithOptionalNameAndAdditionalTime', () {
      final parser = PROVNExpressionsParser;
      final expressions =
          parser.parse('wasEndedBy(foo; bar, baz, qux, 1999-11-19T00:01:02Z)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as EndExpression;
      print(e);
      expect(e.id, 'foo');
      expect(e.activityId, 'bar');
      expect(e.entityId, 'baz');
      expect(e.enderId, 'qux');
      expect(e.attributes.length, 0);
    });
    test('endWithAllComponents', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse(
          'wasEndedBy(foo; bar, baz, qux, 1999-11-19T00:01:02Z,[foo=1234])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as EndExpression;
      expect(e.id, 'foo');
      expect(e.activityId, 'bar');
      expect(e.entityId, 'baz');
      expect(e.enderId, 'qux');
      expect(e.attributes.length, 1);
    });
    test('endWithMarkers', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('wasEndedBy(_; bar, _, _,_,[foo=1234])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as EndExpression;
      expect(e.id, null);
      expect(e.activityId, 'bar');
      expect(e.entityId, null);
      expect(e.enderId, null);
      expect(e.attributes.length, 1);
    });
  });
}
