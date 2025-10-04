import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Base class for all PROV nodes.
@immutable
abstract class Node {
  /// Creates a base PROV node.
  const Node();
}

/// Base class for all PROV expressions.
///
/// Each expression has a [name] that identifies its type (e.g., 'entity', 'activity').
@immutable
abstract class Expression extends Node {
  /// The type name of this expression.
  final String name;

  /// Creates a PROV expression with the given type [name].
  const Expression(this.name);
}

/// Represents a namespace declaration in PROV-N.
///
/// In PROV-N, namespace bindings are declared with the `prefix` statement and
/// allow qualified names such as `ex:e1`, where `ex` expands to a URI.
/// A namespace maps a short [prefix] to a base [uri] used to qualify identifiers.
///
/// Example (PROV-N):
///   prefix ex <http://example.org/>
///   entity(ex:e1)
@immutable
class Namespace {
  /// The namespace prefix (e.g., 'ex', 'prov').
  final String prefix;

  /// The namespace URI (e.g., 'http://example.org/').
  final String uri;

  /// Creates a namespace declaration mapping [prefix] to [uri].
  const Namespace(this.prefix, this.uri);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Namespace &&
          runtimeType == other.runtimeType &&
          prefix == other.prefix &&
          uri == other.uri;

  @override
  int get hashCode => Object.hash(prefix, uri);

  @override
  String toString() => 'prefix $prefix <$uri>';
}

/// Represents a complete PROV document.
///
/// In PROV-N, a document is the top-level container that may declare namespaces
/// and contain one or more expressions (entities, activities, agents, and
/// relations). It may also contain bundles.
///
/// PROV-N form:
///   document
///     prefix ex <http://example.org/>
///     entity(ex:e1)
///     activity(ex:a, 2024-01-01T00:00:00Z, -)
///   endDocument
@immutable
class DocumentExpression extends Expression {
  /// The namespace declarations for this document.
  final List<Namespace> namespaces;

  /// The PROV expressions contained in this document.
  final List<Expression> expressions;

  /// Creates a PROV document with optional [namespaces] and [expressions].
  DocumentExpression([
    List<Namespace> namespaces = const [],
    List<Expression> expressions = const [],
  ])  : namespaces = List.unmodifiable(namespaces),
        expressions = List.unmodifiable(expressions),
        super('document');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentExpression &&
          runtimeType == other.runtimeType &&
          const DeepCollectionEquality().equals(namespaces, other.namespaces) &&
          const DeepCollectionEquality().equals(expressions, other.expressions);

  @override
  int get hashCode => Object.hash(
        const DeepCollectionEquality().hash(namespaces),
        const DeepCollectionEquality().hash(expressions),
      );

  @override
  String toString() =>
      'document(namespaces: $namespaces, expressions: $expressions)';
}

/// Represents a named bundle of provenance descriptions.
///
/// A bundle is a named set of provenance descriptions with its own optional
/// namespace declarations. Bundles enable provenance of provenance and the
/// encapsulation of subgraphs within a document.
///
/// PROV-N form:
///   bundle ex:b
///     entity(ex:e1)
///   endBundle
@immutable
class BundleExpression extends Expression {
  /// The unique identifier for this bundle.
  final String identifier;

  /// The namespace declarations specific to this bundle.
  final List<Namespace> namespaces;

  /// The PROV expressions contained in this bundle.
  final List<Expression> expressions;

  /// Additional attributes for this bundle.
  final List<Attribute> attributes;

  /// Creates a bundle identified by [identifier] with [attributes], and optional [namespaces] and [expressions].
  BundleExpression(
    this.identifier,
    List<Attribute> attributes, [
    List<Namespace> namespaces = const [],
    List<Expression> expressions = const [],
  ])  : attributes = List.unmodifiable(attributes),
        namespaces = List.unmodifiable(namespaces),
        expressions = List.unmodifiable(expressions),
        super('bundle');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BundleExpression &&
          runtimeType == other.runtimeType &&
          identifier == other.identifier &&
          const DeepCollectionEquality().equals(namespaces, other.namespaces) &&
          const DeepCollectionEquality()
              .equals(expressions, other.expressions) &&
          const DeepCollectionEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => Object.hash(
        identifier,
        const DeepCollectionEquality().hash(namespaces),
        const DeepCollectionEquality().hash(expressions),
        const DeepCollectionEquality().hash(attributes),
      );

  @override
  String toString() {
    return 'bundle[identifier: $identifier, attributes: $attributes, namespaces: $namespaces, expressions: $expressions]';
  }
}

/// Represents an entity (prov:Entity).
///
/// An entity is a physical, digital, conceptual, or other kind of thing with
/// fixed aspects. Entities may be real or imaginary.
///
/// PROV-N form:
///   entity(e, [attr1=val1, ...])
@immutable
class EntityExpression extends Expression {
  /// The unique identifier for this entity.
  final String identifier;

  /// Additional attributes describing this entity.
  final List<Attribute> attributes;

  /// Creates an entity with [identifier] and associated [attributes].
  EntityExpression(this.identifier, List<Attribute> attributes)
      : attributes = List.unmodifiable(attributes),
        super('entity');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntityExpression &&
          runtimeType == other.runtimeType &&
          identifier == other.identifier &&
          const DeepCollectionEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => Object.hash(
        identifier,
        const DeepCollectionEquality().hash(attributes),
      );

  @override
  String toString() => 'entity($identifier)';
}

/// Represents an activity (prov:Activity).
///
/// An activity occurs over a period of time and acts upon or with entities.
/// It may consume, process, transform, modify, relocate, use, or generate
/// entities.
///
/// PROV-N form:
///   activity(a, startTime, endTime, [attrs])
@immutable
class ActivityExpression extends Expression {
  /// The unique identifier for this activity.
  final String identifier;

  /// Additional attributes describing this activity.
  final List<Attribute> attributes;

  /// The optional start time of this activity.
  final DateTime? from;

  /// The optional end time of this activity.
  final DateTime? to;

  /// Creates an activity with [identifier], [attributes], and optional start/end times [from] and [to].
  ActivityExpression(
      this.identifier, List<Attribute> attributes, this.from, this.to)
      : attributes = List.unmodifiable(attributes),
        super('activity');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityExpression &&
          runtimeType == other.runtimeType &&
          identifier == other.identifier &&
          const DeepCollectionEquality().equals(attributes, other.attributes) &&
          from == other.from &&
          to == other.to;

  @override
  int get hashCode => Object.hash(
        identifier,
        const DeepCollectionEquality().hash(attributes),
        from,
        to,
      );

  @override
  String toString() => 'activity($identifier'
      ',(${from ?? '_'},${to ?? '_'}),'
      '$attributes'
      ')';
}

/// Represents the generation of an entity by an activity (wasGeneratedBy).
///
/// Generation is the completion of production of a new entity by an activity.
/// The entity did not exist before generation and becomes available for usage
/// after this event.
///
/// PROV-N form:
///   wasGeneratedBy(e, a, t, [attrs])
/// where e=entity, a=activity (optional), t=time (optional).
@immutable
class GenerationExpression extends Expression {
  /// Optional identifier for this generation relationship.
  final String? id;

  /// The identifier of the entity that was generated.
  final String entityId;

  /// The optional identifier of the activity that generated the entity.
  final String? activityId;

  /// The optional time at which the entity was generated.
  final DateTime? datetime;

  /// Additional attributes for this generation.
  final List<Attribute> attributes;

  /// Creates a generation relation for [entityId] optionally by [activityId] at [datetime], with optional [id] and [attributes].
  GenerationExpression(
    this.id,
    this.entityId,
    this.activityId,
    this.datetime,
    List<Attribute> attributes,
  )   : attributes = List.unmodifiable(attributes),
        super('wasGeneratedBy');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerationExpression &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          entityId == other.entityId &&
          activityId == other.activityId &&
          datetime == other.datetime &&
          const DeepCollectionEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => Object.hash(
        id,
        entityId,
        activityId,
        datetime,
        const DeepCollectionEquality().hash(attributes),
      );

  @override
  String toString() => 'wasGeneratedBy(${id ?? '_'},'
      '$entityId,${activityId ?? '_'},${datetime ?? '_'},'
      '$attributes'
      ')';
}

/// Represents the usage of an entity by an activity (used).
///
/// Usage marks the beginning of utilizing an entity by an activity.
/// Before usage, the activity had not begun to utilize this entity.
///
/// PROV-N form:
///   used(a, e, t, [attrs])
/// where a=activity, e=entity (optional), t=time (optional).
@immutable
class UsageExpression extends Expression {
  /// Optional identifier for this usage relationship.
  final String? id;

  /// The optional identifier of the entity that was used.
  final String? entityId;

  /// The identifier of the activity that used the entity.
  final String activityId;

  /// The optional time at which the entity was used.
  final DateTime? datetime;

  /// Additional attributes for this usage.
  final List<Attribute> attributes;

  /// Creates a usage relation where [activityId] used [entityId] at [datetime], with optional [id] and [attributes].
  UsageExpression(
    this.id,
    this.entityId,
    this.activityId,
    this.datetime,
    List<Attribute> attributes,
  )   : attributes = List.unmodifiable(attributes),
        super('used');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsageExpression &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          entityId == other.entityId &&
          activityId == other.activityId &&
          datetime == other.datetime &&
          const DeepCollectionEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => Object.hash(
        id,
        entityId,
        activityId,
        datetime,
        const DeepCollectionEquality().hash(attributes),
      );

  @override
  String toString() => 'used(${id ?? '_'},'
      '$activityId,${entityId ?? '_'},${datetime ?? '_'},'
      '$attributes'
      ')';
}

/// Represents communication between two activities (wasInformedBy).
///
/// Communication captures that one activity was informed by another activity,
/// typically by using an entity generated by the other.
///
/// PROV-N form:
///   wasInformedBy(a2, a1, [attrs])
/// where a1 informs a2.
@immutable
class CommunicationExpression extends Expression {
  /// Optional identifier for this communication relationship.
  final String? id;

  /// The identifier of the activity that was informed.
  final String informedAgentId;

  /// The identifier of the activity that informed.
  final String informantId;

  /// Additional attributes for this communication.
  final List<Attribute> attributes;

  /// Creates a communication relation between [informedAgentId] and [informantId], with optional [id] and [attributes].
  CommunicationExpression(
    this.id,
    this.informedAgentId,
    this.informantId,
    List<Attribute> attributes,
  )   : attributes = List.unmodifiable(attributes),
        super('wasInformedBy');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommunicationExpression &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          informedAgentId == other.informedAgentId &&
          informantId == other.informantId &&
          const DeepCollectionEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => Object.hash(
        id,
        informedAgentId,
        informantId,
        const DeepCollectionEquality().hash(attributes),
      );

  @override
  String toString() => 'wasInformedBy(${id ?? '_'},'
      '$informedAgentId,$informantId,'
      '$attributes'
      ')';
}

/// Represents the start of an activity (wasStartedBy).
///
/// Start describes when an activity begins, possibly triggered by an entity
/// or another activity.
///
/// PROV-N form:
///   wasStartedBy(a, e, starter, t, [attrs])
@immutable
class StartExpression extends Expression {
  /// Optional identifier for this start relationship.
  final String? id;

  /// The optional identifier of the triggering entity.
  final String? entityId;

  /// The identifier of the activity that was started.
  final String activityId;

  /// The optional identifier of the activity that started this activity.
  final String? starterId;

  /// The optional time at which the activity started.
  final DateTime? datetime;

  /// Additional attributes for this start.
  final List<Attribute> attributes;

  /// Creates a start relation for [activityId], optionally triggered by [entityId] or [starterId] at [datetime], with optional [id] and [attributes].
  StartExpression(
    this.id,
    this.entityId,
    this.activityId,
    this.starterId,
    this.datetime,
    List<Attribute> attributes,
  )   : attributes = List.unmodifiable(attributes),
        super('wasStartedBy');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StartExpression &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          entityId == other.entityId &&
          activityId == other.activityId &&
          starterId == other.starterId &&
          datetime == other.datetime &&
          const DeepCollectionEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => Object.hash(
        id,
        entityId,
        activityId,
        starterId,
        datetime,
        const DeepCollectionEquality().hash(attributes),
      );

  @override
  String toString() => 'wasStartedBy(${id ?? '_'},'
      '$activityId,${entityId ?? '_'},${starterId ?? '_'},${datetime ?? '_'},'
      '$attributes'
      ')';
}

/// Represents the end of an activity (wasEndedBy).
///
/// End describes when an activity completes, possibly triggered by an entity
/// or another activity.
///
/// PROV-N form:
///   wasEndedBy(a, e, ender, t, [attrs])
@immutable
class EndExpression extends Expression {
  /// Optional identifier for this end relationship.
  final String? id;

  /// The optional identifier of the triggering entity.
  final String? entityId;

  /// The identifier of the activity that ended.
  final String activityId;

  /// The optional identifier of the activity that ended this activity.
  final String? enderId;

  /// The optional time at which the activity ended.
  final DateTime? datetime;

  /// Additional attributes for this end.
  final List<Attribute> attributes;

  /// Creates an end relation for [activityId], optionally triggered by [entityId] or [enderId] at [datetime], with optional [id] and [attributes].
  EndExpression(
    this.id,
    this.entityId,
    this.activityId,
    this.enderId,
    this.datetime,
    List<Attribute> attributes,
  )   : attributes = List.unmodifiable(attributes),
        super('wasEndedBy');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EndExpression &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          entityId == other.entityId &&
          activityId == other.activityId &&
          enderId == other.enderId &&
          datetime == other.datetime &&
          const DeepCollectionEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => Object.hash(
        id,
        entityId,
        activityId,
        enderId,
        datetime,
        const DeepCollectionEquality().hash(attributes),
      );

  @override
  String toString() => 'wasEndedBy(${id ?? '_'},'
      '$activityId,${entityId ?? '_'},${enderId ?? '_'},${datetime ?? '_'},'
      '$attributes'
      ')';
}

/// Represents the invalidation of an entity (wasInvalidatedBy).
///
/// Invalidation is the start of the destruction, cessation, or expiry of an
/// existing entity by an activity.
///
/// PROV-N form:
///   wasInvalidatedBy(e, a, t, [attrs])
@immutable
class InvalidationExpression extends Expression {
  /// Optional identifier for this invalidation relationship.
  final String? id;

  /// The identifier of the entity that was invalidated.
  final String entityId;

  /// The optional identifier of the activity that invalidated the entity.
  final String? activityId;

  /// The optional time at which the entity was invalidated.
  final DateTime? datetime;

  /// Additional attributes for this invalidation.
  final List<Attribute> attributes;

  /// Creates an invalidation relation for [entityId], optionally by [activityId] at [datetime], with optional [id] and [attributes].
  InvalidationExpression(
    this.id,
    this.entityId,
    this.activityId,
    this.datetime,
    List<Attribute> attributes,
  )   : attributes = List.unmodifiable(attributes),
        super('wasInvalidatedBy');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvalidationExpression &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          entityId == other.entityId &&
          activityId == other.activityId &&
          datetime == other.datetime &&
          const DeepCollectionEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => Object.hash(
        id,
        entityId,
        activityId,
        datetime,
        const DeepCollectionEquality().hash(attributes),
      );

  @override
  String toString() => 'wasInvalidatedBy(${id ?? '_'},'
      '$entityId,${activityId ?? '_'},${datetime ?? '_'},'
      '$attributes'
      ')';
}

/// Represents the derivation of one entity from another (wasDerivedFrom).
///
/// Derivation states that an entity was transformed, created from, or otherwise
/// derived from another entity. The qualified form can also specify the activity,
/// generation, and usage that connect the two.
///
/// PROV-N forms:
///   wasDerivedFrom(e2, e1, [attrs])              // simple
///   wasDerivedFrom(e2, e1, a, g2, u1, [attrs])   // qualified
@immutable
class DerivationExpression extends Expression {
  /// The optional id of this expression.
  final String? id;

  /// The id of the entity that was generated.
  final String generatedEntityId;

  /// The id of the entity used in the generation.
  final String usedEntityId;

  /// The optional id of the activity that generated the entity.
  final String? activityId;

  /// The optional id of the specific instance of the generation that occurred.
  final String? generationId;

  /// The optional id of the specific usage instance.
  final String? usageId;

  /// Attributes captured as part of this expression.
  final List<Attribute> attributes;

  /// Creates a derivation relation from [usedEntityId] to [generatedEntityId],
  /// with optional [activityId], [generationId], [usageId], [id], and [attributes].
  DerivationExpression(
    this.id,
    this.generatedEntityId,
    this.usedEntityId,
    this.activityId,
    this.generationId,
    this.usageId,
    List<Attribute> attributes,
  )   : attributes = List.unmodifiable(attributes),
        super('wasDerivedFrom');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DerivationExpression &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          generatedEntityId == other.generatedEntityId &&
          usedEntityId == other.usedEntityId &&
          activityId == other.activityId &&
          generationId == other.generationId &&
          usageId == other.usageId &&
          const DeepCollectionEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => Object.hash(
        id,
        generatedEntityId,
        usedEntityId,
        activityId,
        generationId,
        usageId,
        const DeepCollectionEquality().hash(attributes),
      );

  @override
  String toString() => 'wasDerivedFrom(${id ?? '_'},'
      '$generatedEntityId,$usedEntityId, ${activityId ?? '_'},${generationId ?? '_'},${usageId ?? '_'},'
      '$attributes'
      ')';
}

/// Represents an agent (prov:Agent).
///
/// An agent bears responsibility for an activity taking place, for the
/// existence of an entity, or for another agent's activity. Typical agents
/// include persons, organizations, or software.
///
/// PROV-N form:
///   agent(ag, [attrs])
@immutable
class AgentExpression extends Expression {
  /// The unique identifier for this agent.
  final String identifier;

  /// Additional attributes describing this agent.
  final List<Attribute> attributes;

  /// Creates an agent with [identifier] and associated [attributes].
  AgentExpression(this.identifier, List<Attribute> attributes)
      : attributes = List.unmodifiable(attributes),
        super('agent');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentExpression &&
          runtimeType == other.runtimeType &&
          identifier == other.identifier &&
          const DeepCollectionEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => Object.hash(
        identifier,
        const DeepCollectionEquality().hash(attributes),
      );

  @override
  String toString() => 'agent($identifier)';
}

/// Represents the attribution of an entity to an agent (wasAttributedTo).
///
/// Attribution associates an entity with the agent responsible for its
/// existence.
///
/// PROV-N form:
///   wasAttributedTo(e, ag, [attrs])
@immutable
class AttributionExpression extends Expression {
  /// The optional id of this expression.
  final String? id;

  /// The id of the entity attributed to the agent.
  final String entityId;

  /// The id of the agent the entity is attributed to.
  final String agentId;

  /// The set of attributes collected by this attribution.
  final List<Attribute> attributes;

  /// Creates an attribution relation assigning [entityId] to [agentId], with optional [id] and [attributes].
  AttributionExpression(
    this.id,
    this.entityId,
    this.agentId,
    List<Attribute> attributes,
  )   : attributes = List.unmodifiable(attributes),
        super('wasAttributedTo');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttributionExpression &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          entityId == other.entityId &&
          agentId == other.agentId &&
          const DeepCollectionEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => Object.hash(
        id,
        entityId,
        agentId,
        const DeepCollectionEquality().hash(attributes),
      );

  @override
  String toString() => 'wasAttributedTo($id,'
      '$entityId,$agentId,'
      '$attributes'
      ')';
}

/// Represents the association of an activity with an agent (wasAssociatedWith).
///
/// Association links an activity to the agent responsible for its execution,
/// optionally via a plan.
///
/// PROV-N form:
///   wasAssociatedWith(a, ag, plan, [attrs])
@immutable
class AssociationExpression extends Expression {
  /// The id of the activity associated with the agent.
  final String activityId;

  /// An optional id of the plan associated with the activity.
  final String? planId;

  /// The optional id of this expression.
  final String? id;

  /// The id of the agent associated with the activity.
  final String? agentId;

  /// The set of attributes collected by this association.
  final List<Attribute> attributes;

  /// Creates an association between [activityId] and [agentId], optionally with [planId], [id], and [attributes].
  AssociationExpression(
    this.id,
    this.activityId,
    this.agentId,
    this.planId,
    List<Attribute> attributes,
  )   : attributes = List.unmodifiable(attributes),
        super('wasAssociatedWith');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssociationExpression &&
          runtimeType == other.runtimeType &&
          activityId == other.activityId &&
          planId == other.planId &&
          id == other.id &&
          agentId == other.agentId &&
          const DeepCollectionEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => Object.hash(
        activityId,
        planId,
        id,
        agentId,
        const DeepCollectionEquality().hash(attributes),
      );

  @override
  String toString() => 'wasAssociatedWith($id,'
      '$activityId, $agentId,$planId'
      '$attributes'
      ')';
}

/// Represents delegation between two agents.
///
/// Delegation (actedOnBehalfOf) states that one agent (the delegate) acted on
/// behalf of another agent (the responsible) in the context of an optional
/// activity. It is used to attribute responsibility across agents according to
/// the PROV Data Model.
@immutable
class DelegationExpression extends Expression {
  /// Optional identifier for this delegation (qualified influence) statement.
  final String? id;

  /// Identifier of the delegate agent (the subordinate acting on behalf of another).
  final String delegateId;

  /// Identifier of the responsible agent on whose behalf the delegate acted.
  final String agentId;

  /// Optional identifier of the activity within which the delegation occurred.
  final String? activityId;

  /// Additional attributes qualifying this delegation (e.g., prov:role).
  final List<Attribute> attributes;

  /// Creates a delegation relation where [delegateId] acted on behalf of [agentId], optionally in [activityId], with optional [id] and [attributes].
  DelegationExpression(
    this.id,
    this.delegateId,
    this.agentId,
    this.activityId,
    List<Attribute> attributes,
  )   : attributes = List.unmodifiable(attributes),
        super('actedOnBehalfOf');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelegationExpression &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          delegateId == other.delegateId &&
          agentId == other.agentId &&
          activityId == other.activityId &&
          const DeepCollectionEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => Object.hash(
        id,
        delegateId,
        agentId,
        activityId,
        const DeepCollectionEquality().hash(attributes),
      );

  @override
  String toString() => 'actedOnBehalfOf(${id ?? '_'},'
      '$delegateId, $agentId,${activityId ?? '_'}'
      '$attributes'
      ')';
}

/// Represents a generic influence relation between two PROV elements.
///
/// Influence (wasInfluencedBy) captures that one element had an effect on
/// another, without specifying the nature of that effect. It generalizes other
/// influence relations in PROV (e.g., derivation, attribution, association).
@immutable
class InfluenceExpression extends Expression {
  /// Optional identifier for this influence statement.
  final String? id;

  /// Identifier of the influenced element (entity, activity, or agent).
  final String influencee;

  /// Identifier of the influencing element (entity, activity, or agent).
  final String influencer;

  /// Additional attributes qualifying this influence.
  final List<Attribute> attributes;

  /// Creates an influence relation where [influencee] was influenced by [influencer], with optional [id] and [attributes].
  InfluenceExpression(
    this.id,
    this.influencee,
    this.influencer,
    List<Attribute> attributes,
  )   : attributes = List.unmodifiable(attributes),
        super('wasInfluencedBy');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InfluenceExpression &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          influencee == other.influencee &&
          influencer == other.influencer &&
          const DeepCollectionEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => Object.hash(
        id,
        influencee,
        influencer,
        const DeepCollectionEquality().hash(attributes),
      );

  @override
  String toString() => 'wasInfluencedBy(${id ?? '_'},'
      '$influencee,$influencer,'
      '$attributes'
      ')';
}

/// Represents alternates: two entities that present aspects of the same thing.
///
/// Alternate (alternateOf) asserts that the two entities are alternates of one
/// another, i.e., different representations, views, or versions of the same
/// underlying entity as per the PROV Data Model.
@immutable
class AlternateExpression extends Expression {
  /// The alternate item.
  final String alternate;

  /// The original item.
  final String original;

  /// Creates an alternate relation between [alternate] and [original].
  AlternateExpression(this.alternate, this.original) : super('alternateOf');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlternateExpression &&
          runtimeType == other.runtimeType &&
          alternate == other.alternate &&
          original == other.original;

  @override
  int get hashCode => Object.hash(alternate, original);

  @override
  String toString() => 'alternateOf($alternate, $original)';
}

/// Represents specialization between two entities.
///
/// Specialization (specializationOf) states that one entity is a more specific
/// version of another, inheriting its characteristics while adding constraints
/// or detail, following the PROV specification.
@immutable
class SpecializationExpression extends Expression {
  /// Identifier of the specialized entity (the more specific entity).
  final String alternate;

  /// Identifier of the general entity of which [alternate] is a specialization.
  final String original;

  /// Creates a specialization relation where [alternate] is a specialization of [original].
  SpecializationExpression(this.alternate, this.original)
      : super('specializationOf');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpecializationExpression &&
          runtimeType == other.runtimeType &&
          alternate == other.alternate &&
          original == other.original;

  @override
  int get hashCode => Object.hash(alternate, original);

  @override
  String toString() => 'specializationOf($alternate, $original)';
}

/// Represents membership of an entity in a collection.
///
/// Membership (hadMember) asserts that an entity is a member of a collection,
/// aligning with the PROV Collections extension in PROV-N/PROV-DM.
@immutable
class MembershipExpression extends Expression {
  /// The identity of the collection.
  final String collection;

  /// The identity of the entity which is a member of the collection.
  final String entity;

  /// Creates a membership relation where [entity] is a member of [collection].
  MembershipExpression(this.collection, this.entity) : super('hadMember');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MembershipExpression &&
          runtimeType == other.runtimeType &&
          collection == other.collection &&
          entity == other.entity;

  @override
  int get hashCode => Object.hash(collection, entity);

  @override
  String toString() => 'hadMember($collection, $entity)';
}

/// Represents a mention of an entity in a bundle.
///
/// MentionOf (mentionOf) asserts that a specific entity is mentioned in a bundle
/// as a specialization of a more general entity. This is part of the PROV
/// collections extension and enables provenance of provenance.
///
/// PROV-N form:
///   mentionOf(specificEntity, generalEntity, bundle)
@immutable
class MentionOfExpression extends Expression {
  /// The identifier of the specific entity being mentioned.
  final String specific;

  /// The identifier of the general entity.
  final String general;

  /// The identifier of the bundle in which the mention occurs.
  final String bundle;

  /// Creates a mention relation where [specific] is a mention of [general] in [bundle].
  MentionOfExpression(this.specific, this.general, this.bundle)
      : super('mentionOf');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MentionOfExpression &&
          runtimeType == other.runtimeType &&
          specific == other.specific &&
          general == other.general &&
          bundle == other.bundle;

  @override
  int get hashCode => Object.hash(specific, general, bundle);

  @override
  String toString() => 'mentionOf($specific, $general, $bundle)';
}

/// Represents user-defined extensions to the PROV relation vocabulary.
///
/// Extensibility expressions allow naming custom relations not covered by the
/// core PROV relations, while still carrying positional arguments and standard
/// PROV attributes, consistent with PROV-N extensibility.
@immutable
class ExtensibilityExpression extends Expression {
  /// Optional identifier associated with this expression
  final String? id;

  /// The arguments captured as part of this expression.
  final List<dynamic> arguments;

  /// The attributes associated with this expression.
  final List<Attribute> attributes;

  /// Creates an extensibility expression with the given [name], optional [id], positional [arguments], and [attributes].
  ExtensibilityExpression(
    this.id,
    String name,
    List<dynamic> arguments,
    List<Attribute> attributes,
  )   : arguments = List.unmodifiable(arguments),
        attributes = List.unmodifiable(attributes),
        super(name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensibilityExpression &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          const DeepCollectionEquality().equals(arguments, other.arguments) &&
          const DeepCollectionEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => Object.hash(
        id,
        const DeepCollectionEquality().hash(arguments),
        const DeepCollectionEquality().hash(attributes),
      );
}

/// Base class for PROV attributes.
///
/// Attributes attach additional information to PROV elements in the form of
/// key=value pairs (e.g., prov:type, prov:label, prov:role). In PROV-N, they
/// appear in square brackets after an expression.
///
/// Example (PROV-N):
///   entity(e, [prov:type='ex:Report', ex:version=2])
///
/// Implementations here support common value types such as strings and numbers.
abstract class Attribute<T> extends Node {
  /// The name of this attribute (e.g., 'prov:type', 'ex:version').
  final String name;

  /// The value of this attribute.
  final T value;

  /// Creates an attribute with [name] and [value].
  const Attribute(this.name, this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Attribute &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          value == other.value;

  @override
  int get hashCode => Object.hash(name, value);
}

/// An attribute with a string value.
///
/// Suitable for textual properties such as prov:label or string-valued prov:type.
///
/// Example (PROV-N):
///   entity(e, [prov:label='Final Report'])
class StringAttribute extends Attribute<String> {
  /// Creates a string attribute with the given [name] and [value].
  StringAttribute(super.name, super.value);

  @override
  String toString() => "$name='$value'";
}

/// An attribute with a numeric value.
///
/// Suitable for numeric properties like counts, sizes, or versions.
///
/// Example (PROV-N):
///   entity(e, [ex:version=2])
class NumericAttribute extends Attribute<num> {
  /// Creates a numeric attribute with the given [name] and [value].
  NumericAttribute(super.name, super.value);

  @override
  String toString() => '$name=$value';
}
