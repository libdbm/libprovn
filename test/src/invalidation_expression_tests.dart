import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
wasInvalidatedBy(ex:inv; tr:WD-prov-dm-20111215, ex:edit1, 2011-11-16T16:00:00,  [ex:fct="save"])
wasInvalidatedBy(tr:WD-prov-dm-20111215, ex:edit1, -)
wasInvalidatedBy(tr:WD-prov-dm-20111215, ex:edit1, 2011-11-16T16:00:00)
wasInvalidatedBy(e2, a1, -, [ex:fct="save"])
wasInvalidatedBy(e2, -, -, [ex:fct="save"])
wasInvalidatedBy(ex:inv; tr:WD-prov-dm-20111215, ex:edit1, -)
wasInvalidatedBy(tr:WD-prov-dm-20111215, ex:edit1, -)
 */
void main() {
  group('invalidationGrammar', () {
    test('invalidationWithName', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('wasInvalidatedBy(foo)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as InvalidationExpression;
      expect(e.entityId, 'foo');
      expect(e.attributes.length, 0);
    });
    test('invalidationWithOptionalName', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('wasInvalidatedBy(foo; bar)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as InvalidationExpression;
      expect(e.id, 'foo');
      expect(e.entityId, 'bar');
      expect(e.attributes.length, 0);
    });
    test('invalidationWithOptionalNameAndAdditionalTime', () {
      final parser = PROVNExpressionsParser;
      final expressions =
          parser.parse('wasInvalidatedBy(foo; bar, baz, 1999-11-19T00:01:02Z)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as InvalidationExpression;
      print(e);
      expect(e.id, 'foo');
      expect(e.entityId, 'bar');
      expect(e.activityId, 'baz');
      expect(e.attributes.length, 0);
    });
    test('invalidationWithAllComponents', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse(
          'wasInvalidatedBy(foo; bar, baz, 1999-11-19T00:01:02Z,[foo=1234])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as InvalidationExpression;
      expect(e.id, 'foo');
      expect(e.entityId, 'bar');
      expect(e.activityId, 'baz');
      expect(e.attributes.length, 1);
    });
    test('invalidationWithMarkers', () {
      final parser = PROVNExpressionsParser;
      final expressions =
          parser.parse('wasInvalidatedBy(_; bar, _, _,[foo=1234])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as InvalidationExpression;
      expect(e.id, null);
      expect(e.entityId, 'bar');
      expect(e.activityId, null);
      expect(e.attributes.length, 1);
    });
  });
}
