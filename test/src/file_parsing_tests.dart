import 'dart:io';

import 'package:libprovn/libprovn.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('Parse all PROVN files in test/data', () {
    final dir = Directory('test/data');
    final files = dir
        .listSync(recursive: false)
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.provn'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    for (final file in files) {
      final name = file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : file.path;

      test('parse $name', () {
        final content = file.readAsStringSync();

        if (name == 'atlas.provn') {
          final result = PROVNDocumentParser.parse(content);
          expect(result, isA<Failure>(),
              reason: 'atlas.provn is known to be malformed and should fail');
          return;
        }

        Result<dynamic> result = PROVNDocumentParser.parse(content);

        if (result is Failure) {
          result = PROVNExpressionsParser.parse(content);
        }

        if (result is Failure) {
          fail(
              'Failed to parse $name: ${result.message} at position ${result.toPositionString()}');
        }
        // Basic sanity check on parsed value
        expect(result.value, isNotNull,
            reason: 'Parsed value should not be null for $name');
      });
    }
  });
}
