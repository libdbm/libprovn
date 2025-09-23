import 'package:libprovn/libprovn.dart';
import 'package:test/test.dart';

/*
	document	   ::=   	"document" (namespaceDeclarations)? (expression)* (bundle)* "endDocument"
 */
void main() {
  group('documentGrammar', () {
    test('empty document', () {
      final text = '''
document
endDocument
''';
      final parser = PROVNDocumentParser;
      final result = parser.parse(text);
      print(result);
    });
    test('extended document syntax', () {
      final text = '''
document(foo:test, [foo="bar"])
endDocument
''';
      final parser = PROVNDocumentParser;
      final result = parser.parse(text);
      print(result);
    });
    test('alternate startDocument', () {
      final text = '''
startDocument(foo:test, [foo="bar"])
endDocument
''';
      final parser = PROVNDocumentParser;
      final result = parser.parse(text);
      print(result);
    });
    test('document with default namespace declaration', () {
      final text = '''
document
default <http://localhost/#>
endDocument
''';
      final parser = PROVNDocumentParser;
      final result = parser.parse(text);
      print(result);
    });
    test('document with multiple namespace declarations', () {
      final text = '''
document
default <http://localhost/#>
prefix result <&serialization=foo#>
endDocument
''';
      final parser = PROVNDocumentParser;
      final result = parser.parse(text);
      print(result);
    });
    test('document with expressions', () {
      final text = '''
document 
entity(X, [status="Secret"])
entity(Y, [status="Secret"])
endDocument
''';
      final parser = PROVNDocumentParser;
      final result = parser.parse(text);
      print(result);
    });
    test('document with empty bundle', () {
      final text = '''
document 
bundle foo:bar
endBundle
endDocument
''';
      final parser = PROVNDocumentParser;
      final result = parser.parse(text);
      print(result);
    });
    test('extended bundle syntax with attributes', () {
      final text = '''
document 
startBundle(bar, [foo="bar"])
endBundle(bar)
endDocument
''';
      final parser = PROVNDocumentParser;
      final result = parser.parse(text);
      print(result);
    });
    test('extended bundle syntax without attributes', () {
      final text = '''
document 
startBundle(bar)
endBundle(bar)
endDocument
''';
      final parser = PROVNDocumentParser;
      final result = parser.parse(text);
      print(result);
    });
    test('document with bundle containing expressions', () {
      final text = '''
document 
bundle foo:bar
entity(X, [status="Secret"])
entity(Y, [status="Secret"])
endBundle
endDocument
''';
      final parser = PROVNDocumentParser;
      final result = parser.parse(text);
      print(result);
    });
    test('document with mixed bundle and expressions', () {
      final text = '''
document
entity(X, [status="Secret"])
entity(Y, [status="Secret"]) 
bundle foo:bar
entity(X, [status="Secret"])
entity(Y, [status="Secret"])
endBundle
endDocument
''';
      final parser = PROVNDocumentParser;
      final result = parser.parse(text);
      print(result);
    });
    test('document with all parts', () {
      final text = '''
document
default <http://localhost/#>
prefix result <&serialization=foo#>
entity(X, [status="Secret"])
entity(Y, [status="Secret"]) 
bundle foo:bar
entity(X, [status="Secret"])
entity(Y, [status="Secret"])
endBundle
bundle bar:baz
default <http://localhost/#>
prefix result <&serialization=foo#>
entity(result:file__vscode, [prov:label=".vscode/spellright.dict"])
entity(result:file--vscode, [prov:label=".vscode/spellright.dict"])
endBundle
endDocument
''';
      final parser = PROVNDocumentParser;
      final result = parser.parse(text);
      print(result);
    });
    test('marker and timestamp', () {
      final text = '''
document
prefix result <http://localhost/#>
prefix fullResult <&serialization=PROV-N#>
bundle result:provenance
entity(result:file--vscode-spellright-dict, [prov:label=".vscode/spellright.dict"])
entity(result:file-indexFormat-versions-specification-0-3-x-md, [prov:label="indexFormat/versions/specification-0-3-x.md"])
entity(result:file-versions-protocol-2-0-md_commit-8accb68fde1222a314f6a845ffff6bb5bee28cc2)
entity(result:file-protocol-md_commit-e8db47b2e8dd1abd7ce99dae44afadaa55033b89)
agent(result:user-KamasamaK, [prov:label="KamasamaK"])
agent(result:user-Dirk-Bäumer, [prov:label="Dirk Bäumer"])
agent(result:user-Dirk-Baeumer, [prov:label="Dirk Baeumer"])
activity(result:commit-b9c53dd87a2fbd0857f21841441dd5f4a0f1987b, [prov:label="Fixed "dead" links in README"])
wasStartedBy(result:commit-ab6bdf5fcdaeb3da91dd5dee557a4dda17e2a5d2, -, -, 2019-07-12T01:48:36.000Z)
wasEndedBy(result:commit-eb8f6db5c2a05f8791c9f6553842e73261bc966b, -, -, 2020-01-20T11:06:51.000Z)
wasAttributedTo(result:file-README-md_commit-eb8f6db5c2a05f8791c9f6553842e73261bc966b, result:user-KamasamaK, [prov:type="authorship"])
wasAssociatedWith(result:commit-eb8f6db5c2a05f8791c9f6553842e73261bc966b, result:user-KamasamaK, [prov:role="author, committer"])
wasInformedBy(result:commit-eb8f6db5c2a05f8791c9f6553842e73261bc966b, result:commit-b2385ea14ceeb0b6a4e0308f3a82297cd795bd0c)
specializationOf(result:file-README-md_commit-eb8f6db5c2a05f8791c9f6553842e73261bc966b, result:file-README-md)
wasGeneratedBy(result:file-README-md_commit-eb8f6db5c2a05f8791c9f6553842e73261bc966b, result:commit-eb8f6db5c2a05f8791c9f6553842e73261bc966b, 2020-01-20T11:06:51.000Z)
used(result:commit-eb8f6db5c2a05f8791c9f6553842e73261bc966b, result:file-README-md_commit-b2385ea14ceeb0b6a4e0308f3a82297cd795bd0c, 2020-01-20T11:06:51.000Z)
wasDerivedFrom(result:file-README-md_commit-eb8f6db5c2a05f8791c9f6553842e73261bc966b, result:file-README-md_commit-b2385ea14ceeb0b6a4e0308f3a82297cd795bd0c, result:commit-eb8f6db5c2a05f8791c9f6553842e73261bc966b, result:file-README-md_commit-eb8f6db5c2a05f8791c9f6553842e73261bc966b_gen, result:file-README-md_commit-b2385ea14ceeb0b6a4e0308f3a82297cd795bd0c_commit-eb8f6db5c2a05f8791c9f6553842e73261bc966b_use)
wasInvalidatedBy(result:file-versions-protocol-2-0-md_commit-1da827644cbc15f6832942db39f9ff6a1a16c3ad, result:commit-1da827644cbc15f6832942db39f9ff6a1a16c3ad, 2016-04-13T11:26:55.000Z)
endBundle 
endDocument
''';
      final parser = PROVNDocumentParser;
      final result = parser.parse(text);
      print(result);
    });
  });
}
