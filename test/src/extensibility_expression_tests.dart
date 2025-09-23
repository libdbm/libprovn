import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
extensionOf(tr:WD-prov-dm-20111215,ex:extension-20111215)


[49]   	extensibilityExpression	   ::=   	QUALIFIED_NAME "(" optionalIdentifier extensibilityArgument ( "," extensibilityArgument )* optionalAttributeValuePairs ")"
[50]   	extensibilityArgument	   ::=   	( identifierOrMarker | literal | time | extensibilityExpression | extensibilityTuple )
[51]   	extensibilityTuple	   ::=   	"{" extensibilityArgument ( "," extensibilityArgument )* "}"
| "(" extensibilityArgument ( "," extensibilityArgument )* ")"
Expressions compatible with the extensibilityExpression production follow a general form of functional syntax, in which the predicate must be a qualifiedName with a non-empty prefix.

Example 46
Collections are sets of entities, whose membership can be expressed using the hadMember relation. The following example shows how one can express membership for dictionaries, an illustrative extension of Collections consisting of sets of key-entity pairs, where a key is a literal. The notation is a variation of that used for Collections membership, allowing multiple member elements to be declared, and in which the elements are pairs. The name of the relation is qualified with the extension-specific namespace http://example.org/dictionaries.

  prefix dictExt <http://example.org/dictionaries#>
  dictExt:hadMembers(mId; d, {("k1",e1), ("k2",e2), ("k3",e3)}, [])
Note that the generic extensibilityExpression production above allows for alternative notations to be used for expressing membership, if the designers of the extensions so desire. Here is an alternate syntax that is consistent with the productions:
  prefix dictExt <http://example.org/dictionaries#>
  dictExt:hadMembers(mid; d, dictExt:set(dictExt:pair("k1",e1),
                                         dictExt:pair("k2",e2),
                                         dictExt:pair("k3",e3)),
                            [dictExt:uniqueKeys="true"])
 */
void main() {
  group('extensionGrammar', () {
    test('extensionWithMissingOptionalId', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse('a:test(a,1234)');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as ExtensibilityExpression;
      print(e);
    });
    test('extensionWithAllComponents', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse(
          'dictExt:hadMembers(mId; d, {("k1",e1), ("k2",e2), ("k3",e3)}, [foo="123",bar=123])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as ExtensibilityExpression;
      print(e);
    });
    test('extensionWithAllAlternateTupleSyntax', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse(
          'dictExt:hadMembers(mId; d, (("k1",e1), ("k2",e2), ("k3",e3)), [foo="123",bar=123])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as ExtensibilityExpression;
      print(e);
    });
    test('alternativeExtensionWithAllComponents', () {
      final parser = PROVNExpressionsParser;
      final expressions = parser.parse(
          'dicExt:hadMembers(mId; d, e:set(e:pair("k1",e1),e:pair("k2",e2),e:pair("k3",e3)), [foo="123",bar=123,e:uniqueKeys="true"])');
      expect(expressions.value.length, 1);
      var e = expressions.value[0] as ExtensibilityExpression;
      print(e);
    });
  });
}
