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


/** This is an auto generated class representing the Conducteur type in your schema. */
class Conducteur extends amplify_core.Model {
  static const classType = const _ConducteurModelType();
  final String id;
  final String? _owner;
  final String? _nom;
  final String? _email;
  final String? _telephone;
  final String? _typeSupport;
  final String? _typeVoiture;
  final List<String>? _zones;
  final String? _heuresConduite;
  final String? _ciRectoUrl;
  final String? _ciVersoUrl;
  final String? _cgRectoUrl;
  final String? _cgVersoUrl;
  final List<String>? _campagnesAssignees;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ConducteurModelIdentifier get modelIdentifier {
      return ConducteurModelIdentifier(
        id: id
      );
  }
  
  String? get owner {
    return _owner;
  }
  
  String get nom {
    try {
      return _nom!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get email {
    try {
      return _email!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get telephone {
    try {
      return _telephone!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get typeSupport {
    try {
      return _typeSupport!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get typeVoiture {
    try {
      return _typeVoiture!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String> get zones {
    try {
      return _zones!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get heuresConduite {
    try {
      return _heuresConduite!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get ciRectoUrl {
    try {
      return _ciRectoUrl!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get ciVersoUrl {
    try {
      return _ciVersoUrl!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get cgRectoUrl {
    try {
      return _cgRectoUrl!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get cgVersoUrl {
    try {
      return _cgVersoUrl!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String>? get campagnesAssignees {
    return _campagnesAssignees;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Conducteur._internal({required this.id, owner, required nom, required email, required telephone, required typeSupport, required typeVoiture, required zones, required heuresConduite, required ciRectoUrl, required ciVersoUrl, required cgRectoUrl, required cgVersoUrl, campagnesAssignees, createdAt, updatedAt}): _owner = owner, _nom = nom, _email = email, _telephone = telephone, _typeSupport = typeSupport, _typeVoiture = typeVoiture, _zones = zones, _heuresConduite = heuresConduite, _ciRectoUrl = ciRectoUrl, _ciVersoUrl = ciVersoUrl, _cgRectoUrl = cgRectoUrl, _cgVersoUrl = cgVersoUrl, _campagnesAssignees = campagnesAssignees, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Conducteur({String? id, String? owner, required String nom, required String email, required String telephone, required String typeSupport, required String typeVoiture, required List<String> zones, required String heuresConduite, required String ciRectoUrl, required String ciVersoUrl, required String cgRectoUrl, required String cgVersoUrl, List<String>? campagnesAssignees, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Conducteur._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      owner: owner,
      nom: nom,
      email: email,
      telephone: telephone,
      typeSupport: typeSupport,
      typeVoiture: typeVoiture,
      zones: zones != null ? List<String>.unmodifiable(zones) : zones,
      heuresConduite: heuresConduite,
      ciRectoUrl: ciRectoUrl,
      ciVersoUrl: ciVersoUrl,
      cgRectoUrl: cgRectoUrl,
      cgVersoUrl: cgVersoUrl,
      campagnesAssignees: campagnesAssignees != null ? List<String>.unmodifiable(campagnesAssignees) : campagnesAssignees,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Conducteur &&
      id == other.id &&
      _owner == other._owner &&
      _nom == other._nom &&
      _email == other._email &&
      _telephone == other._telephone &&
      _typeSupport == other._typeSupport &&
      _typeVoiture == other._typeVoiture &&
      DeepCollectionEquality().equals(_zones, other._zones) &&
      _heuresConduite == other._heuresConduite &&
      _ciRectoUrl == other._ciRectoUrl &&
      _ciVersoUrl == other._ciVersoUrl &&
      _cgRectoUrl == other._cgRectoUrl &&
      _cgVersoUrl == other._cgVersoUrl &&
      DeepCollectionEquality().equals(_campagnesAssignees, other._campagnesAssignees) &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Conducteur {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("owner=" + "$_owner" + ", ");
    buffer.write("nom=" + "$_nom" + ", ");
    buffer.write("email=" + "$_email" + ", ");
    buffer.write("telephone=" + "$_telephone" + ", ");
    buffer.write("typeSupport=" + "$_typeSupport" + ", ");
    buffer.write("typeVoiture=" + "$_typeVoiture" + ", ");
    buffer.write("zones=" + (_zones != null ? _zones!.toString() : "null") + ", ");
    buffer.write("heuresConduite=" + "$_heuresConduite" + ", ");
    buffer.write("ciRectoUrl=" + "$_ciRectoUrl" + ", ");
    buffer.write("ciVersoUrl=" + "$_ciVersoUrl" + ", ");
    buffer.write("cgRectoUrl=" + "$_cgRectoUrl" + ", ");
    buffer.write("cgVersoUrl=" + "$_cgVersoUrl" + ", ");
    buffer.write("campagnesAssignees=" + (_campagnesAssignees != null ? _campagnesAssignees!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Conducteur copyWith({String? owner, String? nom, String? email, String? telephone, String? typeSupport, String? typeVoiture, List<String>? zones, String? heuresConduite, String? ciRectoUrl, String? ciVersoUrl, String? cgRectoUrl, String? cgVersoUrl, List<String>? campagnesAssignees, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Conducteur._internal(
      id: id,
      owner: owner ?? this.owner,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      typeSupport: typeSupport ?? this.typeSupport,
      typeVoiture: typeVoiture ?? this.typeVoiture,
      zones: zones ?? this.zones,
      heuresConduite: heuresConduite ?? this.heuresConduite,
      ciRectoUrl: ciRectoUrl ?? this.ciRectoUrl,
      ciVersoUrl: ciVersoUrl ?? this.ciVersoUrl,
      cgRectoUrl: cgRectoUrl ?? this.cgRectoUrl,
      cgVersoUrl: cgVersoUrl ?? this.cgVersoUrl,
      campagnesAssignees: campagnesAssignees ?? this.campagnesAssignees,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  Conducteur copyWithModelFieldValues({
    ModelFieldValue<String?>? owner,
    ModelFieldValue<String>? nom,
    ModelFieldValue<String>? email,
    ModelFieldValue<String>? telephone,
    ModelFieldValue<String>? typeSupport,
    ModelFieldValue<String>? typeVoiture,
    ModelFieldValue<List<String>>? zones,
    ModelFieldValue<String>? heuresConduite,
    ModelFieldValue<String>? ciRectoUrl,
    ModelFieldValue<String>? ciVersoUrl,
    ModelFieldValue<String>? cgRectoUrl,
    ModelFieldValue<String>? cgVersoUrl,
    ModelFieldValue<List<String>>? campagnesAssignees,
    ModelFieldValue<amplify_core.TemporalDateTime?>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime?>? updatedAt
  }) {
    return Conducteur._internal(
      id: id,
      owner: owner == null ? this.owner : owner.value,
      nom: nom == null ? this.nom : nom.value,
      email: email == null ? this.email : email.value,
      telephone: telephone == null ? this.telephone : telephone.value,
      typeSupport: typeSupport == null ? this.typeSupport : typeSupport.value,
      typeVoiture: typeVoiture == null ? this.typeVoiture : typeVoiture.value,
      zones: zones == null ? this.zones : zones.value,
      heuresConduite: heuresConduite == null ? this.heuresConduite : heuresConduite.value,
      ciRectoUrl: ciRectoUrl == null ? this.ciRectoUrl : ciRectoUrl.value,
      ciVersoUrl: ciVersoUrl == null ? this.ciVersoUrl : ciVersoUrl.value,
      cgRectoUrl: cgRectoUrl == null ? this.cgRectoUrl : cgRectoUrl.value,
      cgVersoUrl: cgVersoUrl == null ? this.cgVersoUrl : cgVersoUrl.value,
      campagnesAssignees: campagnesAssignees == null ? this.campagnesAssignees : campagnesAssignees.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  Conducteur.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _owner = json['owner'],
      _nom = json['nom'],
      _email = json['email'],
      _telephone = json['telephone'],
      _typeSupport = json['typeSupport'],
      _typeVoiture = json['typeVoiture'],
      _zones = json['zones']?.cast<String>(),
      _heuresConduite = json['heuresConduite'],
      _ciRectoUrl = json['ciRectoUrl'],
      _ciVersoUrl = json['ciVersoUrl'],
      _cgRectoUrl = json['cgRectoUrl'],
      _cgVersoUrl = json['cgVersoUrl'],
      _campagnesAssignees = json['campagnesAssignees']?.cast<String>(),
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'owner': _owner, 'nom': _nom, 'email': _email, 'telephone': _telephone, 'typeSupport': _typeSupport, 'typeVoiture': _typeVoiture, 'zones': _zones, 'heuresConduite': _heuresConduite, 'ciRectoUrl': _ciRectoUrl, 'ciVersoUrl': _ciVersoUrl, 'cgRectoUrl': _cgRectoUrl, 'cgVersoUrl': _cgVersoUrl, 'campagnesAssignees': _campagnesAssignees, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'owner': _owner,
    'nom': _nom,
    'email': _email,
    'telephone': _telephone,
    'typeSupport': _typeSupport,
    'typeVoiture': _typeVoiture,
    'zones': _zones,
    'heuresConduite': _heuresConduite,
    'ciRectoUrl': _ciRectoUrl,
    'ciVersoUrl': _ciVersoUrl,
    'cgRectoUrl': _cgRectoUrl,
    'cgVersoUrl': _cgVersoUrl,
    'campagnesAssignees': _campagnesAssignees,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<ConducteurModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ConducteurModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final OWNER = amplify_core.QueryField(fieldName: "owner");
  static final NOM = amplify_core.QueryField(fieldName: "nom");
  static final EMAIL = amplify_core.QueryField(fieldName: "email");
  static final TELEPHONE = amplify_core.QueryField(fieldName: "telephone");
  static final TYPESUPPORT = amplify_core.QueryField(fieldName: "typeSupport");
  static final TYPEVOITURE = amplify_core.QueryField(fieldName: "typeVoiture");
  static final ZONES = amplify_core.QueryField(fieldName: "zones");
  static final HEURESCONDUITE = amplify_core.QueryField(fieldName: "heuresConduite");
  static final CIRECTOURL = amplify_core.QueryField(fieldName: "ciRectoUrl");
  static final CIVERSOURL = amplify_core.QueryField(fieldName: "ciVersoUrl");
  static final CGRECTOURL = amplify_core.QueryField(fieldName: "cgRectoUrl");
  static final CGVERSOURL = amplify_core.QueryField(fieldName: "cgVersoUrl");
  static final CAMPAGNESASSIGNEES = amplify_core.QueryField(fieldName: "campagnesAssignees");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Conducteur";
    modelSchemaDefinition.pluralName = "Conducteurs";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.GROUPS,
        groupClaim: "cognito:groups",
        groups: [ "Admin" ],
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "owner",
        identityClaim: "cognito:username",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.UPDATE
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        operations: const [
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.CREATE
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Conducteur.OWNER,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Conducteur.NOM,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Conducteur.EMAIL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Conducteur.TELEPHONE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Conducteur.TYPESUPPORT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Conducteur.TYPEVOITURE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Conducteur.ZONES,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Conducteur.HEURESCONDUITE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Conducteur.CIRECTOURL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Conducteur.CIVERSOURL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Conducteur.CGRECTOURL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Conducteur.CGVERSOURL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Conducteur.CAMPAGNESASSIGNEES,
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Conducteur.CREATEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Conducteur.UPDATEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _ConducteurModelType extends amplify_core.ModelType<Conducteur> {
  const _ConducteurModelType();
  
  @override
  Conducteur fromJson(Map<String, dynamic> jsonData) {
    return Conducteur.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Conducteur';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Conducteur] in your schema.
 */
class ConducteurModelIdentifier implements amplify_core.ModelIdentifier<Conducteur> {
  final String id;

  /** Create an instance of ConducteurModelIdentifier using [id] the primary key. */
  const ConducteurModelIdentifier({
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
  String toString() => 'ConducteurModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ConducteurModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}