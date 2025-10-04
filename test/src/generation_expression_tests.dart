import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
wasGeneratedBy(ex:g1; tr:WD-prov-dm-20111215, ex:edit1, 2011-11-16T16:00:00,  [ex:fct="save"])
wasGeneratedBy(e2, a1, -)
wasGeneratedBy(e2, a1, 2011-11-16T16:00:00)
wasGeneratedBy(e2, a1, -, [ex:fct="save"])
wasGeneratedBy(e2, [ex:fct="save"])
wasGeneratedBy(ex:g1; e)
wasGeneratedBy(ex:g1; e, a, tr:WD-prov-dm-20111215)
 */
void main() {
  group('generationGrammar', () {
    test('generationWithQualifiedName', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('wasGeneratedBy(ex:g1)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as GenerationExpression;
      expect(e.entityId, 'ex:g1');
      expect(e.attributes.length, 0);
    });
    test('generationWithQualifiedNameAndAgentWithMarker', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('wasGeneratedBy(e2, a1, -)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as GenerationExpression;
      expect(e.entityId, 'e2');
      expect(e.attributes.length, 0);
    });
    test('generationWithQualifiedNameAndActivityWithTime', () {
      final parser = PROVNExpressionsParser;
      final expressions =
          parser.parse('wasGeneratedBy(e:e2, a:a1, 2011-11-16T16:00:00)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as GenerationExpression;
      expect(e.entityId, 'e:e2');
      expect(e.activityId, 'a:a1');
      expect(e.attributes.length, 0);
    });
    test('generationWithQualifiedNameAndMarkerWithTime', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser
          .parse('wasGeneratedBy(ex:e2, - , 2008-08-30T01:45:36.123-08:00)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as GenerationExpression;
      expect(e.entityId, 'ex:e2');
      expect(e.activityId, null);
      expect(e.attributes.length, 0);
    });
    test('generationWithName', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('wasGeneratedBy(g1)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as GenerationExpression;
      expect(e.entityId, 'g1');
      expect(e.attributes.length, 0);
    });
    test('generationWithOptionalName', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('wasGeneratedBy(foo; bar)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as GenerationExpression;
      expect(e.id, 'foo');
      expect(e.entityId, 'bar');
      expect(e.attributes.length, 0);
    });
    test('generationWithOptionalNameAndAdditionalTime', () {
      final parser = PROVNExpressionsParser;
      final expressions =
          parser.parse('wasGeneratedBy(foo; bar, baz, 1999-11-19T00:01:02Z)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as GenerationExpression;
      print(e);
      expect(e.id, 'foo');
      expect(e.entityId, 'bar');
      expect(e.activityId, 'baz');
      expect(e.attributes.length, 0);
    });
    test('generationWithAllComponents', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse(
          'wasGeneratedBy(foo; bar, baz, 1999-11-19T00:01:02Z,[foo=1234])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as GenerationExpression;
      expect(e.id, 'foo');
      expect(e.entityId, 'bar');
      expect(e.activityId, 'baz');
      expect(e.attributes.length, 1);
    });
    test('generationWithMarkers', () {
      final parser = PROVNExpressionsParser;
      final expressions =
          parser.parse('wasGeneratedBy(_; bar, -, -,[foo=1234])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as GenerationExpression;
      expect(e.id, null);
      expect(e.entityId, 'bar');
      expect(e.activityId, null);
      expect(e.attributes.length, 1);
    });
  });
}
