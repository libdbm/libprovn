import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
wasDerivedFrom(ex:d; e2, e1, a, g2, u1, [ex:comment="a righteous derivation"])
wasDerivedFrom(e2, e1)
wasDerivedFrom(e2, e1, a, g2, u1)
wasDerivedFrom(e2, e1, -, g2, u1)
wasDerivedFrom(e2, e1, a, -, u1)
wasDerivedFrom(e2, e1, a, g2, -)
wasDerivedFrom(e2, e1, a, -, -)
wasDerivedFrom(e2, e1, -, -, u1)
wasDerivedFrom(e2, e1, -, -, -)
wasDerivedFrom(ex:d; e2, e1, a, g2, u1)
wasDerivedFrom(-; e2, e1, a, g2, u1)

Revision
wasDerivedFrom(ex:d; e2, e1, a, g2, u1,
               [prov:type='prov:Revision',
                ex:comment="a righteous derivation"])

Quotation
wasDerivedFrom(ex:quoteId1; ex:blockQuote,ex:blog, ex:act1, ex:g, ex:u,
               [ prov:type='prov:Quotation' ])

Primary source
wasDerivedFrom(ex:sourceId1;  ex:e1, ex:e2, ex:act, ex:g, ex:u,
               [ prov:type='prov:PrimarySource' ])
 */
void main() {
  group('derivationGrammar', () {
    test('derivationWithMinimalComponents', () {
      final parser = PROVNExpressionsParser;
      final expressions =
          parser.parse('wasDerivedFrom(generatedEntity, usedEntity)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as DerivationExpression;
      expect(e.generatedEntityId, 'generatedEntity');
      expect(e.usedEntityId, 'usedEntity');
      expect(e.attributes.length, 0);
    });
    test('derivationWithAllComponents', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse(
          'wasDerivedFrom(id; generatedEntity, usedEntity, activity, generation, usage, [ex:comment="a righteous derivation"])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as DerivationExpression;
      expect(e.id, 'id');
      expect(e.generatedEntityId, 'generatedEntity');
      expect(e.usedEntityId, 'usedEntity');
      expect(e.activityId, 'activity');
      expect(e.generationId, 'generation');
      expect(e.usageId, 'usage');
      expect(e.attributes.length, 1);
    });
  });
}
