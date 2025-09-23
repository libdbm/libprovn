import 'package:libprovn/src/io/provn/datetime.dart';
import 'package:test/test.dart';

void main() {
  group('dateTimeGrammar', () {
    test('dateTime', () {
      final parser = dateTimeFromFormat('yyyy-MM-ddThh:mm:ssZ');
      final result = parser.parse('2007-03-01T13:00:00Z');
      expect(result.value.toString(), '2007-03-01 13:00:00.000');
    });
  });
}
