import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
entity(tr:WD-prov-dm-20111215, [ prov:type="document" ])
entity(tr:WD-prov-dm-20111215)
 */
void main() {
  group('entityGrammar', () {
    test('entityWithName', () {
      final parser = PROVNExpressionsParser;
      final entities = parser.parse('entity(foo)');
      expect(entities.value.length, 1);
      var e = entities.value[0] as EntityExpression;
      expect(e.identifier, 'foo');
      expect(e.attributes.length, 0);
    });
    test('entityWithEmptyAttributeList', () {
      final parser = PROVNExpressionsParser;
      final entities = parser.parse('entity(foo,[])');
      expect(entities.value.length, 1);
      var e = entities.value[0] as EntityExpression;
      expect(e.identifier, 'foo');
      expect(e.attributes.length, 0);
    });
    test('entityWithNumericAttribute', () {
      final parser = PROVNExpressionsParser;
      final entities = parser.parse('entity(foo,[a=123])');
      expect(entities.value.length, 1);
      var e = entities.value[0] as EntityExpression;
      expect(e.identifier, 'foo');
      expect(e.attributes.length, 1);
      var a = e.attributes[0] as NumericAttribute;
      expect(a.name, 'a');
      expect(a.value, 123);
    });
    test('entityWithStringAttribute', () {
      final parser = PROVNExpressionsParser;
      final entities = parser.parse('entity(foo,[a="hello world"])');
      expect(entities.value.length, 1);
      var e = entities.value[0] as EntityExpression;
      expect(e.identifier, 'foo');
      expect(e.attributes.length, 1);
      var a = e.attributes[0] as StringAttribute;
      expect(a.name, 'a');
      expect(a.value, 'hello world');
    });
    test('entityWithMultipleAttributes', () {
      final parser = PROVNExpressionsParser;
      final entities =
          parser.parse('entity(foo,[a=123,b=345,c="foo",d="bar"])');
      expect(entities.value.length, 1);
      var e = entities.value[0] as EntityExpression;
      expect(e.identifier, 'foo');
      expect(e.attributes.length, 4);
    });
    test('entityMultipleEntities', () {
      final parser = PROVNExpressionsParser;
      final entities = parser.parse('entity(foo)entity(bar)');
      expect(entities.value.length, 2);
      var a = entities.value[0] as EntityExpression;
      var b = entities.value[1] as EntityExpression;
      expect(a.identifier, 'foo');
      expect(b.identifier, 'bar');
    });
  });
}
