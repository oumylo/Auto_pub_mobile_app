/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;
import 'package:collection/collection.dart';


/** This is an auto generated class representing the Campagne type in your schema. */
class Campagne extends amplify_core.Model {
  static const classType = const _CampagneModelType();
  final String id;
  final String? _owner;
  final String? _titre;
  final double? _budget;
  final List<String>? _zonesCibles;
  final String? _description;
  final String? _visuelUrl;
  final String? _propositionChoisie;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  CampagneModelIdentifier get modelIdentifier {
      return CampagneModelIdentifier(
        id: id
      );
  }
  
  String? get owner {
    return _owner;
  }
  
  String get titre {
    try {
      return _titre!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get budget {
    try {
      return _budget!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String> get zonesCibles {
    try {
      return _zonesCibles!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get description {
    try {
      return _description!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get visuelUrl {
    try {
      return _visuelUrl!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get propositionChoisie {
    return _propositionChoisie;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Campagne._internal({required this.id, owner, required titre, required budget, required zonesCibles, required description, required visuelUrl, propositionChoisie, createdAt, updatedAt}): _owner = owner, _titre = titre, _budget = budget, _zonesCibles = zonesCibles, _description = description, _visuelUrl = visuelUrl, _propositionChoisie = propositionChoisie, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Campagne({String? id, String? owner, required String titre, required double budget, required List<String> zonesCibles, required String description, required String visuelUrl, String? propositionChoisie, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt, required String statut}) {
    return Campagne._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      owner: owner,
      titre: titre,
      budget: budget,
      zonesCibles: zonesCibles != null ? List<String>.unmodifiable(zonesCibles) : zonesCibles,
      description: description,
      visuelUrl: visuelUrl,
      propositionChoisie: propositionChoisie,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Campagne &&
      id == other.id &&
      _owner == other._owner &&
      _titre == other._titre &&
      _budget == other._budget &&
      DeepCollectionEquality().equals(_zonesCibles, other._zonesCibles) &&
      _description == other._description &&
      _visuelUrl == other._visuelUrl &&
      _propositionChoisie == other._propositionChoisie &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Campagne {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("owner=" + "$_owner" + ", ");
    buffer.write("titre=" + "$_titre" + ", ");
    buffer.write("budget=" + (_budget != null ? _budget!.toString() : "null") + ", ");
    buffer.write("zonesCibles=" + (_zonesCibles != null ? _zonesCibles!.toString() : "null") + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("visuelUrl=" + "$_visuelUrl" + ", ");
    buffer.write("propositionChoisie=" + "$_propositionChoisie" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Campagne copyWith({String? owner, String? titre, double? budget, List<String>? zonesCibles, String? description, String? visuelUrl, String? propositionChoisie, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Campagne._internal(
      id: id,
      owner: owner ?? this.owner,
      titre: titre ?? this.titre,
      budget: budget ?? this.budget,
      zonesCibles: zonesCibles ?? this.zonesCibles,
      description: description ?? this.description,
      visuelUrl: visuelUrl ?? this.visuelUrl,
      propositionChoisie: propositionChoisie ?? this.propositionChoisie,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  Campagne copyWithModelFieldValues({
    ModelFieldValue<String?>? owner,
    ModelFieldValue<String>? titre,
    ModelFieldValue<double>? budget,
    ModelFieldValue<List<String>>? zonesCibles,
    ModelFieldValue<String>? description,
    ModelFieldValue<String>? visuelUrl,
    ModelFieldValue<String?>? propositionChoisie,
    ModelFieldValue<amplify_core.TemporalDateTime?>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime?>? updatedAt
  }) {
    return Campagne._internal(
      id: id,
      owner: owner == null ? this.owner : owner.value,
      titre: titre == null ? this.titre : titre.value,
      budget: budget == null ? this.budget : budget.value,
      zonesCibles: zonesCibles == null ? this.zonesCibles : zonesCibles.value,
      description: description == null ? this.description : description.value,
      visuelUrl: visuelUrl == null ? this.visuelUrl : visuelUrl.value,
      propositionChoisie: propositionChoisie == null ? this.propositionChoisie : propositionChoisie.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  Campagne.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _owner = json['owner'],
      _titre = json['titre'],
      _budget = (json['budget'] as num?)?.toDouble(),
      _zonesCibles = json['zonesCibles']?.cast<String>(),
      _description = json['description'],
      _visuelUrl = json['visuelUrl'],
      _propositionChoisie = json['propositionChoisie'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'owner': _owner, 'titre': _titre, 'budget': _budget, 'zonesCibles': _zonesCibles, 'description': _description, 'visuelUrl': _visuelUrl, 'propositionChoisie': _propositionChoisie, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'owner': _owner,
    'titre': _titre,
    'budget': _budget,
    'zonesCibles': _zonesCibles,
    'description': _description,
    'visuelUrl': _visuelUrl,
    'propositionChoisie': _propositionChoisie,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<CampagneModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<CampagneModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final OWNER = amplify_core.QueryField(fieldName: "owner");
  static final TITRE = amplify_core.QueryField(fieldName: "titre");
  static final BUDGET = amplify_core.QueryField(fieldName: "budget");
  static final ZONESCIBLES = amplify_core.QueryField(fieldName: "zonesCibles");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final VISUELURL = amplify_core.QueryField(fieldName: "visuelUrl");
  static final PROPOSITIONCHOISIE = amplify_core.QueryField(fieldName: "propositionChoisie");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Campagne";
    modelSchemaDefinition.pluralName = "Campagnes";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "owner",
        identityClaim: "cognito:username",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        operations: const [
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Campagne.OWNER,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Campagne.TITRE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Campagne.BUDGET,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Campagne.ZONESCIBLES,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Campagne.DESCRIPTION,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Campagne.VISUELURL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Campagne.PROPOSITIONCHOISIE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Campagne.CREATEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Campagne.UPDATEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _CampagneModelType extends amplify_core.ModelType<Campagne> {
  const _CampagneModelType();
  
  @override
  Campagne fromJson(Map<String, dynamic> jsonData) {
    return Campagne.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Campagne';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Campagne] in your schema.
 */
class CampagneModelIdentifier implements amplify_core.ModelIdentifier<Campagne> {
  final String id;

  /** Create an instance of CampagneModelIdentifier using [id] the primary key. */
  const CampagneModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'CampagneModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is CampagneModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}