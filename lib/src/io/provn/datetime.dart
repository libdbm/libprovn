import 'package:petitparser/petitparser.dart';

/*
From XMLSCHEMA
-?([1-9][0-9]{3,}|0[0-9]{3})
-(0[1-9]|1[0-2])
-(0[1-9]|[12][0-9]|3[01])
T(([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](\.[0-9]+)?|(24:00:00(\.0+)?))
(Z|(\+|-)((0[0-9]|1[0-3]):[0-5][0-9]|14:00))?
 */
enum _DateTimeField {
  month,
  day,
  year,
  literal,
  hour,
  minute,
  second,
  millisecond
}

Parser<DateTime> dateTimeFromFormat(String format) {
  final day = 'dd'.toParser().map((token) => digit()
      .repeat(2)
      .flatten()
      .map((value) => MapEntry(_DateTimeField.day, int.parse(value))));

  final month = 'MM'.toParser().map((token) => digit()
      .repeat(2)
      .flatten()
      .map((value) => MapEntry(_DateTimeField.month, int.parse(value))));

  final year = 'yyyy'.toParser().map((token) => digit()
      .repeat(4)
      .flatten()
      .map((value) => MapEntry(_DateTimeField.year, int.parse(value))));

  final hour = 'hh'.toParser().map((token) => digit()
      .repeat(2)
      .flatten()
      .map((value) => MapEntry(_DateTimeField.hour, int.parse(value))));

  final minute = 'mm'.toParser().map((token) => digit()
      .repeat(2)
      .flatten()
      .map((value) => MapEntry(_DateTimeField.minute, int.parse(value))));

  final second = 'ss'.toParser().map((token) => digit()
      .repeat(2)
      .flatten()
      .map((value) => MapEntry(_DateTimeField.second, int.parse(value))));

  final millisecond = 'SSS'.toParser().map((token) => digit()
      .repeat(3)
      .flatten()
      .map((value) => MapEntry(_DateTimeField.millisecond, int.parse(value))));

  final spacing = whitespace().map((token) => whitespace()
      .star()
      .map((value) => const MapEntry(_DateTimeField.literal, 0)));

  final verbatim = any().map((token) => token
      .toParser()
      .map((value) => const MapEntry(_DateTimeField.literal, 0)));

  final entries = [
    day,
    month,
    year,
    hour,
    minute,
    second,
    millisecond,
    spacing,
    verbatim
  ].toChoiceParser().cast<Parser<MapEntry<_DateTimeField, int>>>();

  final dtParser = entries.star().end().map((parsers) {
    return parsers
        .toSequenceParser()
        .castList<MapEntry<_DateTimeField, int>>()
        .map((entries) {
      final arguments = Map.fromEntries(entries);
      return DateTime(
          arguments[_DateTimeField.year] ?? DateTime.now().year,
          arguments[_DateTimeField.month] ?? DateTime.january,
          arguments[_DateTimeField.day] ?? 1,
          arguments[_DateTimeField.hour] ?? 0,
          arguments[_DateTimeField.minute] ?? 0,
          arguments[_DateTimeField.second] ?? 0,
          arguments[_DateTimeField.millisecond] ?? 0,
          0);
    });
  });

  return dtParser.parse(format).value;
}
