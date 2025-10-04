// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'package:petitparser/petitparser.dart';

import 'datetime.dart';

class PROVNGrammarDefinition extends GrammarDefinition {
  @override
  Parser start() => ref0(document);

  /*
  document	   ::=   	"document" ("(" identifier optionalAttributeValuePairs ")")? (namespaceDeclarations)? (expression)* (bundle)* "endDocument"
  // extension
   */
  Parser document() =>
      ref0(START_DOCUMENT) &
      ref0(optionalIdentifierAndAttributes) &
      ref0(namespaceDeclarations).optional() &
      (ref0(expression) | ref0(bundle)).star() &
      ref0(END_DOCUMENT);

  Parser expressions() => ref0(expression).star();

  /*
[2]   	expression	   ::=   	( entityExpression | activityExpression | generationExpression | usageExpression | startExpression | endExpression | invalidationExpression | communicationExpression | agentExpression | associationExpression | attributionExpression | delegationExpression | derivationExpression | influenceExpression | alternateExpression | specializationExpression | membershipExpression | extensibilityExpression )
  */
  Parser expression() =>
      ref0(entityExpression) |
      ref0(activityExpression) |
      ref0(generationExpression) |
      ref0(usageExpression) |
      ref0(communicationExpression) |
      ref0(startExpression) |
      ref0(endExpression) |
      ref0(invalidationExpression) |
      ref0(derivationExpression) |
      ref0(agentExpression) |
      ref0(attributionExpression) |
      ref0(associationExpression) |
      ref0(delegationExpression) |
      ref0(influenceExpression) |
      ref0(alternateExpression) |
      ref0(specializationExpression) |
      ref0(membershipExpression) |
      ref0(mentionOfExpression) |
      ref0(extensibilityExpression);

  /*
[3]   	entityExpression	   ::=   	"entity" "(" identifier optionalAttributeValuePairs ")"
   */
  Parser entityExpression() =>
      ref0(ENTITY) &
      ref0(OPEN_PAREN) &
      ref0(identifier) &
      ref0(optionalAttributeValuePairs) &
      ref0(CLOSE_PAREN);

  /*
[7]   	activityExpression	   ::=   	"activity" "(" identifier ( "," timeOrMarker "," timeOrMarker )? optionalAttributeValuePairs ")"
   */
  Parser activityExpression() =>
      ref0(ACTIVITY) &
      ref0(OPEN_PAREN) &
      ref0(identifier) &
      ref0(optionalToFrom) &
      ref0(optionalAttributeValuePairs) &
      ref0(CLOSE_PAREN);

  /*
[9]   	generationExpression	   ::=   	"wasGeneratedBy" "(" optionalIdentifier eIdentifier ( "," aIdentifierOrMarker "," timeOrMarker )? optionalAttributeValuePairs ")"
   */
  Parser generationExpression() =>
      ref0(WAS_GENERATED_BY) &
      ref0(OPEN_PAREN) &
      ref0(optionalIdentifier) &
      ref0(identifier) &
      (ref0(COMMA) &
              ref0(identifierOrMarker) &
              ref0(COMMA) &
              ref0(timeOrMarker))
          .optional() &
      ref0(optionalAttributeValuePairs) &
      ref0(CLOSE_PAREN);

  /*
[12]   	usageExpression	   ::=   	"used" "(" optionalIdentifier aIdentifier ( "," eIdentifierOrMarker "," timeOrMarker )? optionalAttributeValuePairs ")"
   */
  Parser usageExpression() =>
      ref0(USED) &
      ref0(OPEN_PAREN) &
      ref0(optionalIdentifier) &
      ref0(identifier) &
      (ref0(COMMA) &
              ref0(identifierOrMarker) &
              ref0(COMMA) &
              ref0(timeOrMarker))
          .optional() &
      ref0(optionalAttributeValuePairs) &
      ref0(CLOSE_PAREN);

  /*
[13]   	communicationExpression	   ::=   	"wasInformedBy" "(" optionalIdentifier aIdentifier "," aIdentifier optionalAttributeValuePairs ")"

Communication	Non-Terminal
id	optionalIdentifier
informed	aIdentifier
informant	aIdentifier
attributes	optionalAttributeValuePairs

   */
  Parser communicationExpression() =>
      ref0(WAS_INFORMED_BY) &
      ref0(OPEN_PAREN) &
      ref0(optionalIdentifier) &
      ref0(identifier) &
      ref0(COMMA) &
      ref0(identifier) &
      ref0(optionalAttributeValuePairs) &
      ref0(CLOSE_PAREN);

  /*
[14]   	startExpression	   ::=   	"wasStartedBy" "(" optionalIdentifier aIdentifier ( "," eIdentifierOrMarker "," aIdentifierOrMarker "," timeOrMarker )? optionalAttributeValuePairs ")"
   */
  Parser startExpression() =>
      ref0(WAS_STARTED_BY) &
      ref0(OPEN_PAREN) &
      ref0(optionalIdentifier) &
      ref0(identifier) &
      (ref0(COMMA) &
              ref0(identifierOrMarker) &
              ref0(COMMA) &
              ref0(identifierOrMarker) &
              ref0(COMMA) &
              ref0(timeOrMarker))
          .optional() &
      ref0(optionalAttributeValuePairs) &
      ref0(CLOSE_PAREN);

  /*
[15]   	endExpression	   ::=   	"wasEndedBy" "(" optionalIdentifier aIdentifier ( "," eIdentifierOrMarker "," aIdentifierOrMarker "," timeOrMarker )? optionalAttributeValuePairs ")"
   */
  Parser endExpression() =>
      ref0(WAS_ENDED_BY) &
      ref0(OPEN_PAREN) &
      ref0(optionalIdentifier) &
      ref0(identifier) &
      (ref0(COMMA) &
              ref0(identifierOrMarker) &
              ref0(COMMA) &
              ref0(identifierOrMarker) &
              ref0(COMMA) &
              ref0(timeOrMarker))
          .optional() &
      ref0(optionalAttributeValuePairs) &
      ref0(CLOSE_PAREN);

  /*
[16]   	invalidationExpression	   ::=   	"wasInvalidatedBy" "(" optionalIdentifier eIdentifier ( "," aIdentifierOrMarker "," timeOrMarker )? optionalAttributeValuePairs ")"
  */
  Parser invalidationExpression() =>
      ref0(WAS_INVALIDATED_BY) &
      ref0(OPEN_PAREN) &
      ref0(optionalIdentifier) &
      ref0(identifier) &
      (ref0(COMMA) &
              ref0(identifierOrMarker) &
              ref0(COMMA) &
              ref0(timeOrMarker))
          .optional() &
      ref0(optionalAttributeValuePairs) &
      ref0(CLOSE_PAREN);

  /*
[17]   	derivationExpression	   ::=   	"wasDerivedFrom" "(" optionalIdentifier eIdentifier "," eIdentifier ( "," aIdentifierOrMarker "," gIdentifierOrMarker "," uIdentifierOrMarker )? optionalAttributeValuePairs ")"   */
  Parser derivationExpression() =>
      ref0(WAS_DERIVED_FROM) &
      ref0(OPEN_PAREN) &
      ref0(optionalIdentifier) &
      ref0(identifier) &
      ref0(COMMA) &
      ref0(identifier) &
      (ref0(COMMA) &
              ref0(identifierOrMarker) &
              ref0(COMMA) &
              ref0(identifierOrMarker) &
              ref0(COMMA) &
              ref0(identifierOrMarker))
          .optional() &
      ref0(optionalAttributeValuePairs) &
      ref0(CLOSE_PAREN);

  /*
[18]   	agentExpression	   ::=   	"agent" "(" identifier optionalAttributeValuePairs ")"

PROV-N provides no dedicated syntax for Person, Organization, SoftwareAgent. Instead, a Person, an Organization, or a SoftwareAgent must be expressed as an agentExpression with attribute prov:type='prov:Person', prov:type='prov:Organization', or prov:type='prov:SoftwareAgent', respectively.
   */
  Parser agentExpression() =>
      ref0(AGENT) &
      ref0(OPEN_PAREN) &
      ref0(identifier) &
      ref0(optionalAttributeValuePairs) &
      ref0(CLOSE_PAREN);

  /*
[19]   	attributionExpression	   ::=   	"wasAttributedTo" "(" optionalIdentifier eIdentifier "," agIdentifier optionalAttributeValuePairs ")"
   */
  Parser attributionExpression() =>
      ref0(WAS_ATTRIBUTED_TO) &
      ref0(OPEN_PAREN) &
      ref0(optionalIdentifier) &
      ref0(identifier) &
      ref0(COMMA) &
      ref0(identifier) &
      ref0(optionalAttributeValuePairs) &
      ref0(CLOSE_PAREN);

  /*
[20]   	associationExpression	   ::=   	"wasAssociatedWith" "(" optionalIdentifier aIdentifier ( "," agIdentifierOrMarker "," eIdentifierOrMarker )? optionalAttributeValuePairs ")"   */
  Parser associationExpression() =>
      ref0(WAS_ASSOCIATED_WITH) &
      ref0(OPEN_PAREN) &
      ref0(optionalIdentifier) &
      ref0(identifier) &
      (ref0(COMMA) &
              ref0(identifierOrMarker) &
              ref0(COMMA) &
              ref0(identifierOrMarker))
          .optional() &
      ref0(optionalAttributeValuePairs) &
      ref0(CLOSE_PAREN);

  /*
[21]   	delegationExpression	   ::=   	"actedOnBehalfOf" "(" optionalIdentifier agIdentifier "," agIdentifier ( "," aIdentifierOrMarker )? optionalAttributeValuePairs ")"
   */
  Parser delegationExpression() =>
      ref0(ACTED_ON_BEHALF_OF) &
      ref0(OPEN_PAREN) &
      ref0(optionalIdentifier) &
      ref0(identifier) &
      ref0(COMMA) &
      ref0(identifier) &
      (ref0(COMMA) & ref0(identifierOrMarker)).optional() &
      ref0(optionalAttributeValuePairs) &
      ref0(CLOSE_PAREN);

  /*
[22]   	influenceExpression	   ::=   	"wasInfluencedBy" "(" optionalIdentifier eIdentifier "," eIdentifier optionalAttributeValuePairs ")"
   */
  Parser influenceExpression() =>
      ref0(WAS_INFLUENCED_BY) &
      ref0(OPEN_PAREN) &
      ref0(optionalIdentifier) &
      ref0(identifier) &
      ref0(COMMA) &
      ref0(identifier) &
      ref0(optionalAttributeValuePairs) &
      ref0(CLOSE_PAREN);

  /*
[23]   	bundle	   ::=   	"bundle" identifier ([attributeValuePairs])? (namespaceDeclarations)? (expression)* "endBundle"
// extension
   */
  Parser bundle() => ref0(standardBundle) | ref0(extendedBundle);

  Parser standardBundle() =>
      ref0(START_BUNDLE) &
      ref0(identifier) &
      ref0(namespaceDeclarations).optional() &
      ref0(expression).star() &
      ref0(END_BUNDLE);

  Parser extendedBundle() =>
      ref0(START_EXTENDED_BUNDLE) &
      ref0(OPEN_PAREN) &
      ref0(identifier) &
      ref0(optionalAttributeValuePairs) &
      ref0(CLOSE_PAREN) &
      ref0(namespaceDeclarations).optional() &
      ref0(expression).star() &
      ref0(END_BUNDLE) &
      ref0(OPEN_PAREN) &
      ref0(identifier) &
      ref0(CLOSE_PAREN);

  /*
[24]   	alternateExpression	   ::=   	"alternateOf" "(" eIdentifier "," eIdentifier ")"
   */
  Parser alternateExpression() =>
      ref0(ALTERNATE_OF) &
      ref0(OPEN_PAREN) &
      ref0(identifier) &
      ref0(COMMA) &
      ref0(identifier) &
      ref0(CLOSE_PAREN);

  /*
[25]   	specializationExpression	   ::=   	"specializationOf" "(" eIdentifier "," eIdentifier ")"
   */
  Parser specializationExpression() =>
      ref0(SPECIALIZATION_OF) &
      ref0(OPEN_PAREN) &
      ref0(identifier) &
      ref0(COMMA) &
      ref0(identifier) &
      ref0(CLOSE_PAREN);

  /*
[26]   	membershipExpression	   ::=   	"hadMember" "(" cIdentifier "," eIdentifier ")"
   */
  Parser membershipExpression() =>
      ref0(HAD_MEMBER) &
      ref0(OPEN_PAREN) &
      ref0(identifier) &
      ref0(COMMA) &
      ref0(identifier) &
      ref0(CLOSE_PAREN);

  /*
[27]   	mentionOfExpression	   ::=   	"mentionOf" "(" identifier "," identifier "," identifier ")"
   */
  Parser mentionOfExpression() =>
      ref0(MENTION_OF) &
      ref0(OPEN_PAREN) &
      ref0(identifier) &
      ref0(COMMA) &
      ref0(identifier) &
      ref0(COMMA) &
      ref0(identifier) &
      ref0(CLOSE_PAREN);

  /*
 [49]   	extensibilityExpression	   ::=   	QUALIFIED_NAME "(" optionalIdentifier extensibilityArgument ( "," extensibilityArgument )* optionalAttributeValuePairs ")"
   */
  Parser extensibilityExpression() =>
      ref0(qualifiedName) &
      ref0(OPEN_PAREN) &
      ref0(optionalIdentifier) &
      ref0(extensibilityArgument).plusSeparated(ref0(COMMA)) &
      ref0(optionalAttributeValuePairs) &
      ref0(CLOSE_PAREN);

/*
[50]   	extensibilityArgument	   ::=   	( identifierOrMarker | literal | time | extensibilityExpression | extensibilityTuple )
 */
  Parser extensibilityArgument() =>
      ref0(extensibilityExpression) |
      ref0(identifierOrMarker) |
      ref0(literal) |
      ref0(datetimeLiteral) |
      ref0(extensibilityTuple);

/*
[51]   	extensibilityTuple	   ::=   	"{" extensibilityArgument ( "," extensibilityArgument )* "}" | "(" extensibilityArgument ( "," extensibilityArgument )* ")"
 */
  Parser extensibilityTuple() =>
      (ref0(OPEN_CURLY) &
          ref0(extensibilityArgument).plusSeparated(ref0(COMMA)) &
          ref0(CLOSE_CURLY)) |
      (ref0(OPEN_PAREN) &
          ref0(extensibilityArgument).plusSeparated(ref0(COMMA)) &
          ref0(CLOSE_PAREN));

/*
[45]   	namespaceDeclarations	   ::=   	( defaultNamespaceDeclaration | namespaceDeclaration ) (namespaceDeclaration)*
*/
  Parser namespaceDeclarations() =>
      (ref0(defaultNamespaceDeclaration) | ref0(namespaceDeclaration)) &
      ref0(namespaceDeclaration).star();

  /*
[46]   	namespaceDeclaration	   ::=   	"prefix" PN_PREFIX namespace
*/
  Parser namespaceDeclaration() =>
      ref0(PREFIX) & ref0(PN_PREFIX) & ref0(namespace);

/*
[47]   	defaultNamespaceDeclaration	   ::=   	"default" IRI_REF
 */
  Parser defaultNamespaceDeclaration() => ref0(DEFAULT) & ref0(IRI_REF);

  /*
[48]   	namespace	   ::=   	IRI_REF
 */
  Parser namespace() => ref0(IRI_REF);

  /*
  Extension for document and bundle..
   */
  Parser optionalIdentifierAndAttributes() => (ref0(OPEN_PAREN) &
          ref0(identifier) &
          ref0(optionalAttributeValuePairs) &
          ref0(CLOSE_PAREN))
      .optional();

  /*
  *
  * */

  Parser optionalToFrom() => (ref0(COMMA) &
          //ref0(OPEN_PAREN) &
          ref0(timeOrMarker) &
          ref0(COMMA) &
          ref0(timeOrMarker))
      //ref0(CLOSE_PAREN))
      .optional();

  /*
[4]   	optionalAttributeValuePairs	   ::=   	( "," "[" attributeValuePairs "]" )?
   */
  Parser optionalAttributeValuePairs() => (ref0(COMMA) &
          ref0(OPEN_SQUARE) &
          ref0(attributeValuePairs).optional() &
          ref0(CLOSE_SQUARE))
      .optional();

  /*
[5]   	attributeValuePairs	   ::=   	( | attributeValuePair ( "," attributeValuePair )* )
   */
  Parser attributeValuePairs() =>
      ref0(attributeValuePair).plusSeparated(ref0(COMMA));

  /*
[6]   	attributeValuePair	   ::=   	attribute "=" literal
   */
  Parser attributeValuePair() =>
      ref0(identifier) & ref0(EQUALS) & ref0(literal);

  /*
[58]   	<STRING_LITERAL>	   ::=   	STRING_LITERAL2
| STRING_LITERAL_LONG2
[60]   	<INT_LITERAL>	   ::=   	("-")? (DIGIT)+
[62]   	<DIGIT>	   ::=   	[0-9]
[61]   	<QUALIFIED_NAME_LITERAL>	   ::=   	"'" QUALIFIED_NAME "'"

// From SPARQL
[76]  	LANGTAG	  ::=  	'@' [a-zA-Z]+ ('-' [a-zA-Z0-9]+)*
[87]  	STRING_LITERAL1	  ::=  	"'" ( ([^#x27#x5C#xA#xD]) | ECHAR )* "'"
[88]  	STRING_LITERAL2	  ::=  	'"' ( ([^#x22#x5C#xA#xD]) | ECHAR )* '"'
[89]  	STRING_LITERAL_LONG1	  ::=  	"'''" ( ( "'" | "''" )? ( [^'\] | ECHAR ) )* "'''"
[90]  	STRING_LITERAL_LONG2	  ::=  	'"""' ( ( '"' | '""' )? ( [^"\] | ECHAR ) )* '"""'
[91]  	ECHAR	  ::=  	'\' [tbnrf\"']
   */
  // [40]   	literal	   ::=   	typedLiteral | convenienceNotation
  Parser literal() => ref0(typedLiteral) | ref0(convenienceNotation);

  // [41]   	typedLiteral	   ::=   	STRING_LITERAL "%%" datatype
  // [42]   	datatype	   ::=   	QUALIFIED_NAME
  Parser typedLiteral() =>
      ref0(stringLiteral) & ref0(DOUBLE_PERCENT) & ref0(QUALIFIED_NAME);

  // [43]   	convenienceNotation	   ::=   	STRING_LITERAL (LANGTAG)? | INT_LITERAL | QUALIFIED_NAME_LITERAL
  Parser convenienceNotation() =>
      ref0(stringLiteral) | ref0(numberLiteral) | ref0(qualifiedNameLiteral);

  /*
[10]   	optionalIdentifier	   ::=   	( identifierOrMarker ";" )?
   */
  Parser optionalIdentifier() =>
      (ref0(identifierOrMarker) & ref0(SEMICOLON)).optional();

  /*
[8]   	timeOrMarker	   ::=   	( time | "-" )
   */
  Parser timeOrMarker() => ref0(datetimeLiteral) | MARKER();

  /*
[11]   	identifierOrMarker	   ::=   	( identifier | "-" )
   */
  Parser identifierOrMarker() => ref0(identifier) | MARKER();

  Parser stringLiteral() => ref1(token, ref0(stringPrimitive));

  Parser numberLiteral() => ref1(token, ref0(numberPrimitive));

  Parser datetimeLiteral() => ref1(token, ref0(dateTimePrimitive));

  Parser qualifiedNameLiteral() =>
      char('\'') & ref0(QUALIFIED_NAME) & char('\'');

  Parser qualifiedName() => ref0(IDENTIFIER);

  Parser identifier() => ref0(IDENTIFIER);

  Parser dateTimePrimitive() =>
      dateTimeFromFormat('yyyy-MM-ddThh:mm:ss.SSSTZD') |
      dateTimeFromFormat('yyyy-MM-ddThh:mm:ssZ') |
      dateTimeFromFormat('yyyy-MM-ddThh:mm:ss.SSS') |
      dateTimeFromFormat('yyyy-MM-ddThh:mm:ss');

  Parser characterPrimitive() =>
      ref0(characterNormal) | ref0(characterEscape) | ref0(characterUnicode);

  Parser characterNormal() => pattern('^"\\');

  Parser characterEscape() => char('\\') & pattern(escapeChars.keys.join());

  Parser characterUnicode() => string('\\u') & pattern('0-9A-Fa-f').times(4);

  Parser numberPrimitive() =>
      char('-').optional() &
      char('0').or(digit().plus()) &
      char('.').seq(digit().plus()).optional() &
      pattern('eE')
          .seq(pattern('-+').optional())
          .seq(digit().plus())
          .optional();

  Parser stringPrimitive() =>
      char('"') & ref0(characterPrimitive).star() & char('"');

  // Whitespace and comment handling
  Parser space() => whitespace() | ref0(commentSingle) | ref0(commentMulti);

  Parser commentSingle() =>
      string('//') & pattern('\n\r').neg().star() & pattern('\n\r').optional();

  Parser commentMulti() =>
      string('/*') &
      (ref0(commentMulti) | string('*/').neg()).star() &
      string('*/');

  Parser token(Object parser, [String? message]) {
    if (parser is Parser) {
      return parser.flatten(message: message).trim(ref0(space));
    } else if (parser is String) {
      return parser
          .toParser(message: message ?? '$parser expected')
          .trim(ref0(space));
    } else {
      throw ArgumentError.value(parser, 'parser', 'Invalid parser type');
    }
  }

  Parser OPEN_CURLY() => ref1(token, '{');

  Parser CLOSE_CURLY() => ref1(token, '}');

  Parser OPEN_PAREN() => ref1(token, '(');

  Parser CLOSE_PAREN() => ref1(token, ')');

  Parser OPEN_SQUARE() => ref1(token, '[');

  Parser CLOSE_SQUARE() => ref1(token, ']');

  Parser COMMA() => ref1(token, ',');

  Parser EQUALS() => ref1(token, '=');

  Parser HYPHEN() => ref1(token, '-');

  Parser UNDERSCORE() => ref1(token, '_');

  Parser MARKER() => HYPHEN() | UNDERSCORE();

  Parser SEMICOLON() => ref1(token, ';');

  Parser DOUBLE_PERCENT() => ref1(token, '%%');

  Parser ENTITY() => ref1(token, 'entity');

  Parser PREFIX() => ref1(token, 'prefix');

  Parser DEFAULT() => ref1(token, 'default');

  Parser ACTIVITY() => ref1(token, 'activity');

  Parser WAS_GENERATED_BY() => ref1(token, 'wasGeneratedBy');

  Parser USED() => ref1(token, 'used');

  Parser WAS_STARTED_BY() => ref1(token, 'wasStartedBy');

  Parser WAS_ENDED_BY() => ref1(token, 'wasEndedBy');

  Parser WAS_INVALIDATED_BY() => ref1(token, 'wasInvalidatedBy');

  Parser WAS_DERIVED_FROM() => ref1(token, 'wasDerivedFrom');

  Parser AGENT() => ref1(token, 'agent');

  Parser WAS_ATTRIBUTED_TO() => ref1(token, 'wasAttributedTo');

  Parser WAS_ASSOCIATED_WITH() => ref1(token, 'wasAssociatedWith');

  Parser ACTED_ON_BEHALF_OF() => ref1(token, 'actedOnBehalfOf');

  Parser WAS_INFORMED_BY() => ref1(token, 'wasInformedBy');

  Parser WAS_INFLUENCED_BY() => ref1(token, 'wasInfluencedBy');

  Parser ALTERNATE_OF() => ref1(token, 'alternateOf');

  Parser SPECIALIZATION_OF() => ref1(token, 'specializationOf');

  Parser HAD_MEMBER() => ref1(token, 'hadMember');

  Parser MENTION_OF() => ref1(token, 'mentionOf');

  Parser START_DOCUMENT() =>
      ref1(token, 'document') | ref1(token, 'startDocument');

  Parser END_DOCUMENT() => ref1(token, 'endDocument');

  Parser START_BUNDLE() => ref1(token, 'bundle');

  Parser START_EXTENDED_BUNDLE() => ref1(token, 'startBundle');

  Parser END_BUNDLE() => ref1(token, 'endBundle');

  // [38]   	identifier	   ::=   	QUALIFIED_NAME
  Parser IDENTIFIER() => ref0(QUALIFIED_NAME);

  //   [52]   	<QUALIFIED_NAME>	   ::=   	( PN_PREFIX ":" )? PN_LOCAL | PN_PREFIX ":"
  Parser QUALIFIED_NAME() => ref1(
      token,
      (ref0(PN_PREFIX) & char(':')).optional() & ref0(PN_LOCAL) |
          ref0(PN_PREFIX) & char(':'));

  // Parser QUALIFIED_NAME() => ((ref0(PN_PREFIX) & char(':')).optional() & ref0(PN_LOCAL)) | (ref0(PN_PREFIX) & char(':'));

//<' ( ~('<' | '>' | '"' | '{' | '}' | '|' | '^' | '\\' | '`') | (PN_CHARS))* '>'
  Parser IRI_REF() => ref1(
        token,
        char('<') & pattern('^<>"{}|^`\\\x00-\x20').plus() & char('>'),
      ).flatten();

  // [99]  	PN_PREFIX	  ::=  	PN_CHARS_BASE ((PN_CHARS|'.')* PN_CHARS)?
  Parser PN_PREFIX() =>
      ref0(PN_CHARS_BASE) &
      ((ref0(PN_CHARS) | char('.')).star()).optional() &
      ref0(PN_CHARS).optional();

  // [100]  	[53]   	<PN_LOCAL>	   ::=   	( PN_CHARS_U | [0-9] | PN_CHARS_OTHERS ) ( ( PN_CHARS | "." | PN_CHARS_OTHERS )* ( PN_CHARS | PN_CHARS_OTHERS ) )?
  // W3C spec-compliant implementation
  // Allows PN_CHARS_U, digits, or PN_CHAR_OTHERS as first character
  // Allows PN_CHARS, ".", or PN_CHAR_OTHERS as continuation characters
  // Note: Simplified to allow trailing dots for ease of implementation
  Parser PN_LOCAL() =>
      (ref0(PN_CHARS_U) | digit() | ref0(PN_CHAR_OTHERS)) &
      (ref0(PN_CHARS) | char('.') | ref0(PN_CHAR_OTHERS)).star();

  // [95]	  PN_CHARS_BASE	  ::=  	[A-Z] | [a-z]
  // | [#x00C0-#x00D6] | [#x00D8-#x00F6] | [#x00F8-#x02FF] | [#x0370-#x037D]
  // | [#x037F-#x1FFF] | [#x200C-#x200D] | [#x2070-#x218F] | [#x2C00-#x2FEF]
  // | [#x3001-#xD7FF] | [#xF900-#xFDCF] | [#xFDF0-#xFFFD] | [#x10000-#xEFFFF]
  Parser PN_CHARS_BASE() => SingleCharacterParser(
      const PN_CHARS_BASEPredicate(), 'PN_CHARS_BASE expected');

  // [96]  	PN_CHARS_U	  ::=  	PN_CHARS_BASE | '_'
  Parser PN_CHARS_U() => ref0(PN_CHARS_BASE) | char('_');

  // [98]  	PN_CHARS	  ::=  	PN_CHARS_U | '-' | [0-9] | #x00B7 | [#x0300-#x036F] | [#x203F-#x2040]
  Parser PN_CHARS() => ref0(PN_CHARS_U) | digit() | char('-');

  /*

[54]   	<PN_CHARS_OTHERS>	   ::=   	"/"
| "@"
| "~"
| "&"
| "+"
| "*"
| "?"
| "#"
| "$"
| "!"
| PERCENT
| PN_CHARS_ESC
   */
  Parser PN_CHAR_OTHERS() => ref2(
        token,
        pattern('/@~&+*?#\$!') | ref0(PERCENT) | ref0(PN_CHARS_ESC),
        'PN_CHARS mismatch',
      );

  //[55]   	<PN_CHARS_ESC>	   ::=   	"\" ( "=" | "'" | "(" | ")" | "," | "-" | ":" | ";" | "[" | "]" | "." )
  Parser PN_CHARS_ESC() => char('\\') & (char('-') | pattern('=\'(),:;[].'));

  //[ 56]   	<PERCENT>	   ::=   	"%" HEX HEX
  Parser PERCENT() => char('%') & ref0(HEX) & ref0(HEX);

  // [57]   	<HEX>	   ::=   	[0-9] | [A-F] | [a-f]
  Parser HEX() => pattern('0-9a-fA-F');
}

class PN_CHARS_BASEPredicate extends CharacterPredicate {
  const PN_CHARS_BASEPredicate();

  // [95]  	PN_CHARS_BASE	  ::=  	[A-Z] | [a-z]
  // | [#x00C0-#x00D6] | [#x00D8-#x00F6] | [#x00F8-#x02FF] | [#x0370-#x037D]
  // | [#x037F-#x1FFF] | [#x200C-#x200D] | [#x2070-#x218F] | [#x2C00-#x2FEF]
  // | [#x3001-#xD7FF] | [#xF900-#xFDCF] | [#xFDF0-#xFFFD] | [#x10000-#xEFFFF]
  @override
  bool test(int value) =>
      (value >= 65 && value <= 90) || // [A-Z]
      (value >= 97 && value <= 122) || // [a-z]
      (value >= 0x00C0 && value <= 0x00D6) ||
      (value >= 0x00D8 && value <= 0x00F6) ||
      (value >= 0x00F8 && value <= 0x02FF) ||
      (value >= 0x0370 && value <= 0x037D) ||
      (value >= 0x037F && value <= 0x1FFF) ||
      (value >= 0x200C && value <= 0x200D) ||
      (value >= 0x2070 && value <= 0x218F) ||
      (value >= 0x2C00 && value <= 0x2FEF) ||
      (value >= 0x3001 && value <= 0xD7FF) ||
      (value >= 0xF900 && value <= 0xFDCF) ||
      (value >= 0xFDF0 && value <= 0xFFFD) ||
      (value >= 0x10000 && value <= 0xEFFFF);

  @override
  bool isEqualTo(CharacterPredicate other) => other is PN_CHARS_BASEPredicate;
}

const Map<String, String> escapeChars = {
  '\\': '\\',
  '/': '/',
  '"': '"',
  'b': '\b',
  'f': '\f',
  'n': '\n',
  'r': '\r',
  't': '\t'
};
