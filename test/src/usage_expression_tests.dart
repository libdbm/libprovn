import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
used(ex:u1; ex:act2, ar3:0111, 2011-11-16T16:00:00, [ex:fct="load"])
used(ex:act2)
used(ex:act2, ar3:0111, 2011-11-16T16:00:00)
used(a1,e1, -, [ex:fct="load"])
used(ex:u1; ex:act2, ar3:0111, -)
 */
void main() {
  group('usageGrammar', () {
    test('usageWithName', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('used(foo)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as UsageExpression;
      expect(e.activityId, 'foo');
      expect(e.attributes.length, 0);
    });
    test('usageWithQualifiedName', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('used(ex:act2)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as UsageExpression;
      expect(e.activityId, 'ex:act2');
      expect(e.attributes.length, 0);
    });
    test('usageWithOptionalName', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('used(foo; bar)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as UsageExpression;
      expect(e.id, 'foo');
      expect(e.activityId, 'bar');
      expect(e.attributes.length, 0);
    });
    test('usageWithOptionalNameAndAdditionalTime', () {
      final parser = PROVNExpressionsParser;
      final expressions =
          parser.parse('used(foo; bar, baz, 1999-11-19T00:01:02Z)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as UsageExpression;
      print(e);
      expect(e.id, 'foo');
      expect(e.activityId, 'bar');
      expect(e.entityId, 'baz');
      expect(e.attributes.length, 0);
    });
    test('usageWithAllComponents', () {
      final parser = PROVNExpressionsParser;
      final expressions =
          parser.parse('used(foo; bar, baz, 1999-11-19T00:01:02Z,[foo=1234])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as UsageExpression;
      expect(e.id, 'foo');
      expect(e.activityId, 'bar');
      expect(e.entityId, 'baz');
      expect(e.attributes.length, 1);
    });
    test('usageWithMarkers', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('used(_; bar, _, -,[foo=1234])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as UsageExpression;
      expect(e.id, null);
      expect(e.activityId, 'bar');
      expect(e.entityId, null);
      expect(e.attributes.length, 1);
    });
  });
}
