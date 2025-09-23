import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
wasStartedBy(ex:start; ex:act2, ex:trigger, ex:act1, 2011-11-16T16:00:00, [ex:param="a"])
wasStartedBy(ex:act2, -, ex:act1, -)
wasStartedBy(ex:act2, -, ex:act1, 2011-11-16T16:00:00)
wasStartedBy(ex:act2, -, -, 2011-11-16T16:00:00)
wasStartedBy(ex:act2, [ex:param="a"])
wasStartedBy(ex:start; ex:act2, e, ex:act1, 2011-11-16T16:00:00)
 */
void main() {
  group('startGrammar', () {
    test('startWithName', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('wasStartedBy(foo)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as StartExpression;
      expect(e.activityId, 'foo');
      expect(e.attributes.length, 0);
    });
    test('startWithOptionalName', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('wasStartedBy(foo; bar)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as StartExpression;
      expect(e.id, 'foo');
      expect(e.activityId, 'bar');
      expect(e.attributes.length, 0);
    });
    test('startWithOptionalNameAndAdditionalTime', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser
          .parse('wasStartedBy(foo; bar, baz, qux, 1999-11-19T00:01:02Z)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as StartExpression;
      print(e);
      expect(e.id, 'foo');
      expect(e.activityId, 'bar');
      expect(e.entityId, 'baz');
      expect(e.starterId, 'qux');
      expect(e.attributes.length, 0);
    });
    test('startWithAllComponents', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse(
          'wasStartedBy(foo; bar, baz, qux, 1999-11-19T00:01:02Z,[foo=1234])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as StartExpression;
      expect(e.id, 'foo');
      expect(e.activityId, 'bar');
      expect(e.entityId, 'baz');
      expect(e.starterId, 'qux');
      expect(e.attributes.length, 1);
    });
    test('startWithNoOptionalIdentitifer', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse(
          'wasStartedBy(bar, baz, qux, 1999-11-19T00:01:02Z,[foo=1234])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as StartExpression;
      expect(e.id, isNull);
      expect(e.activityId, 'bar');
      expect(e.entityId, 'baz');
      expect(e.starterId, 'qux');
      expect(e.attributes.length, 1);
    });
    test('startWithMarkers', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('wasStartedBy(_;bar,_,_,_,[foo=1234])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as StartExpression;
      expect(e.id, null);
      expect(e.activityId, 'bar');
      expect(e.entityId, null);
      expect(e.starterId, null);
      expect(e.attributes.length, 1);
    });
    test('Real data', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser
          .parse('wasStartedBy(result:commit,-,-,2018-02-08T16:43:25.000Z)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as StartExpression;
      print(expressions);
      expect(e.id, null);
      expect(e.activityId, 'result:commit');
      expect(e.entityId, null);
      expect(e.starterId, null);
      expect(e.attributes.length, 0);
    });
  });
}
