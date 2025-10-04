// ignore_for_file: non_constant_identifier_names

import 'package:petitparser/petitparser.dart';

import '../../types.dart';
import 'grammar.dart';

final PROVNParserDefinition definition_ = PROVNParserDefinition();

/// Parser for PROV-N expression lists without document wrapper.
///
/// Use this when parsing standalone PROV-N expressions that are not
/// wrapped in a `document...endDocument` block.
///
/// Example:
/// ```dart
/// final result = PROVNExpressionsParser.parse('entity(ex:e1)');
/// ```
final Parser<List<Expression>> PROVNExpressionsParser =
    definition_.buildFrom(definition_.expressions()).end();

/// Parser for complete PROV-N documents.
///
/// Use this to parse full PROV-N documents including namespace declarations
/// and expressions wrapped in `document...endDocument`.
///
/// Example:
/// ```dart
/// final result = PROVNDocumentParser.parse('''
///   document
///     prefix ex <http://example.org/>
///     entity(ex:e1)
///   endDocument
/// ''');
/// ```
final Parser<DocumentExpression> PROVNDocumentParser =
    definition_.buildFrom(definition_.document()).end();

/// Parser definition for PROV-N notation.
///
/// This class extends the PROV-N grammar to build typed Dart objects
/// from parsed PROV-N text.
class PROVNParserDefinition extends PROVNGrammarDefinition {
  @override
  Parser<List<Expression>> expressions() => super.expressions().castList();

  @override
  Parser<List<Namespace>> namespaceDeclarations() =>
      super.namespaceDeclarations().map((each) {
        final namespaces = <Namespace>[];

        // First namespace (could be default or regular)
        if (each[0] is Namespace) {
          namespaces.add(each[0] as Namespace);
        }

        // Additional namespaces
        if (each[1] is List) {
          for (final ns in each[1]) {
            if (ns is Namespace) {
              namespaces.add(ns);
            }
          }
        }

        return namespaces;
      });

  @override
  Parser<Namespace> namespaceDeclaration() =>
      super.namespaceDeclaration().map((each) {
        // each[0] = 'prefix'
        // each[1] = prefix name (PN_PREFIX returns a list like [e, [x], null])
        // each[2] = namespace URI (IRI_REF now returns a string like "<http://...>")

        final prefixData = each[1];
        String prefix;
        if (prefixData is String) {
          prefix = prefixData;
        } else if (prefixData is List) {
          // PN_PREFIX returns [first_char, [rest_chars...], optional_part]
          // Flatten to string
          final first = prefixData[0];
          final rest = prefixData[1] ?? [];
          if (rest is List) {
            prefix = first.toString() + rest.join('');
          } else {
            prefix = first.toString() + rest.toString();
          }
        } else {
          prefix = prefixData.toString();
        }

        final uri = each[2] as String;
        // Remove angle brackets and trim whitespace from URI
        final trimmedUri = uri.trim();
        final cleanUri = trimmedUri.startsWith('<') && trimmedUri.endsWith('>')
            ? trimmedUri.substring(1, trimmedUri.length - 1)
            : trimmedUri;

        return Namespace(prefix.trim(), cleanUri);
      });

  @override
  Parser<Namespace> defaultNamespaceDeclaration() =>
      super.defaultNamespaceDeclaration().map((each) {
        // each[0] = 'default'
        // each[1] = namespace URI (IRI_REF now returns a string)
        final uri = each[1] as String;
        // Remove angle brackets and trim whitespace from URI
        final trimmedUri = uri.trim();
        final cleanUri = trimmedUri.startsWith('<') && trimmedUri.endsWith('>')
            ? trimmedUri.substring(1, trimmedUri.length - 1)
            : trimmedUri;
        return Namespace('default', cleanUri);
      });

  @override
  Parser<DocumentExpression> document() => super.document().map((each) {
        // each[0] = START_DOCUMENT
        // each[1] = optional identifier and attributes
        // each[2] = optional namespace declarations (List<Namespace>)
        // each[3] = expressions and bundles (star)
        // each[4] = END_DOCUMENT

        final namespaces = each[2] as List<Namespace>? ?? [];

        final expressions = <Expression>[];
        expressions.addAll((each[3] as List).cast<Expression>());

        return DocumentExpression(namespaces, expressions);
      });

  @override
  Parser<BundleExpression> standardBundle() =>
      super.standardBundle().map((each) {
        // each[0] = START_BUNDLE
        // each[1] = identifier
        // each[2] = optional namespace declarations
        // each[3] = expressions (star)
        // each[4] = END_BUNDLE

        final identifier = each[1] as String;
        final namespaces = each[2] as List<Namespace>? ?? [];
        final expressions = (each[3] as List).cast<Expression>();

        return BundleExpression(identifier, [], namespaces, expressions);
      });

  @override
  Parser<Expression> entityExpression() => super.entityExpression().map((each) {
        final String identifier = each[2];
        final List<Attribute> attributes = each[3] ?? [];
        return EntityExpression(identifier, attributes);
      });

  @override
  Parser<Expression> activityExpression() =>
      super.activityExpression().map((each) {
        final String identifier = each[2];
        final DateTime? from =
            each[3] != null && each[3].length > 0 ? each[3][0] : null;
        final DateTime? to =
            each[3] != null && each[3].length > 0 ? each[3][1] : null;
        final List<Attribute> attributes = each[4] ?? [];
        return ActivityExpression(identifier, attributes, from, to);
      });

  @override
  Parser<Expression> generationExpression() =>
      super.generationExpression().map((each) {
        final String? identifier = each[2];
        final String eIdentifier = each[3];
        final String? aIdentifier = each[4] != null ? each[4][1] : null;
        final DateTime? datetime = each[4] != null ? each[4][3] : null;
        final List<Attribute> attributes = each[5] ?? [];
        return GenerationExpression(
            identifier, eIdentifier, aIdentifier, datetime, attributes);
      });

  @override
  Parser<Expression> usageExpression() => super.usageExpression().map((each) {
        final String? identifier = each[2];
        final String aIdentifier = each[3];
        final String? eIdentifier = each[4] != null ? each[4][1] : null;
        final DateTime? datetime = each[4] != null ? each[4][3] : null;
        final List<Attribute> attributes = each[5] ?? [];
        return UsageExpression(
            identifier, eIdentifier, aIdentifier, datetime, attributes);
      });

  @override
  Parser<Expression> communicationExpression() =>
      super.communicationExpression().map((each) {
        final String? id = each[2];
        final String informed = each[3];
        final String informant = each[5];
        final List<Attribute> attributes = each[6] ?? [];
        return CommunicationExpression(
            id ?? '_:id', informed, informant, attributes);
      });

  @override
  Parser<Expression> startExpression() => super.startExpression().map((each) {
        final String? identifier = each[2];
        final String aIdentifier = each[3];
        final String? eIdentifier = each[4] != null ? each[4][1] : null;
        final String? sIdentifier = each[4] != null ? each[4][3] : null;
        final DateTime? datetime = each[4] != null ? each[4][5] : null;
        final List<Attribute> attributes = each[5] ?? [];
        return StartExpression(identifier, eIdentifier, aIdentifier,
            sIdentifier, datetime, attributes);
      });

  @override
  Parser<Expression> endExpression() => super.endExpression().map((each) {
        final String? identifier = each[2];
        final String aIdentifier = each[3];
        final String? eIdentifier = each[4] != null ? each[4][1] : null;
        final String? sIdentifier = each[4] != null ? each[4][3] : null;
        final DateTime? datetime = each[4] != null ? each[4][5] : null;
        final List<Attribute> attributes = each[5] ?? [];
        return EndExpression(identifier, eIdentifier, aIdentifier, sIdentifier,
            datetime, attributes);
      });

  @override
  Parser<Expression> invalidationExpression() =>
      super.invalidationExpression().map((each) {
        final String? identifier = each[2];
        final String eIdentifier = each[3];
        final String? aIdentifier = each[4] != null ? each[4][1] : null;
        final DateTime? datetime = each[4] != null ? each[4][3] : null;
        final List<Attribute> attributes = each[5] ?? [];
        return InvalidationExpression(
            identifier, eIdentifier, aIdentifier, datetime, attributes);
      });

  @override
  Parser<Expression> derivationExpression() =>
      super.derivationExpression().map((each) {
        final String? id = each[2];
        final String generated = each[3];
        final String used = each[5];
        final String? activity = each[6] != null ? each[6][1] : null;
        final String? generation = each[6] != null ? each[6][3] : null;
        final String? usage = each[6] != null ? each[6][5] : null;
        final List<Attribute> attributes = each[7] ?? [];
        return DerivationExpression(
            id, generated, used, activity, generation, usage, attributes);
      });

  @override
  Parser<Expression> agentExpression() => super.agentExpression().map((each) {
        final String identifier = each[2];
        final List<Attribute> attributes = each[3] ?? [];
        return AgentExpression(identifier, attributes);
      });

  @override
  Parser<Expression> attributionExpression() =>
      super.attributionExpression().map((each) {
        final String? id = each[2];
        final String entity = each[3];
        final String agent = each[5];
        final List<Attribute> attributes = each[6] ?? [];
        return AttributionExpression(id, entity, agent, attributes);
      });

  @override
  Parser<Expression> associationExpression() =>
      super.associationExpression().map((each) {
        final String? id = each[2];
        final String entity = each[3];
        final String? agent = each[4] != null ? each[4][1] : null;
        final String? plan = each[4] != null ? each[4][3] : null;
        final List<Attribute> attributes = each[5] ?? [];
        return AssociationExpression(id, entity, agent, plan, attributes);
      });

  @override
  Parser<Expression> delegationExpression() =>
      super.delegationExpression().map((each) {
        final String? id = each[2];
        final String delegate = each[3];
        final String agent = each[5];
        final String? activity = each[6] != null ? each[6][1] : null;
        final List<Attribute> attributes = each[7] ?? [];
        return DelegationExpression(
            id ?? '_:id', delegate, agent, activity ?? '', attributes);
      });

  @override
  Parser<Expression> influenceExpression() =>
      super.influenceExpression().map((each) {
        final String? id = each[2];
        final String influencee = each[3];
        final String influencer = each[5];
        final List<Attribute> attributes = each[6] ?? [];
        return InfluenceExpression(
            id ?? '_:id', influencee, influencer, attributes);
      });

  @override
  Parser<Expression> alternateExpression() =>
      super.alternateExpression().map((each) {
        final String alternate = each[2];
        final String original = each[4];
        return AlternateExpression(alternate, original);
      });

  @override
  Parser<Expression> specializationExpression() =>
      super.specializationExpression().map((each) {
        final String alternate = each[2];
        final String original = each[4];
        return SpecializationExpression(alternate, original);
      });

  @override
  Parser<Expression> membershipExpression() =>
      super.membershipExpression().map((each) {
        final String collection = each[2];
        final String entity = each[4];
        return MembershipExpression(collection, entity);
      });

  @override
  Parser<Expression> mentionOfExpression() =>
      super.mentionOfExpression().map((each) {
        final String specific = each[2];
        final String general = each[4];
        final String bundle = each[6];
        return MentionOfExpression(specific, general, bundle);
      });

  @override
  Parser<Expression> extensibilityExpression() =>
      super.extensibilityExpression().map((each) {
        final String name = each[0];
        final String? id = each[2];
        final SeparatedList<dynamic, dynamic> arguments = each[3];
        final List<Attribute> attributes = each[4] ?? [];
        return ExtensibilityExpression(
            id, name, arguments.elements, attributes);
      });

  @override
  Parser<String?> optionalIdentifier() =>
      super.optionalIdentifier().map((each) {
        return each != null ? each[0] : null;
      });

  @override
  Parser<String?> identifierOrMarker() =>
      super.identifierOrMarker().map((each) {
        if (each != null && each != '_' && each != '-') {
          return each;
        }
        return null;
      });

  @override
  Parser<DateTime?> timeOrMarker() => super.timeOrMarker().map((each) {
        if (each != null && each != '_' && each != '-') {
          return DateTime.parse(each);
        }
        return null;
      });

  @override
  Parser<List<DateTime?>> optionalToFrom() =>
      super.optionalToFrom().map((each) {
        return each != null ? [each[1], each[3]] : [];
      });

  @override
  Parser<List<Attribute>> attributeValuePairs() =>
      super.attributeValuePairs().map((each) {
        final List<Attribute> attributes = [];
        if (each != null) {
          for (var a in each.elements) {
            attributes.add(a);
          }
        }
        return attributes;
      });

  @override
  Parser<List<Attribute>> optionalAttributeValuePairs() =>
      super.optionalAttributeValuePairs().map((each) {
        final List<Attribute<dynamic>> attributes =
            each != null ? each[2] ?? [] : [];
        return attributes;
      });

  @override
  Parser<Attribute> attributeValuePair() =>
      super.attributeValuePair().map((each) {
        final String name = each[0];
        final Object value = each[2];
        if (value is String) {
          return StringAttribute(name, value.toString());
        } else if (value is num) {
          return NumericAttribute(name, value);
        } else if (value is List) {
          // Typed literal: [string, "%%", datatype]
          // For now, just use the string part and ignore the datatype
          return StringAttribute(name, value[0].toString());
        }
        return NumericAttribute(name, value as num);
      });

  @override
  Parser qualifiedNameLiteral() =>
      super.qualifiedNameLiteral().map((each) => each[1]);

  @override
  Parser stringLiteral() =>
      super.stringLiteral().map((each) => each.substring(1, each.length - 1));

  @override
  Parser numberLiteral() => super.numberLiteral().map((each) {
        final floating = double.parse(each);
        final integral = floating.toInt();
        if (floating == integral && each.indexOf('.') == -1) {
          return integral;
        } else {
          return floating;
        }
      });
}
