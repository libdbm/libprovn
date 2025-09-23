import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
agent(tr:WD-prov-dm-20111215, [ prov:type="document" ])
agent(tr:WD-prov-dm-20111215)
 */
void main() {
  group('W3C Agent Examples', () {
    test('agent(tr:WD-prov-dm-20111215, [ prov:type="document" ])', () {
      final parser = PROVNExpressionsParser;
      final entities = parser
          .parse('agent(tr:WD-prov-dm-20111215, [ prov:type="document" ])');
      expect(entities.value.length, 1);

      final e = entities.value[0] as AgentExpression;
      expect(e.identifier, 'tr:WD-prov-dm-20111215');
      expect(e.attributes.length, 1);
      expect(e.attributes[0].name, 'prov:type');
      expect(e.attributes[0].value, 'document');
    });
    test('agent(tr:WD-prov-dm-20111215)', () {
      final parser = PROVNExpressionsParser;
      final entities = parser.parse('agent(tr:WD-prov-dm-20111215)');
      expect(entities.value.length, 1);

      final e = entities.value[0] as AgentExpression;
      expect(e.identifier, 'tr:WD-prov-dm-20111215');
      expect(e.attributes.length, 0);
    });
  });
  group('agentGrammar', () {
    test('agentWithName', () {
      final parser = PROVNExpressionsParser;
      final entities = parser.parse('agent(foo)');
      expect(entities.value.length, 1);

      final e = entities.value[0] as AgentExpression;
      expect(e.identifier, 'foo');
      expect(e.attributes.length, 0);
    });
    test('agentWithEmptyAttributeList', () {
      final parser = PROVNExpressionsParser;
      final entities = parser.parse('agent(foo,[])');
      expect(entities.value.length, 1);

      final e = entities.value[0] as AgentExpression;
      expect(e.identifier, 'foo');
      expect(e.attributes.length, 0);
    });
    test('agentWithNumericAttribute', () {
      final parser = PROVNExpressionsParser;
      final entities = parser.parse('agent(foo,[a=123])');
      expect(entities.value.length, 1);

      final e = entities.value[0] as AgentExpression;
      expect(e.identifier, 'foo');
      expect(e.attributes.length, 1);
      expect(e.attributes[0].name, 'a');
      expect(e.attributes[0].value, 123);
    });
    test('agentWithStringAttribute', () {
      final parser = PROVNExpressionsParser;
      final entities = parser.parse('agent(foo,[a="hello world"])');
      expect(entities.value.length, 1);

      final e = entities.value[0] as AgentExpression;
      expect(e.identifier, 'foo');
      expect(e.attributes.length, 1);
      expect(e.attributes[0].name, 'a');
      expect(e.attributes[0].value, 'hello world');
    });
    test('agentWithMultipleAttributes', () {
      final parser = PROVNExpressionsParser;
      final entities = parser.parse('agent(foo,[a=123,b=345,c="foo",d="bar"])');
      expect(entities.value.length, 1);

      final e = entities.value[0] as AgentExpression;
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
    });
    test('agentMultipleEntities', () {
      final parser = PROVNExpressionsParser;
      final entities = parser.parse('agent(foo)agent(bar)');
      expect(entities.value.length, 2);

      final a = entities.value[0] as AgentExpression;
      final b = entities.value[1] as AgentExpression;
      expect(a.identifier, 'foo');
      expect(b.identifier, 'bar');
    });
  });
}
