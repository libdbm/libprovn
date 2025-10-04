import 'dart:convert';
import '../../types.dart';

/// A reader that deserializes PROV-JSON format to PROV expressions.
///
/// This class parses W3C PROV-JSON format and converts it into
/// PROV expression objects that can be manipulated programmatically
/// or converted to other formats.
///
/// Example:
/// ```dart
/// final reader = PROVJSONReader();
/// final document = reader.readDocument(str);
/// ```
class PROVJSONReader {
  /// Reads a PROV-JSON string and returns a DocumentExpression.
  DocumentExpression readDocument(String str) {
    final json = jsonDecode(str) as Map<String, dynamic>;
    return _parseDocument(json);
  }

  DocumentExpression _parseDocument(Map<String, dynamic> json) {
    final namespaces = <Namespace>[];
    final expressions = <Expression>[];

    // Parse prefixes
    if (json.containsKey('prefix')) {
      final prefixes = json['prefix'] as Map<String, dynamic>;
      prefixes.forEach((prefix, uri) {
        namespaces.add(Namespace(prefix, uri.toString()));
      });
    }

    // Parse entities
    if (json.containsKey('entity')) {
      final entities = json['entity'] as Map<String, dynamic>;
      entities.forEach((id, props) {
        expressions.add(_parseEntity(id, props as Map<String, dynamic>));
      });
    }

    // Parse activities
    if (json.containsKey('activity')) {
      final activities = json['activity'] as Map<String, dynamic>;
      activities.forEach((id, props) {
        expressions.add(_parseActivity(id, props as Map<String, dynamic>));
      });
    }

    // Parse agents
    if (json.containsKey('agent')) {
      final agents = json['agent'] as Map<String, dynamic>;
      agents.forEach((id, props) {
        expressions.add(_parseAgent(id, props as Map<String, dynamic>));
      });
    }

    // Parse wasGeneratedBy
    if (json.containsKey('wasGeneratedBy')) {
      final generations = json['wasGeneratedBy'] as Map<String, dynamic>;
      generations.forEach((id, props) {
        expressions.add(_parseGeneration(id, props as Map<String, dynamic>));
      });
    }

    // Parse used
    if (json.containsKey('used')) {
      final usages = json['used'] as Map<String, dynamic>;
      usages.forEach((id, props) {
        expressions.add(_parseUsage(id, props as Map<String, dynamic>));
      });
    }

    // Parse wasAttributedTo
    if (json.containsKey('wasAttributedTo')) {
      final attributions = json['wasAttributedTo'] as Map<String, dynamic>;
      attributions.forEach((id, props) {
        expressions.add(_parseAttribution(id, props as Map<String, dynamic>));
      });
    }

    // Parse wasAssociatedWith
    if (json.containsKey('wasAssociatedWith')) {
      final associations = json['wasAssociatedWith'] as Map<String, dynamic>;
      associations.forEach((id, props) {
        expressions.add(_parseAssociation(id, props as Map<String, dynamic>));
      });
    }

    // Parse actedOnBehalfOf
    if (json.containsKey('actedOnBehalfOf')) {
      final delegations = json['actedOnBehalfOf'] as Map<String, dynamic>;
      delegations.forEach((id, props) {
        expressions.add(_parseDelegation(id, props as Map<String, dynamic>));
      });
    }

    // Parse wasDerivedFrom
    if (json.containsKey('wasDerivedFrom')) {
      final derivations = json['wasDerivedFrom'] as Map<String, dynamic>;
      derivations.forEach((id, props) {
        expressions.add(_parseDerivation(id, props as Map<String, dynamic>));
      });
    }

    // Parse wasInformedBy
    if (json.containsKey('wasInformedBy')) {
      final communications = json['wasInformedBy'] as Map<String, dynamic>;
      communications.forEach((id, props) {
        expressions.add(_parseCommunication(id, props as Map<String, dynamic>));
      });
    }

    // Parse wasStartedBy
    if (json.containsKey('wasStartedBy')) {
      final starts = json['wasStartedBy'] as Map<String, dynamic>;
      starts.forEach((id, props) {
        expressions.add(_parseStart(id, props as Map<String, dynamic>));
      });
    }

    // Parse wasEndedBy
    if (json.containsKey('wasEndedBy')) {
      final ends = json['wasEndedBy'] as Map<String, dynamic>;
      ends.forEach((id, props) {
        expressions.add(_parseEnd(id, props as Map<String, dynamic>));
      });
    }

    // Parse wasInvalidatedBy
    if (json.containsKey('wasInvalidatedBy')) {
      final invalidations = json['wasInvalidatedBy'] as Map<String, dynamic>;
      invalidations.forEach((id, props) {
        expressions.add(_parseInvalidation(id, props as Map<String, dynamic>));
      });
    }

    // Parse specializationOf
    if (json.containsKey('specializationOf')) {
      final specializations = json['specializationOf'] as Map<String, dynamic>;
      specializations.forEach((id, props) {
        expressions
            .add(_parseSpecialization(id, props as Map<String, dynamic>));
      });
    }

    // Parse alternateOf
    if (json.containsKey('alternateOf')) {
      final alternates = json['alternateOf'] as Map<String, dynamic>;
      alternates.forEach((id, props) {
        expressions.add(_parseAlternate(id, props as Map<String, dynamic>));
      });
    }

    // Parse hadMember
    if (json.containsKey('hadMember')) {
      final memberships = json['hadMember'] as Map<String, dynamic>;
      memberships.forEach((id, props) {
        expressions.add(_parseMembership(id, props as Map<String, dynamic>));
      });
    }

    // Parse mentionOf
    if (json.containsKey('mentionOf')) {
      final mentions = json['mentionOf'] as Map<String, dynamic>;
      mentions.forEach((id, props) {
        expressions.add(_parseMentionOf(id, props as Map<String, dynamic>));
      });
    }

    // Parse wasInfluencedBy
    if (json.containsKey('wasInfluencedBy')) {
      final influences = json['wasInfluencedBy'] as Map<String, dynamic>;
      influences.forEach((id, props) {
        expressions.add(_parseInfluence(id, props as Map<String, dynamic>));
      });
    }

    // Parse bundles
    if (json.containsKey('bundle')) {
      final bundles = json['bundle'] as Map<String, dynamic>;
      bundles.forEach((id, bundleJson) {
        expressions.add(_parseBundle(id, bundleJson as Map<String, dynamic>));
      });
    }

    return DocumentExpression(namespaces, expressions);
  }

  EntityExpression _parseEntity(String id, Map<String, dynamic> props) {
    final attributes = _parseAttributes(props);
    return EntityExpression(id, attributes);
  }

  ActivityExpression _parseActivity(String id, Map<String, dynamic> props) {
    final from = props.containsKey('prov:startTime')
        ? DateTime.parse(props['prov:startTime'].toString())
        : null;
    final to = props.containsKey('prov:endTime')
        ? DateTime.parse(props['prov:endTime'].toString())
        : null;
    final attributes =
        _parseAttributes(props, exclude: {'prov:startTime', 'prov:endTime'});
    return ActivityExpression(id, attributes, from, to);
  }

  AgentExpression _parseAgent(String id, Map<String, dynamic> props) {
    final attributes = _parseAttributes(props);
    return AgentExpression(id, attributes);
  }

  GenerationExpression _parseGeneration(String id, Map<String, dynamic> props) {
    final entityId = props['prov:entity']?.toString() ?? '';
    final activityId = props['prov:activity']?.toString();
    final datetime = props.containsKey('prov:time')
        ? DateTime.parse(props['prov:time'].toString())
        : null;
    final attributes = _parseAttributes(props,
        exclude: {'prov:entity', 'prov:activity', 'prov:time'});
    return GenerationExpression(
        id == '_:id' ? null : id, entityId, activityId, datetime, attributes);
  }

  UsageExpression _parseUsage(String id, Map<String, dynamic> props) {
    final activityId = props['prov:activity']?.toString() ?? '';
    final entityId = props['prov:entity']?.toString();
    final datetime = props.containsKey('prov:time')
        ? DateTime.parse(props['prov:time'].toString())
        : null;
    final attributes = _parseAttributes(props,
        exclude: {'prov:activity', 'prov:entity', 'prov:time'});
    return UsageExpression(id == '_:id' ? null : id, activityId,
        entityId ?? '-', datetime, attributes);
  }

  AttributionExpression _parseAttribution(
      String id, Map<String, dynamic> props) {
    final entityId = props['prov:entity']?.toString() ?? '';
    final agentId = props['prov:agent']?.toString() ?? '';
    final attributes =
        _parseAttributes(props, exclude: {'prov:entity', 'prov:agent'});
    return AttributionExpression(
        id == '_:id' ? null : id, entityId, agentId, attributes);
  }

  AssociationExpression _parseAssociation(
      String id, Map<String, dynamic> props) {
    final activityId = props['prov:activity']?.toString() ?? '';
    final agentId = props['prov:agent']?.toString();
    final planId = props['prov:plan']?.toString();
    final attributes = _parseAttributes(props,
        exclude: {'prov:activity', 'prov:agent', 'prov:plan'});
    return AssociationExpression(
        id == '_:id' ? null : id, activityId, agentId, planId, attributes);
  }

  DelegationExpression _parseDelegation(String id, Map<String, dynamic> props) {
    final delegateId = props['prov:delegate']?.toString() ?? '';
    final agentId = props['prov:responsible']?.toString() ?? '';
    final activityId = props['prov:activity']?.toString() ?? '';
    final attributes = _parseAttributes(props,
        exclude: {'prov:delegate', 'prov:responsible', 'prov:activity'});
    return DelegationExpression(
        id, delegateId, agentId, activityId, attributes);
  }

  DerivationExpression _parseDerivation(String id, Map<String, dynamic> props) {
    final generatedId = props['prov:generatedEntity']?.toString() ?? '';
    final usedId = props['prov:usedEntity']?.toString() ?? '';
    final activityId = props['prov:activity']?.toString();
    final generationId = props['prov:generation']?.toString();
    final usageId = props['prov:usage']?.toString();
    final attributes = _parseAttributes(props, exclude: {
      'prov:generatedEntity',
      'prov:usedEntity',
      'prov:activity',
      'prov:generation',
      'prov:usage'
    });
    return DerivationExpression(id == '_:id' ? null : id, generatedId, usedId,
        activityId, generationId, usageId, attributes);
  }

  CommunicationExpression _parseCommunication(
      String id, Map<String, dynamic> props) {
    final informedId = props['prov:informed']?.toString() ?? '';
    final informantId = props['prov:informant']?.toString() ?? '';
    final attributes =
        _parseAttributes(props, exclude: {'prov:informed', 'prov:informant'});
    return CommunicationExpression(id, informedId, informantId, attributes);
  }

  StartExpression _parseStart(String id, Map<String, dynamic> props) {
    final activityId = props['prov:activity']?.toString() ?? '';
    final entityId = props['prov:trigger']?.toString();
    final starterId = props['prov:starter']?.toString();
    final datetime = props.containsKey('prov:time')
        ? DateTime.parse(props['prov:time'].toString())
        : null;
    final attributes = _parseAttributes(props, exclude: {
      'prov:activity',
      'prov:trigger',
      'prov:starter',
      'prov:time'
    });
    return StartExpression(id == '_:id' ? null : id, activityId,
        entityId ?? '-', starterId, datetime, attributes);
  }

  EndExpression _parseEnd(String id, Map<String, dynamic> props) {
    final activityId = props['prov:activity']?.toString() ?? '';
    final entityId = props['prov:trigger']?.toString();
    final enderId = props['prov:ender']?.toString();
    final datetime = props.containsKey('prov:time')
        ? DateTime.parse(props['prov:time'].toString())
        : null;
    final attributes = _parseAttributes(props,
        exclude: {'prov:activity', 'prov:trigger', 'prov:ender', 'prov:time'});
    return EndExpression(id == '_:id' ? null : id, activityId, entityId ?? '-',
        enderId, datetime, attributes);
  }

  InvalidationExpression _parseInvalidation(
      String id, Map<String, dynamic> props) {
    final entityId = props['prov:entity']?.toString() ?? '';
    final activityId = props['prov:activity']?.toString();
    final datetime = props.containsKey('prov:time')
        ? DateTime.parse(props['prov:time'].toString())
        : null;
    final attributes = _parseAttributes(props,
        exclude: {'prov:entity', 'prov:activity', 'prov:time'});
    return InvalidationExpression(
        id == '_:id' ? null : id, entityId, activityId, datetime, attributes);
  }

  SpecializationExpression _parseSpecialization(
      String id, Map<String, dynamic> props) {
    final alternate = props['prov:specificEntity']?.toString() ?? id;
    final original = props['prov:generalEntity']?.toString() ?? '';
    return SpecializationExpression(alternate, original);
  }

  AlternateExpression _parseAlternate(String id, Map<String, dynamic> props) {
    final alternate = props['prov:alternate1']?.toString() ?? id;
    final original = props['prov:alternate2']?.toString() ?? '';
    return AlternateExpression(alternate, original);
  }

  MembershipExpression _parseMembership(String id, Map<String, dynamic> props) {
    final collection = props['prov:collection']?.toString() ?? id;
    final entity = props['prov:entity']?.toString() ?? '';
    return MembershipExpression(collection, entity);
  }

  MentionOfExpression _parseMentionOf(String id, Map<String, dynamic> props) {
    final specific = props['prov:specificEntity']?.toString() ?? id;
    final general = props['prov:generalEntity']?.toString() ?? '';
    final bundle = props['prov:bundle']?.toString() ?? '';
    return MentionOfExpression(specific, general, bundle);
  }

  InfluenceExpression _parseInfluence(String id, Map<String, dynamic> props) {
    final influencee = props['prov:influencee']?.toString() ?? '';
    final influencer = props['prov:influencer']?.toString() ?? '';
    final attributes = _parseAttributes(props,
        exclude: {'prov:influencee', 'prov:influencer'});
    return InfluenceExpression(id, influencee, influencer, attributes);
  }

  BundleExpression _parseBundle(String id, Map<String, dynamic> bundleJson) {
    final bundleDoc = _parseDocument(bundleJson);
    return BundleExpression(
      id,
      [], // No attributes in PROV-JSON for bundles
      bundleDoc.namespaces,
      bundleDoc.expressions,
    );
  }

  List<Attribute> _parseAttributes(Map<String, dynamic> props,
      {Set<String>? exclude}) {
    final attributes = <Attribute>[];
    final excluded = exclude ?? {};

    props.forEach((key, value) {
      if (!excluded.contains(key) && !key.startsWith('prov:')) {
        if (value is String) {
          attributes.add(StringAttribute(key, value));
        } else if (value is num) {
          attributes.add(NumericAttribute(key, value));
        } else if (value is Map && value.containsKey('\$')) {
          // Typed literal
          final literalValue = value['\$'];
          if (literalValue is String) {
            attributes.add(StringAttribute(key, literalValue));
          } else if (literalValue is num) {
            attributes.add(NumericAttribute(key, literalValue));
          }
        }
      }
    });

    return attributes;
  }
}
