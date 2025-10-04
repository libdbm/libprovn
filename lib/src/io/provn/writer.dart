import '../../types.dart';

/// A writer that serializes PROV expressions to PROV-N notation.
///
/// This class converts PROV expression objects back into W3C PROV-N
/// text format. It handles proper formatting, indentation, and
/// escaping of special characters.
///
/// Example:
/// ```dart
/// final writer = PROVNWriter();
/// final provn = writer.writeDocument(document);
/// ```
class PROVNWriter {
  final StringBuffer _buffer = StringBuffer();
  final String _indent = '  ';
  int _indentLevel = 0;

  /// Writes a document expression to PROV-N format.
  String writeDocument(DocumentExpression doc) {
    _buffer.clear();
    _indentLevel = 0;

    _writeLine('document');
    _indentLevel++;

    // Write namespaces
    for (final ns in doc.namespaces) {
      _writeNamespace(ns);
    }

    if (doc.namespaces.isNotEmpty && doc.expressions.isNotEmpty) {
      _writeLine(''); // Empty line between namespaces and expressions
    }

    // Write expressions
    for (final expr in doc.expressions) {
      _writeExpression(expr);
    }

    _indentLevel--;
    _write('endDocument');

    return _buffer.toString();
  }

  /// Writes a list of expressions.
  String writeExpressions(List<Expression> expressions) {
    _buffer.clear();

    for (var i = 0; i < expressions.length; i++) {
      _writeExpression(expressions[i]);
      if (i < expressions.length - 1) {
        _writeLine('');
      }
    }

    return _buffer.toString();
  }

  /// Writes a single expression.
  String writeExpression(Expression expr) {
    _buffer.clear();
    _writeExpression(expr);
    return _buffer.toString();
  }

  void _writeExpression(Expression expr) {
    switch (expr) {
      case EntityExpression():
        _writeEntity(expr);
      case ActivityExpression():
        _writeActivity(expr);
      case AgentExpression():
        _writeAgent(expr);
      case GenerationExpression():
        _writeGeneration(expr);
      case UsageExpression():
        _writeUsage(expr);
      case AttributionExpression():
        _writeAttribution(expr);
      case AssociationExpression():
        _writeAssociation(expr);
      case DelegationExpression():
        _writeDelegation(expr);
      case DerivationExpression():
        _writeDerivation(expr);
      case CommunicationExpression():
        _writeCommunication(expr);
      case StartExpression():
        _writeStart(expr);
      case EndExpression():
        _writeEnd(expr);
      case InvalidationExpression():
        _writeInvalidation(expr);
      case SpecializationExpression():
        _writeSpecialization(expr);
      case AlternateExpression():
        _writeAlternate(expr);
      case MembershipExpression():
        _writeMembership(expr);
      case MentionOfExpression():
        _writeMentionOf(expr);
      case BundleExpression():
        _writeBundle(expr);
      case InfluenceExpression():
        _writeInfluence(expr);
      case ExtensibilityExpression():
        _writeExtensibility(expr);
      default:
        // Handle any other expression types
        _writeLine('// Unknown expression type: ${expr.runtimeType}');
    }
  }

  void _writeEntity(EntityExpression entity) {
    _write('entity(${entity.identifier}');
    if (entity.attributes.isNotEmpty) {
      _write(', ');
      _writeAttributes(entity.attributes);
    }
    _write(')');
    _writeLine('');
  }

  void _writeActivity(ActivityExpression activity) {
    _write('activity(${activity.identifier}');

    // Write time if present
    if (activity.from != null || activity.to != null) {
      _write(', ');
      _writeTime(activity.from);
      _write(', ');
      _writeTime(activity.to);
    }

    if (activity.attributes.isNotEmpty) {
      _write(', ');
      _writeAttributes(activity.attributes);
    }
    _write(')');
    _writeLine('');
  }

  void _writeAgent(AgentExpression agent) {
    _write('agent(${agent.identifier}');
    if (agent.attributes.isNotEmpty) {
      _write(', ');
      _writeAttributes(agent.attributes);
    }
    _write(')');
    _writeLine('');
  }

  void _writeGeneration(GenerationExpression gen) {
    _write('wasGeneratedBy(');

    if (gen.id != null && !gen.id!.startsWith('_:')) {
      _write('${gen.id}; ');
    }

    _write(gen.entityId);

    if (gen.activityId != null) {
      _write(', ${gen.activityId}');
    } else {
      _write(', -');
    }

    if (gen.datetime != null) {
      _write(', ');
      _writeTime(gen.datetime);
    } else if (gen.attributes.isNotEmpty) {
      _write(', -');
    }

    if (gen.attributes.isNotEmpty) {
      _write(', ');
      _writeAttributes(gen.attributes);
    }

    _write(')');
    _writeLine('');
  }

  void _writeUsage(UsageExpression usage) {
    _write('used(');

    if (usage.id != null && !usage.id!.startsWith('_:')) {
      _write('${usage.id}; ');
    }

    _write(usage.activityId);

    if (usage.entityId != null) {
      _write(', ${usage.entityId}');
    } else {
      _write(', -');
    }

    if (usage.datetime != null) {
      _write(', ');
      _writeTime(usage.datetime);
    } else if (usage.attributes.isNotEmpty) {
      _write(', -');
    }

    if (usage.attributes.isNotEmpty) {
      _write(', ');
      _writeAttributes(usage.attributes);
    }

    _write(')');
    _writeLine('');
  }

  void _writeAttribution(AttributionExpression attr) {
    _write('wasAttributedTo(');

    if (attr.id != null && !attr.id!.startsWith('_:')) {
      _write('${attr.id}; ');
    }

    _write('${attr.entityId}, ${attr.agentId}');

    if (attr.attributes.isNotEmpty) {
      _write(', ');
      _writeAttributes(attr.attributes);
    }

    _write(')');
    _writeLine('');
  }

  void _writeAssociation(AssociationExpression assoc) {
    _write('wasAssociatedWith(');

    if (assoc.id != null && !assoc.id!.startsWith('_:')) {
      _write('${assoc.id}; ');
    }

    _write(assoc.activityId);

    // EBNF-compliant: if agent or plan is present, both must be written
    if (assoc.agentId != null || assoc.planId != null) {
      _write(', ');
      _write(assoc.agentId ?? '-');
      _write(', ');
      _write(assoc.planId ?? '-');
    }

    if (assoc.attributes.isNotEmpty) {
      _write(', ');
      _writeAttributes(assoc.attributes);
    }

    _write(')');
    _writeLine('');
  }

  void _writeDelegation(DelegationExpression deleg) {
    _write('actedOnBehalfOf(');

    if (deleg.id != null && !deleg.id!.startsWith('_:')) {
      _write('${deleg.id}; ');
    }

    _write('${deleg.delegateId}, ${deleg.agentId}');

    if (deleg.activityId != null) {
      _write(', ');
      _write(deleg.activityId!);
    } else {
      _write(', -');
    }

    if (deleg.attributes.isNotEmpty) {
      _write(', ');
      _writeAttributes(deleg.attributes);
    }

    _write(')');
    _writeLine('');
  }

  void _writeDerivation(DerivationExpression deriv) {
    _write('wasDerivedFrom(');

    if (deriv.id != null && !deriv.id!.startsWith('_:')) {
      _write('${deriv.id}; ');
    }

    _write('${deriv.generatedEntityId}, ${deriv.usedEntityId}');

    // EBNF-compliant: if any optional parameter is present, all three must be written
    final hasOptionalParams = deriv.activityId != null ||
        deriv.generationId != null ||
        deriv.usageId != null;

    if (hasOptionalParams) {
      _write(', ');
      _write(deriv.activityId ?? '-');
      _write(', ');
      _write(deriv.generationId ?? '-');
      _write(', ');
      _write(deriv.usageId ?? '-');
    }

    if (deriv.attributes.isNotEmpty) {
      _write(', ');
      _writeAttributes(deriv.attributes);
    }

    _write(')');
    _writeLine('');
  }

  void _writeCommunication(CommunicationExpression comm) {
    _write('wasInformedBy(');

    if (comm.id != null && !comm.id!.startsWith('_:')) {
      _write('${comm.id}; ');
    }

    _write('${comm.informedAgentId}, ${comm.informantId}');

    if (comm.attributes.isNotEmpty) {
      _write(', ');
      _writeAttributes(comm.attributes);
    }

    _write(')');
    _writeLine('');
  }

  void _writeStart(StartExpression start) {
    _write('wasStartedBy(');

    if (start.id != null && !start.id!.startsWith('_:')) {
      _write('${start.id}; ');
    }

    _write(start.activityId);

    if (start.entityId != null ||
        start.starterId != null ||
        start.datetime != null ||
        start.attributes.isNotEmpty) {
      _write(', ');
      _write(start.entityId ?? '-');
    }

    if (start.starterId != null ||
        start.datetime != null ||
        start.attributes.isNotEmpty) {
      _write(', ');
      _write(start.starterId ?? '-');
    }

    if (start.datetime != null || start.attributes.isNotEmpty) {
      _write(', ');
      if (start.datetime != null) {
        _writeTime(start.datetime);
      } else {
        _write('-');
      }
    }

    if (start.attributes.isNotEmpty) {
      _write(', ');
      _writeAttributes(start.attributes);
    }

    _write(')');
    _writeLine('');
  }

  void _writeEnd(EndExpression end) {
    _write('wasEndedBy(');

    if (end.id != null && !end.id!.startsWith('_:')) {
      _write('${end.id}; ');
    }

    _write(end.activityId);

    if (end.entityId != null ||
        end.enderId != null ||
        end.datetime != null ||
        end.attributes.isNotEmpty) {
      _write(', ');
      _write(end.entityId ?? '-');
    }

    if (end.enderId != null ||
        end.datetime != null ||
        end.attributes.isNotEmpty) {
      _write(', ');
      _write(end.enderId ?? '-');
    }

    if (end.datetime != null || end.attributes.isNotEmpty) {
      _write(', ');
      if (end.datetime != null) {
        _writeTime(end.datetime);
      } else {
        _write('-');
      }
    }

    if (end.attributes.isNotEmpty) {
      _write(', ');
      _writeAttributes(end.attributes);
    }

    _write(')');
    _writeLine('');
  }

  void _writeInvalidation(InvalidationExpression inv) {
    _write('wasInvalidatedBy(');

    if (inv.id != null && !inv.id!.startsWith('_:')) {
      _write('${inv.id}; ');
    }

    _write(inv.entityId);

    if (inv.activityId != null ||
        inv.datetime != null ||
        inv.attributes.isNotEmpty) {
      _write(', ');
      _write(inv.activityId ?? '-');
    }

    if (inv.datetime != null || inv.attributes.isNotEmpty) {
      _write(', ');
      if (inv.datetime != null) {
        _writeTime(inv.datetime);
      } else {
        _write('-');
      }
    }

    if (inv.attributes.isNotEmpty) {
      _write(', ');
      _writeAttributes(inv.attributes);
    }

    _write(')');
    _writeLine('');
  }

  void _writeSpecialization(SpecializationExpression spec) {
    _write('specializationOf(${spec.alternate}, ${spec.original})');
    _writeLine('');
  }

  void _writeAlternate(AlternateExpression alt) {
    _write('alternateOf(${alt.alternate}, ${alt.original})');
    _writeLine('');
  }

  void _writeMembership(MembershipExpression mem) {
    _write('hadMember(${mem.collection}, ${mem.entity})');
    _writeLine('');
  }

  void _writeMentionOf(MentionOfExpression mention) {
    _write(
        'mentionOf(${mention.specific}, ${mention.general}, ${mention.bundle})');
    _writeLine('');
  }

  void _writeBundle(BundleExpression bundle) {
    _write('bundle ${bundle.identifier}');

    if (bundle.attributes.isNotEmpty) {
      _write(' ');
      _writeAttributes(bundle.attributes);
    }
    _writeLine('');

    _indentLevel++;

    // Write bundle namespaces
    for (final ns in bundle.namespaces) {
      _writeNamespace(ns);
    }

    if (bundle.namespaces.isNotEmpty && bundle.expressions.isNotEmpty) {
      _writeLine(''); // Empty line between namespaces and expressions
    }

    // Write bundle expressions
    for (final expr in bundle.expressions) {
      _writeExpression(expr);
    }

    _indentLevel--;

    _writeLine('endBundle');
  }

  void _writeNamespace(Namespace ns) {
    if (ns.prefix == 'default') {
      _writeLine('default <${ns.uri}>');
    } else {
      _writeLine('prefix ${ns.prefix} <${ns.uri}>');
    }
  }

  void _writeInfluence(InfluenceExpression inf) {
    _write('wasInfluencedBy(');

    if (inf.id != null && !inf.id!.startsWith('_:')) {
      _write('${inf.id}; ');
    }

    _write('${inf.influencee}, ${inf.influencer}');

    if (inf.attributes.isNotEmpty) {
      _write(', ');
      _writeAttributes(inf.attributes);
    }

    _write(')');
    _writeLine('');
  }

  void _writeExtensibility(ExtensibilityExpression ext) {
    _write('${ext.name}(');

    bool first = true;
    for (final arg in ext.arguments) {
      if (!first) _write(', ');
      _write(arg);
      first = false;
    }

    if (ext.attributes.isNotEmpty) {
      if (ext.arguments.isNotEmpty) _write(', ');
      _writeAttributes(ext.attributes);
    }

    _write(')');
    _writeLine('');
  }

  void _writeAttributes(List<Attribute> attrs) {
    _write('[');

    for (var i = 0; i < attrs.length; i++) {
      if (i > 0) _write(', ');
      _writeAttribute(attrs[i]);
    }

    _write(']');
  }

  void _writeAttribute(Attribute attr) {
    _write(attr.name.toString());
    _write('=');

    switch (attr) {
      case StringAttribute():
        _write('"${_escapeString(attr.value)}"');
      case NumericAttribute():
        _write(attr.value.toString());
      default:
        _write(attr.toString());
    }
  }

  void _writeTime(DateTime? time) {
    if (time == null) {
      _write('-');
    } else {
      _write(time.toIso8601String());
    }
  }

  String _escapeString(String s) {
    return s
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }

  void _write(String s) {
    _buffer.write(s);
  }

  void _writeLine(String s) {
    if (s.isNotEmpty) {
      _buffer.write(_indent * _indentLevel);
      _buffer.write(s);
    }
    _buffer.writeln();
  }
}
