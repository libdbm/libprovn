import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
specializationOf(tr:WD-prov-dm-20111215,ex:specialization-20111215)
 */
void main() {
  group('specializationGrammar', () {
    test('specializationWithAllComponents', () {
      final parser = PROVNExpressionsParser;
      final expressions =
          parser.parse('specializationOf(specializationId, originalId)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as SpecializationExpression;
      print(e);
      expect(e.alternate, 'specializationId');
      expect(e.original, 'originalId');
    });
  });
}
