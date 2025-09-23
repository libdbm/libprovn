import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
alternateOf(tr:WD-prov-dm-20111215,ex:alternate-20111215)
 */
void main() {
  group('W3C Alternate Examples', () {
    test('alternateWithAllComponents', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser
          .parse('alternateOf(tr:WD-prov-dm-20111215,ex:alternate-20111215)');
      expect(expressions.value.length, 1);

      var e = expressions.value[0] as AlternateExpression;
      expect(e.alternate, 'tr:WD-prov-dm-20111215');
      expect(e.original, 'ex:alternate-20111215');
    });
  });
  group('alternateGrammar', () {
    test('alternateWithAllComponents', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('alternateOf(alternateId, originalId)');
      expect(expressions.value.length, 1);

      var e = expressions.value[0] as AlternateExpression;
      expect(e.alternate, 'alternateId');
      expect(e.original, 'originalId');
    });
  });
}
