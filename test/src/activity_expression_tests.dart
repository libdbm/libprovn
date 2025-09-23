import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
activity(ex:a10, 2011-11-16T16:00:00, 2011-11-16T16:00:01, [prov:type="createFile"])
activity(ex:a10)
activity(ex:a10, -, -)
activity(ex:a10, -, -, [prov:type="edit"])
activity(ex:a10, -, 2011-11-16T16:00:00)
activity(ex:a10, 2011-11-16T16:00:00, -)
activity(ex:a10, 2011-11-16T16:00:00, -, [prov:type="createFile"])
activity(ex:a10, [prov:type="edit"])
 */
void main() {
  group('W3C Activity Examples', () {
    test(
        'activity(ex:a10, 2011-11-16T16:00:00, 2011-11-16T16:00:01, [prov:type="createFile"])',
        () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse(
          'activity(ex:a10, 2011-11-16T16:00:00, 2011-11-16T16:00:01, [prov:type="createFile"])');
      expect(expressions.value.length, 1);

      final e = expressions.value[0] as ActivityExpression;
      expect(e.identifier, 'ex:a10');
      expect(e.attributes.length, 1);
      expect(e.attributes[0].name, 'prov:type');
      expect(e.attributes[0].value, 'createFile');
      expect(e.from, DateTime.parse('2011-11-16T16:00:00'));
      expect(e.to, DateTime.parse('2011-11-16T16:00:01'));
    });
    test('activity(ex:a10)', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('activity(ex:a10)');
      expect(expressions.value.length, 1);

      final e = expressions.value[0] as ActivityExpression;
      expect(e.identifier, 'ex:a10');
      expect(e.attributes.length, 0);
      expect(e.from, null);
      expect(e.to, null);
    });
    test('activity(ex:a10, -, -)', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('activity(ex:a10, -, -)');
      expect(expressions.value.length, 1);

      final e = expressions.value[0] as ActivityExpression;
      expect(e.identifier, 'ex:a10');
      expect(e.attributes.length, 0);
      expect(e.from, null);
      expect(e.to, null);
    });
    test('activity(ex:a10, -, -, [prov:type="edit"])', () {
      final parser = PROVNExpressionsParser;
      final expressions =
          parser.parse('activity(ex:a10, -, -, [prov:type="edit"])');
      expect(expressions.value.length, 1);

      final e = expressions.value[0] as ActivityExpression;
      expect(e.identifier, 'ex:a10');
      expect(e.attributes.length, 1);
      expect(e.attributes[0].name, 'prov:type');
      expect(e.attributes[0].value, 'edit');
      expect(e.from, null);
      expect(e.to, null);
    });
    test('activity(ex:a10, -, 2011-11-16T16:00:00)', () {
      final parser = PROVNExpressionsParser;
      final expressions =
          parser.parse('activity(ex:a10, -, 2011-11-16T16:00:00)');
      expect(expressions.value.length, 1);

      final e = expressions.value[0] as ActivityExpression;
      expect(e.identifier, 'ex:a10');
      expect(e.attributes.length, 0);
      expect(e.from, null);
      expect(e.to, DateTime.parse('2011-11-16T16:00:00'));
    });
    test('activity(ex:a10, 2011-11-16T16:00:00, -)', () {
      final parser = PROVNExpressionsParser;
      final expressions =
          parser.parse('activity(ex:a10, 2011-11-16T16:00:00, -)');
      expect(expressions.value.length, 1);

      final e = expressions.value[0] as ActivityExpression;
      expect(e.identifier, 'ex:a10');
      expect(e.attributes.length, 0);
      expect(e.from, DateTime.parse('2011-11-16T16:00:00'));
      expect(e.to, null);
    });
    test('activity(ex:a10, 2011-11-16T16:00:00, -, [prov:type="createFile"])',
        () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse(
          'activity(ex:a10, 2011-11-16T16:00:00, -, [prov:type="createFile"])');
      expect(expressions.value.length, 1);

      final e = expressions.value[0] as ActivityExpression;
      expect(e.identifier, 'ex:a10');
      expect(e.attributes.length, 1);
    });
    test('activity(ex:a10, [prov:type="edit"])', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('activity(ex:a10, [prov:type="edit"])');
      expect(expressions.value.length, 1);

      final e = expressions.value[0] as ActivityExpression;
      expect(e.identifier, 'ex:a10');
      expect(e.attributes.length, 1);
      expect(e.attributes[0].name, 'prov:type');
      expect(e.attributes[0].value, 'edit');
      expect(e.from, null);
      expect(e.to, null);
    });
  });
  group('activityGrammar', () {
    test('activityWithName', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('activity(foo)');
      expect(expressions.value.length, 1);

      final e = expressions.value[0] as ActivityExpression;
      expect(e.identifier, 'foo');
      expect(e.attributes.length, 0);
      expect(e.from, null);
      expect(e.to, null);
    });
    test('activityWithEmptyAttributeList', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('activity(foo,[])');
      expect(expressions.value.length, 1);

      final e = expressions.value[0] as ActivityExpression;
      expect(e.identifier, 'foo');
      expect(e.attributes.length, 0);
      expect(e.from, null);
      expect(e.to, null);
    });
    test('activityWithNumericAttribute', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('activity(foo,[a=123])');
      expect(expressions.value.length, 1);

      final e = expressions.value[0] as ActivityExpression;
      expect(e.identifier, 'foo');
      expect(e.attributes.length, 1);
      expect(e.attributes[0].name, 'a');
      expect(e.attributes[0].value, 123);
      expect(e.from, null);
      expect(e.to, null);
    });
    test('activityWithStringAttribute', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('activity(foo,[a="hello world"])');
      expect(expressions.value.length, 1);

      final e = expressions.value[0] as ActivityExpression;
      expect(e.identifier, 'foo');
      expect(e.attributes.length, 1);
      expect(e.attributes[0].name, 'a');
      expect(e.attributes[0].value, 'hello world');
      expect(e.from, null);
      expect(e.to, null);
    });
    test('activityWithMultipleAttributes', () {
      final parser = PROVNExpressionsParser;
      final expressions =
          parser.parse('activity(foo,[a=123,b=345,c="foo",d="bar"])');
      expect(expressions.value.length, 1);

      final e = expressions.value[0] as ActivityExpression;
      expect(e.identifier, 'foo');
      expect(e.attributes.length, 4);
      expect(e.attributes[0].name, 'a');
      expect(e.attributes[0].value, 123);
      expect(e.attributes[1].name, 'b');
      expect(e.attributes[1].value, 345);
      expect(e.attributes[2].name, 'c');
      expect(e.attributes[2].value, 'foo');
      expect(e.attributes[3].name, 'd');
      expect(e.attributes[3].value, 'bar');
      expect(e.from, null);
      expect(e.to, null);
    });
    test('activityMultipleActivities', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('activity(foo)activity(bar)');
      expect(expressions.value.length, 2);

      final a = expressions.value[0] as ActivityExpression;
      final b = expressions.value[1] as ActivityExpression;
      expect(a.identifier, 'foo');
      expect(b.identifier, 'bar');
    });
    test('activityWithFromToAndStringAttribute', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse(
          'activity(foo,1999-11-19T00:01:02,2020-11-20T03:04:05Z,[a="hello world"])');
      expect(expressions.value.length, 1);

      final e = expressions.value[0] as ActivityExpression;
      expect(e.identifier, 'foo');
      expect(e.attributes.length, 1);
      expect(e.attributes[0].name, 'a');
      expect(e.attributes[0].value, 'hello world');
      expect(e.from.toString(), startsWith('1999-11-19 00:01:02'));
    });
    test('activityWithFromToWithMarker', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('activity(foo,1999-11-19T00:01:02,-)');
      expect(expressions.value.length, 1);

      final e = expressions.value[0] as ActivityExpression;
      expect(e.identifier, 'foo');
      expect(e.from.toString(), startsWith('1999-11-19 00:01:02'));
    });
  });
}
