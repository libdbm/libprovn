import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
hadMember(tr:WD-prov-dm-20111215,ex:member-20111215)
 */
void main() {
  group('membershipGrammar', () {
    test('membershipWithAllComponents', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('hadMember(collection, entity)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as MembershipExpression;
      print(e);
      expect(e.collection, 'collection');
      expect(e.entity, 'entity');
    });
  });
}
