import 'dart:convert';
import '../../types.dart';

/// A writer that serializes PROV expressions to PROV-JSON format.
///
/// This class converts PROV expression objects into W3C PROV-JSON
/// format, a JSON representation of provenance information.
///
/// Example:
/// ```dart
/// final writer = PROVJSONWriter();
/// final json = writer.writeDocument(document);
/// ```
class PROVJSONWriter {
  /// Writes a document expression to PROV-JSON format.
  String writeDocument(DocumentExpression doc) {
    final json = <String, dynamic>{};

    // Add prefixes
    if (doc.namespaces.isNotEmpty) {
      final prefixes = <String, String>{};
      for (final ns in doc.namespaces) {
        if (ns.prefix != 'default') {
          prefixes[ns.prefix] = ns.uri;
        } else {
          prefixes['default'] = ns.uri;
        }
      }
      json['prefix'] = prefixes;
    }

    // Process expressions
    final entities = <String, dynamic>{};
    final activities = <String, dynamic>{};
    final agents = <String, dynamic>{};
    final generations = <String, dynamic>{};
    final usages = <String, dynamic>{};
    final attributions = <String, dynamic>{};
    final associations = <String, dynamic>{};
    final delegations = <String, dynamic>{};
    final derivations = <String, dynamic>{};
    final communications = <String, dynamic>{};
    final starts = <String, dynamic>{};
    final ends = <String, dynamic>{};
    final invalidations = <String, dynamic>{};
    final specializations = <String, dynamic>{};
    final alternates = <String, dynamic>{};
    final memberships = <String, dynamic>{};
    final influences = <String, dynamic>{};
    final bundles = <String, dynamic>{};

    for (final expr in doc.expressions) {
      switch (expr) {
        case EntityExpression():
          entities[expr.identifier] = _writeEntity(expr);
        case ActivityExpression():
          activities[expr.identifier] = _writeActivity(expr);
        case AgentExpression():
          agents[expr.identifier] = _writeAgent(expr);
        case GenerationExpression():
          final id = expr.id ?? '_:id${generations.length}';
          generations[id] = _writeGeneration(expr);
        case UsageExpression():
          final id = expr.id ?? '_:id${usages.length}';
          usages[id] = _writeUsage(expr);
        case AttributionExpression():
          final id = expr.id ?? '_:id${attributions.length}';
          attributions[id] = _writeAttribution(expr);
        case AssociationExpression():
          final id = expr.id ?? '_:id${associations.length}';
          associations[id] = _writeAssociation(expr);
        case DelegationExpression():
          final id = expr.id ?? '_:id${delegations.length}';
          delegations[id] = _writeDelegation(expr);
        case DerivationExpression():
          final id = expr.id ?? '_:id${derivations.length}';
          derivations[id] = _writeDerivation(expr);
        case CommunicationExpression():
          final id = expr.id ?? '_:id${communications.length}';
          communications[id] = _writeCommunication(expr);
        case StartExpression():
          final id = expr.id ?? '_:id${starts.length}';
          starts[id] = _writeStart(expr);
        case EndExpression():
          final id = expr.id ?? '_:id${ends.length}';
          ends[id] = _writeEnd(expr);
        case InvalidationExpression():
          final id = expr.id ?? '_:id${invalidations.length}';
          invalidations[id] = _writeInvalidation(expr);
        case SpecializationExpression():
          final id = '_:id${specializations.length}';
          specializations[id] = _writeSpecialization(expr);
        case AlternateExpression():
          final id = '_:id${alternates.length}';
          alternates[id] = _writeAlternate(expr);
        case MembershipExpression():
          final id = '_:id${memberships.length}';
          memberships[id] = _writeMembership(expr);
        case InfluenceExpression():
          final id = expr.id ?? '_:id${influences.length}';
          influences[id] = _writeInfluence(expr);
        case BundleExpression():
          bundles[expr.identifier] = _writeBundle(expr);
      }
    }

    // Add non-empty sections to JSON
    if (entities.isNotEmpty) json['entity'] = entities;
    if (activities.isNotEmpty) json['activity'] = activities;
    if (agents.isNotEmpty) json['agent'] = agents;
    if (generations.isNotEmpty) json['wasGeneratedBy'] = generations;
    if (usages.isNotEmpty) json['used'] = usages;
    if (attributions.isNotEmpty) json['wasAttributedTo'] = attributions;
    if (associations.isNotEmpty) json['wasAssociatedWith'] = associations;
    if (delegations.isNotEmpty) json['actedOnBehalfOf'] = delegations;
    if (derivations.isNotEmpty) json['wasDerivedFrom'] = derivations;
    if (communications.isNotEmpty) json['wasInformedBy'] = communications;
    if (starts.isNotEmpty) json['wasStartedBy'] = starts;
    if (ends.isNotEmpty) json['wasEndedBy'] = ends;
    if (invalidations.isNotEmpty) json['wasInvalidatedBy'] = invalidations;
    if (specializations.isNotEmpty) json['specializationOf'] = specializations;
    if (alternates.isNotEmpty) json['alternateOf'] = alternates;
    if (memberships.isNotEmpty) json['hadMember'] = memberships;
    if (influences.isNotEmpty) json['wasInfluencedBy'] = influences;
    if (bundles.isNotEmpty) json['bundle'] = bundles;

    return const JsonEncoder.withIndent('  ').convert(json);
  }

  Map<String, dynamic> _writeEntity(EntityExpression entity) {
    final props = <String, dynamic>{};
    _addAttributes(props, entity.attributes);
    return props;
  }

  Map<String, dynamic> _writeActivity(ActivityExpression activity) {
    final props = <String, dynamic>{};
    if (activity.from != null) {
      props['prov:startTime'] = activity.from!.toIso8601String();
    }
    if (activity.to != null) {
      props['prov:endTime'] = activity.to!.toIso8601String();
    }
    _addAttributes(props, activity.attributes);
    return props;
  }

  Map<String, dynamic> _writeAgent(AgentExpression agent) {
    final props = <String, dynamic>{};
    _addAttributes(props, agent.attributes);
    return props;
  }

  Map<String, dynamic> _writeGeneration(GenerationExpression gen) {
    final props = <String, dynamic>{};
    props['prov:entity'] = gen.entityId;
    if (gen.activityId != null) {
      props['prov:activity'] = gen.activityId;
    }
    if (gen.datetime != null) {
      props['prov:time'] = gen.datetime!.toIso8601String();
    }
    _addAttributes(props, gen.attributes);
    return props;
  }

  Map<String, dynamic> _writeUsage(UsageExpression usage) {
    final props = <String, dynamic>{};
    props['prov:activity'] = usage.activityId;
    if (usage.entityId != null) {
      props['prov:entity'] = usage.entityId;
    }
    if (usage.datetime != null) {
      props['prov:time'] = usage.datetime!.toIso8601String();
    }
    _addAttributes(props, usage.attributes);
    return props;
  }

  Map<String, dynamic> _writeAttribution(AttributionExpression attr) {
    final props = <String, dynamic>{};
    props['prov:entity'] = attr.entityId;
    props['prov:agent'] = attr.agentId;
    _addAttributes(props, attr.attributes);
    return props;
  }

  Map<String, dynamic> _writeAssociation(AssociationExpression assoc) {
    final props = <String, dynamic>{};
    props['prov:activity'] = assoc.activityId;
    if (assoc.agentId != null) {
      props['prov:agent'] = assoc.agentId;
    }
    if (assoc.planId != null) {
      props['prov:plan'] = assoc.planId;
    }
    _addAttributes(props, assoc.attributes);
    return props;
  }

  Map<String, dynamic> _writeDelegation(DelegationExpression deleg) {
    final props = <String, dynamic>{};
    props['prov:delegate'] = deleg.delegateId;
    props['prov:responsible'] = deleg.agentId;
    if (deleg.activityId != null) {
      props['prov:activity'] = deleg.activityId;
    }
    _addAttributes(props, deleg.attributes);
    return props;
  }

  Map<String, dynamic> _writeDerivation(DerivationExpression deriv) {
    final props = <String, dynamic>{};
    props['prov:generatedEntity'] = deriv.generatedEntityId;
    props['prov:usedEntity'] = deriv.usedEntityId;
    if (deriv.activityId != null) {
      props['prov:activity'] = deriv.activityId;
    }
    if (deriv.generationId != null) {
      props['prov:generation'] = deriv.generationId;
    }
    if (deriv.usageId != null) {
      props['prov:usage'] = deriv.usageId;
    }
    _addAttributes(props, deriv.attributes);
    return props;
  }

  Map<String, dynamic> _writeCommunication(CommunicationExpression comm) {
    final props = <String, dynamic>{};
    props['prov:informed'] = comm.informedAgentId;
    props['prov:informant'] = comm.informantId;
    _addAttributes(props, comm.attributes);
    return props;
  }

  Map<String, dynamic> _writeStart(StartExpression start) {
    final props = <String, dynamic>{};
    props['prov:activity'] = start.activityId;
    if (start.entityId != null) {
      props['prov:trigger'] = start.entityId;
    }
    if (start.starterId != null) {
      props['prov:starter'] = start.starterId;
    }
    if (start.datetime != null) {
      props['prov:time'] = start.datetime!.toIso8601String();
    }
    _addAttributes(props, start.attributes);
    return props;
  }

  Map<String, dynamic> _writeEnd(EndExpression end) {
    final props = <String, dynamic>{};
    props['prov:activity'] = end.activityId;
    if (end.entityId != null) {
      props['prov:trigger'] = end.entityId;
    }
    if (end.enderId != null) {
      props['prov:ender'] = end.enderId;
    }
    if (end.datetime != null) {
      props['prov:time'] = end.datetime!.toIso8601String();
    }
    _addAttributes(props, end.attributes);
    return props;
  }

  Map<String, dynamic> _writeInvalidation(InvalidationExpression inv) {
    final props = <String, dynamic>{};
    props['prov:entity'] = inv.entityId;
    if (inv.activityId != null) {
      props['prov:activity'] = inv.activityId;
    }
    if (inv.datetime != null) {
      props['prov:time'] = inv.datetime!.toIso8601String();
    }
    _addAttributes(props, inv.attributes);
    return props;
  }

  Map<String, dynamic> _writeSpecialization(SpecializationExpression spec) {
    return {
      'prov:specificEntity': spec.alternate,
      'prov:generalEntity': spec.original,
    };
  }

  Map<String, dynamic> _writeAlternate(AlternateExpression alt) {
    return {
      'prov:alternate1': alt.alternate,
      'prov:alternate2': alt.original,
    };
  }

  Map<String, dynamic> _writeMembership(MembershipExpression mem) {
    return {
      'prov:collection': mem.collection,
      'prov:entity': mem.entity,
    };
  }

  Map<String, dynamic> _writeInfluence(InfluenceExpression inf) {
    final props = <String, dynamic>{};
    props['prov:influencee'] = inf.influencee;
    props['prov:influencer'] = inf.influencer;
    _addAttributes(props, inf.attributes);
    return props;
  }

  Map<String, dynamic> _writeBundle(BundleExpression bundle) {
    // Create a temporary document for the bundle content
    final bundleDoc = DocumentExpression(bundle.namespaces, bundle.expressions);
    final bundleJson = writeDocument(bundleDoc);
    return jsonDecode(bundleJson) as Map<String, dynamic>;
  }

  void _addAttributes(Map<String, dynamic> props, List<Attribute> attributes) {
    for (final attr in attributes) {
      final key = attr.name;
      switch (attr) {
        case StringAttribute():
          props[key] = attr.value;
        case NumericAttribute():
          props[key] = attr.value;
      }
    }
  }
}
