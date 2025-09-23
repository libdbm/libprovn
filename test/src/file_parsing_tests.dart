import 'dart:io';
import 'package:test/test.dart';
import 'package:petitparser/petitparser.dart';
import 'package:libprovn/libprovn.dart';

void main() {
  group('Parse git2prov', () {
    test('parse file', () {
      // final parser = trace(PROVNDocumentParser);
      final parser = PROVNDocumentParser;
      final file = File('test/data/lsp.provn');
      final result = parser.parse(file.readAsStringSync());
      if (result is Failure) {
        print('==>${result.message} ${result.position}');
      }
      print(result);
    });
  });
}
