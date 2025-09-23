import 'package:meta/meta.dart';

/// Base class for all PROV nodes.
@immutable
abstract class Node {
  const Node();
}

/// Base class for all PROV expressions.
///
/// Each expression has a [name] that identifies its type (e.g., 'entity', 'activity').
@immutable
abstract class Expression extends Node {
  /// The type name of this expression.
  final String name;

  const Expression(this.name);
}

/// Represents a namespace declaration in PROV-N.
///
/// Namespaces map prefixes to URIs, allowing qualified names like `ex:entity1`
/// where `ex` is the prefix.
@immutable
class Namespace {
  /// The namespace prefix (e.g., 'ex', 'prov').
  final String prefix;

  /// The namespace URI (e.g., 'http://example.org/').
  final String uri;

  const Namespace(this.prefix, this.uri);

  @override
  String toString() => 'prefix $prefix <$uri>';
}

/// Represents a complete PROV document.
///
/// A document contains namespace declarations and a list of PROV expressions.
/// This is the top-level container for PROV-N content.
@immutable
class DocumentExpression extends Expression {
  /// The namespace declarations for this document.
  final List<Namespace> namespaces;

  /// The PROV expressions contained in this document.
  final List<Expression> expressions;

  DocumentExpression([
    this.namespaces = const [],
    this.expressions = const [],
  ]) : super('document');

  @override
  String toString() =>
      'document(namespaces: $namespaces, expressions: $expressions)';
}

/// Represents a named bundle of provenance descriptions.
///
/// Bundles are a mechanism for grouping provenance descriptions with
/// their own namespace declarations. They can be used to describe
/// provenance of provenance.
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

  BundleExpression(
    this.identifier,
    this.attributes, [
    this.namespaces = const [],
    this.expressions = const [],
  ]) : super('bundle');

  @override
  String toString() {
    return 'bundle[identifier: $identifier, attributes: $attributes, namespaces: $namespaces, expressions: $expressions]';
  }
}

/// Represents an entity in the provenance model.
///
/// An entity is a physical, digital, conceptual, or other kind of thing
/// with some fixed aspects. Entities may be real or imaginary.
@immutable
class EntityExpression extends Expression {
  /// The unique identifier for this entity.
  final String identifier;

  /// Additional attributes describing this entity.
  final List<Attribute> attributes;

  EntityExpression(this.identifier, this.attributes) : super('entity');

  @override
  bool operator ==(Object other) =>
      other is EntityExpression && identifier == other.identifier;

  @override
  int get hashCode => identifier.hashCode;

  @override
  String toString() => 'entity($identifier)';
}

/// Represents an activity in the provenance model.
///
/// An activity is something that occurs over a period of time and acts
/// upon or with entities. It may include consuming, processing, transforming,
/// modifying, relocating, using, or generating entities.
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

  ActivityExpression(this.identifier, this.attributes, this.from, this.to)
      : super('activity');

  @override
  bool operator ==(Object other) =>
      other is ActivityExpression && identifier == other.identifier;

  @override
  int get hashCode => identifier.hashCode;

  @override
  String toString() =>
      'activity($identifier'
      ',(${from ?? '_'},${to ?? '_'}),'
      '$attributes'
      ')';
}

/// Represents the generation of an entity by an activity.
///
/// Generation is the completion of production of a new entity by an activity.
/// This entity did not exist before generation and becomes available for usage
/// after this generation.
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

  GenerationExpression(
    this.id,
    this.entityId,
    this.activityId,
    this.datetime,
    this.attributes,
  ) : super('wasGeneratedBy');

  @override
  bool operator ==(Object other) =>
      other is GenerationExpression && entityId == other.entityId;

  @override
  int get hashCode => entityId.hashCode;

  @override
  String toString() =>
      'wasGeneratedBy(${id ?? '_'},'
      '$entityId,${activityId ?? '_'},${datetime ?? '_'},'
      '$attributes'
      ')';
}

/// Represents the usage of an entity by an activity.
///
/// Usage is the beginning of utilizing an entity by an activity.
/// Before usage, the activity had not begun to utilize this entity.
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

  UsageExpression(
    this.id,
    this.entityId,
    this.activityId,
    this.datetime,
    this.attributes,
  ) : super('used');

  @override
  bool operator ==(Object other) =>
      other is GenerationExpression && activityId == other.activityId;

  @override
  int get hashCode => entityId.hashCode;

  @override
  String toString() =>
      'used(${id ?? '_'},'
      '$activityId,${entityId ?? '_'},${datetime ?? '_'},'
      '$attributes'
      ')';
}

/// Represents communication between two activities.
///
/// Communication is the exchange of an entity between two activities,
/// one activity using the entity generated by the other.
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

  CommunicationExpression(
    this.id,
    this.informedAgentId,
    this.informantId,
    this.attributes,
  ) : super('wasInformedBy');

  @override
  bool operator ==(Object other) =>
      other is CommunicationExpression &&
      informedAgentId == other.informedAgentId &&
      informantId == other.informantId;

  @override
  int get hashCode =>
      Object.hash(informedAgentId.hashCode, informantId.hashCode);

  @override
  String toString() =>
      'wasInformedBy(${id ?? '_'},'
      '$informedAgentId,$informantId,'
      '$attributes'
      ')';
}

/// Represents the start of an activity.
///
/// Start is when an activity begins, potentially triggered by an entity.
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

  StartExpression(
    this.id,
    this.entityId,
    this.activityId,
    this.starterId,
    this.datetime,
    this.attributes,
  ) : super('wasStartedBy');

  @override
  bool operator ==(Object other) =>
      other is StartExpression && activityId == other.activityId;

  @override
  int get hashCode => entityId.hashCode;

  @override
  String toString() =>
      'wasStartedBy(${id ?? '_'},'
      '$activityId,${entityId ?? '_'},${starterId ?? '_'},${datetime ?? '_'},'
      '$attributes'
      ')';
}

/// Represents the end of an activity.
///
/// End is when an activity ceases, potentially triggered by an entity.
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

  EndExpression(
    this.id,
    this.entityId,
    this.activityId,
    this.enderId,
    this.datetime,
    this.attributes,
  ) : super('wasEndedBy');

  @override
  bool operator ==(Object other) =>
      other is GenerationExpression && activityId == other.activityId;

  @override
  int get hashCode => entityId.hashCode;

  @override
  String toString() =>
      'wasEndedBy(${id ?? '_'},'
      '$activityId,${entityId ?? '_'},${enderId ?? '_'},${datetime ?? '_'},'
      '$attributes'
      ')';
}

/// Represents the invalidation of an entity.
///
/// Invalidation is the start of the destruction, cessation, or expiry
/// of an existing entity by an activity.
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

  InvalidationExpression(
    this.id,
    this.entityId,
    this.activityId,
    this.datetime,
    this.attributes,
  ) : super('wasInvalidatedBy');

  @override
  bool operator ==(Object other) =>
      other is InvalidationExpression && entityId == other.entityId;

  @override
  int get hashCode => entityId.hashCode;

  @override
  String toString() =>
      'wasInvalidatedBy(${id ?? '_'},'
      '$entityId,${activityId ?? '_'},${datetime ?? '_'},'
      '$attributes'
      ')';
}

@immutable
class DerivationExpression extends Expression {
  final String? id;
  final String generatedEntityId;
  final String usedEntityId;
  final String? activityId;
  final String? generationId;
  final String? usageId;
  final List<Attribute> attributes;

  DerivationExpression(
    this.id,
    this.generatedEntityId,
    this.usedEntityId,
    this.activityId,
    this.generationId,
    this.usageId,
    this.attributes,
  ) : super('wasDerivedFrom');

  @override
  bool operator ==(Object other) =>
      other is DerivationExpression &&
      generatedEntityId == other.generatedEntityId &&
      usedEntityId == other.usedEntityId;

  @override
  int get hashCode => generatedEntityId.hashCode;

  @override
  String toString() =>
      'wasDerivedFrom(${id ?? '_'},'
      '$generatedEntityId,$usedEntityId, ${activityId ?? '_'},${generationId ?? '_'},${usageId ?? '_'},'
      '$attributes'
      ')';
}

/// Represents an agent in the provenance model.
///
/// An agent is something that bears some form of responsibility for an
/// activity taking place, for the existence of an entity, or for another
/// agent's activity. An agent may be a person, organization, or software.
@immutable
class AgentExpression extends Expression {
  /// The unique identifier for this agent.
  final String identifier;

  /// Additional attributes describing this agent.
  final List<Attribute> attributes;

  AgentExpression(this.identifier, this.attributes) : super('agent');

  @override
  bool operator ==(Object other) =>
      other is AgentExpression && identifier == other.identifier;

  @override
  int get hashCode => identifier.hashCode;

  @override
  String toString() => 'agent($identifier)';
}

@immutable
class AttributionExpression extends Expression {
  final String? id;
  final String entityId;
  final String agentId;
  final List<Attribute> attributes;

  AttributionExpression(
    this.id,
    this.entityId,
    this.agentId,
    this.attributes,
  ) : super('wasAttributedTo');

  @override
  bool operator ==(Object other) =>
      other is AttributionExpression &&
      entityId == other.entityId &&
      agentId == other.agentId;

  @override
  int get hashCode => entityId.hashCode;

  @override
  String toString() =>
      'wasAttributedTo($id,'
      '$entityId,$agentId,'
      '$attributes'
      ')';
}

@immutable
class AssociationExpression extends Expression {
  final String? id;
  final String activityId;
  final String? agentId;
  final String? planId;
  final List<Attribute> attributes;

  AssociationExpression(
    this.id,
    this.activityId,
    this.agentId,
    this.planId,
    this.attributes,
  ) : super('wasAssociatedWith');

  @override
  bool operator ==(Object other) =>
      other is AssociationExpression &&
      activityId == other.activityId &&
      agentId == other.agentId;

  @override
  int get hashCode => activityId.hashCode;

  @override
  String toString() =>
      'wasAssociatedWith($id,'
      '$activityId, $agentId,$planId'
      '$attributes'
      ')';
}

@immutable
class DelegationExpression extends Expression {
  final String? id;
  final String delegateId;
  final String agentId;
  final String? activityId;
  final List<Attribute> attributes;

  DelegationExpression(
    this.id,
    this.delegateId,
    this.agentId,
    this.activityId,
    this.attributes,
  ) : super('actedOnBehalfOf');

  @override
  bool operator ==(Object other) =>
      other is DelegationExpression &&
      delegateId == other.delegateId &&
      agentId == other.agentId;

  @override
  int get hashCode => Object.hash(delegateId.hashCode, agentId.hashCode);

  @override
  String toString() =>
      'actedOnBehalfOf(${id ?? '_'},'
      '$delegateId, $agentId,${activityId ?? '_'}'
      '$attributes'
      ')';
}

@immutable
class InfluenceExpression extends Expression {
  final String? id;
  final String influencee;
  final String influencer;
  final List<Attribute> attributes;

  InfluenceExpression(
    this.id,
    this.influencee,
    this.influencer,
    this.attributes,
  ) : super('wasInfluencedBy');

  @override
  bool operator ==(Object other) =>
      other is InfluenceExpression &&
      influencee == other.influencee &&
      influencer == other.influencer;

  @override
  int get hashCode => Object.hash(influencee.hashCode, influencer.hashCode);

  @override
  String toString() =>
      'wasInfluencedBy(${id ?? '_'},'
      '$influencee,$influencer,'
      '$attributes'
      ')';
}

@immutable
class AlternateExpression extends Expression {
  final String alternate;
  final String original;

  AlternateExpression(this.alternate, this.original) : super('alternateOf');

  @override
  bool operator ==(Object other) =>
      other is AlternateExpression &&
      alternate == other.alternate &&
      original == other.original;

  @override
  int get hashCode => Object.hash(alternate.hashCode, original.hashCode);

  @override
  String toString() => 'alternateOf($alternate, $original)';
}

@immutable
class SpecializationExpression extends Expression {
  final String alternate;
  final String original;

  SpecializationExpression(this.alternate, this.original)
      : super('specializationOf');

  @override
  bool operator ==(Object other) =>
      other is SpecializationExpression &&
      alternate == other.alternate &&
      original == other.original;

  @override
  int get hashCode => Object.hash(alternate.hashCode, original.hashCode);

  @override
  String toString() => 'specializationOf($alternate, $original)';
}

@immutable
class MembershipExpression extends Expression {
  final String collection;
  final String entity;

  MembershipExpression(this.collection, this.entity) : super('hadMember');

  @override
  bool operator ==(Object other) =>
      other is MembershipExpression &&
      collection == other.collection &&
      entity == other.entity;

  @override
  int get hashCode => Object.hash(collection.hashCode, entity.hashCode);

  @override
  String toString() => 'hadMember($collection, $entity)';
}

@immutable
class ExtensibilityExpression extends Expression {
  final String? id;
  final List<dynamic> arguments;
  final List<Attribute> attributes;

  ExtensibilityExpression(
    this.id,
    String name,
    this.arguments,
    this.attributes,
  ) : super(name);
}

/// Base class for PROV attributes.
///
/// Attributes provide additional information about PROV elements.
/// They can be either string or numeric values.
abstract class Attribute<T> extends Node {
  /// The name of this attribute (e.g., 'prov:type', 'ex:version').
  final String name;

  /// The value of this attribute.
  final T value;

  const Attribute(this.name, this.value);

  @override
  bool operator ==(Object other) =>
      other is Attribute && name == other.name && value == other.value;

  @override
  int get hashCode => name.hashCode;
}

/// An attribute with a string value.
///
/// Used for textual properties like names, descriptions, types, etc.
class StringAttribute extends Attribute<String> {
  /// Creates a string attribute with the given [name] and [value].
  StringAttribute(super.name, super.value);

  @override
  String toString() => "$name='$value'";
}

/// An attribute with a numeric value.
///
/// Used for numeric properties like counts, sizes, versions, etc.
class NumericAttribute extends Attribute<num> {
  /// Creates a numeric attribute with the given [name] and [value].
  NumericAttribute(super.name, super.value);

  @override
  String toString() => '$name=$value';
}
