import 'dart:io';
import 'package:libprovn/libprovn.dart';
import 'package:petitparser/petitparser.dart';

enum Format { provn, json, auto }

void main(List<String> args) async {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    printUsage();
    exit(0);
  }

  String? input;
  String? output;
  Format inputFormat = Format.auto;
  Format outputFormat = Format.auto;

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    switch (arg) {
      case '--from':
      case '-f':
        if (i + 1 < args.length) {
          final format = args[++i].toLowerCase();
          inputFormat = _parseFormat(format);
          if (inputFormat == Format.auto) {
            print('Error: Invalid input format: $format');
            printUsage();
            exit(1);
          }
        }
        break;
      case '--to':
      case '-t':
        if (i + 1 < args.length) {
          final format = args[++i].toLowerCase();
          outputFormat = _parseFormat(format);
          if (outputFormat == Format.auto) {
            print('Error: Invalid output format: $format');
            printUsage();
            exit(1);
          }
        }
        break;
      case '--output':
      case '-o':
        if (i + 1 < args.length) {
          output = args[++i];
        }
        break;
      default:
        if (!arg.startsWith('-')) {
          input = arg;
        } else {
          print('Error: Unknown option: $arg');
          printUsage();
          exit(1);
        }
    }
  }

  if (input == null) {
    print('Error: No input file specified');
    printUsage();
    exit(1);
  }

  final inputFile = File(input);
  if (!await inputFile.exists()) {
    print('Error: Input file not found: $input');
    exit(1);
  }

  final content = await inputFile.readAsString();

  if (inputFormat == Format.auto) {
    inputFormat = _detectFormat(input, content);
  }

  if (outputFormat == Format.auto) {
    if (output != null) {
      outputFormat = _detectFormatByExtension(output);
    } else {
      outputFormat = inputFormat == Format.provn ? Format.json : Format.provn;
    }
  }

  DocumentExpression document;

  try {
    if (inputFormat == Format.provn) {
      final result = PROVNDocumentParser.parse(content);
      if (result is Failure) {
        print('Error parsing PROV-N: ${result.message}');
        print('Position: ${result.position}');
        exit(1);
      }
      document = result.value;
    } else {
      final reader = PROVJSONReader();
      document = reader.readDocument(content);
    }
  } catch (e) {
    print(
        'Error parsing ${inputFormat == Format.provn ? "PROV-N" : "PROV-JSON"}: $e');
    exit(1);
  }

  String converted;
  if (outputFormat == Format.provn) {
    final writer = PROVNWriter();
    converted = writer.writeDocument(document);
  } else {
    final writer = PROVJSONWriter();
    converted = writer.writeDocument(document);
  }

  if (output != null) {
    final outputFile = File(output);
    await outputFile.writeAsString(converted);
    print(
        'Successfully converted ${inputFormat.name.toUpperCase()} to ${outputFormat.name.toUpperCase()}');
    print('Output written to: $output');
  } else {
    print(converted);
  }
}

Format _parseFormat(String format) {
  switch (format.toLowerCase()) {
    case 'provn':
    case 'prov-n':
      return Format.provn;
    case 'json':
    case 'provjson':
    case 'prov-json':
      return Format.json;
    default:
      return Format.auto;
  }
}

Format _detectFormat(String filename, String content) {
  final extension = filename.split('.').last.toLowerCase();
  switch (extension) {
    case 'provn':
      return Format.provn;
    case 'json':
    case 'provjson':
      return Format.json;
    default:
      break;
  }

  content = content.trim();
  if (content.startsWith('{') || content.startsWith('[')) {
    return Format.json;
  }

  if (content.startsWith('document') ||
      content.startsWith('prefix') ||
      content.startsWith('default') ||
      content.contains('entity(') ||
      content.contains('activity(') ||
      content.contains('agent(')) {
    return Format.provn;
  }

  return Format.provn;
}

Format _detectFormatByExtension(String filename) {
  final extension = filename.split('.').last.toLowerCase();
  switch (extension) {
    case 'provn':
      return Format.provn;
    case 'json':
    case 'provjson':
      return Format.json;
    default:
      return Format.auto;
  }
}

void printUsage() {
  print('''
PROV-N / PROV-JSON Conversion Tool

Usage: dart provn.dart [options] <input-file>

Options:
  -f, --from <format>    Input format: provn, prov-n, json, prov-json
                         (auto-detected if not specified)

  -t, --to <format>      Output format: provn, prov-n, json, prov-json
                         (defaults to opposite of input format)

  -o, --output <file>    Output file (prints to stdout if not specified)

  -h, --help             Show this help message

Examples:
  # Convert PROV-N to PROV-JSON
  dart provn.dart document.provn -o document.json

  # Convert PROV-JSON to PROV-N
  dart provn.dart document.json -o document.provn

  # Explicit formats
  dart provn.dart -f provn -t json input.txt -o output.json

  # Print to stdout
  dart provn.dart document.provn
''');
}
