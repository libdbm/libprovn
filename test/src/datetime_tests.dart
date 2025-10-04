import 'package:libprovn/src/io/provn/datetime.dart';
import 'package:test/test.dart';

void main() {
  group('dateTimeGrammar', () {
    test('date/time with Z', () {
      final time = '2007-03-01T13:00:00Z';
      final parser = dateTimeFromFormat('yyyy-MM-ddThh:mm:ssZ');
      final result = parser.parse(time);
      final datetime = DateTime.parse(time);
      expect(result.value.toIso8601String(), datetime.toIso8601String());
    });
    test('date/time with TZD', () {
      final time = '2007-03-01T13:00:00Z';
      final parser = dateTimeFromFormat('yyyy-MM-ddThh:mm:ssTZD');
      final result = parser.parse(time);
      final datetime = DateTime.parse(time);
      expect(result.value.toIso8601String(), datetime.toIso8601String());
    });
    test('date/time with offset', () {
      final time = '2008-08-30T01:45:36.123+08:00';
      final parser = dateTimeFromFormat('yyyy-MM-ddThh:mm:ss.SSSTZD');
      final result = parser.parse(time);
      final datetime = DateTime.parse(time);
      expect(result.value.toIso8601String(), datetime.toIso8601String());
    });
  });
}
