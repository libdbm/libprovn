import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
wasInfluencedBy(ex:infl1;e2,e1,[ex:param="a"])
wasInfluencedBy(ex:e2,ex:e1)
wasInfluencedBy(ex:e2,ex:e1,[ex:param="a"])
wasInfluencedBy(ex:infl1; ex:e2,ex:e1)
 */
void main() {
  group('influenceGrammar', () {
    test('influenceWithAllComponents', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse(
          'wasInfluencedBy(ex:optionalId;influencee,influencer,[ex:param="a"])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as InfluenceExpression;
      print(e);
      expect(e.id, 'ex:optionalId');
      expect(e.influencee, 'influencee');
      expect(e.influencer, 'influencer');
      expect(e.attributes.length, 1);
    });
  });
}
