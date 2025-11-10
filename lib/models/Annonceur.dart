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


/** This is an auto generated class representing the Annonceur type in your schema. */
class Annonceur extends amplify_core.Model {
  static const classType = const _AnnonceurModelType();
  final String id;
  final String? _owner;
  final String? _nom;
  final String? _email;
  final String? _telephone;
  final String? _domaineActivite;
  final String? _adresse;
  final String? _logoUrl;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  AnnonceurModelIdentifier get modelIdentifier {
      return AnnonceurModelIdentifier(
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
  
  String get domaineActivite {
    try {
      return _domaineActivite!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get adresse {
    try {
      return _adresse!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get logoUrl {
    try {
      return _logoUrl!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Annonceur._internal({required this.id, owner, required nom, required email, required telephone, required domaineActivite, required adresse, required logoUrl, createdAt, updatedAt}): _owner = owner, _nom = nom, _email = email, _telephone = telephone, _domaineActivite = domaineActivite, _adresse = adresse, _logoUrl = logoUrl, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Annonceur({String? id, String? owner, required String nom, required String email, required String telephone, required String domaineActivite, required String adresse, required String logoUrl, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Annonceur._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      owner: owner,
      nom: nom,
      email: email,
      telephone: telephone,
      domaineActivite: domaineActivite,
      adresse: adresse,
      logoUrl: logoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Annonceur &&
      id == other.id &&
      _owner == other._owner &&
      _nom == other._nom &&
      _email == other._email &&
      _telephone == other._telephone &&
      _domaineActivite == other._domaineActivite &&
      _adresse == other._adresse &&
      _logoUrl == other._logoUrl &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Annonceur {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("owner=" + "$_owner" + ", ");
    buffer.write("nom=" + "$_nom" + ", ");
    buffer.write("email=" + "$_email" + ", ");
    buffer.write("telephone=" + "$_telephone" + ", ");
    buffer.write("domaineActivite=" + "$_domaineActivite" + ", ");
    buffer.write("adresse=" + "$_adresse" + ", ");
    buffer.write("logoUrl=" + "$_logoUrl" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Annonceur copyWith({String? owner, String? nom, String? email, String? telephone, String? domaineActivite, String? adresse, String? logoUrl, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Annonceur._internal(
      id: id,
      owner: owner ?? this.owner,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      domaineActivite: domaineActivite ?? this.domaineActivite,
      adresse: adresse ?? this.adresse,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  Annonceur copyWithModelFieldValues({
    ModelFieldValue<String?>? owner,
    ModelFieldValue<String>? nom,
    ModelFieldValue<String>? email,
    ModelFieldValue<String>? telephone,
    ModelFieldValue<String>? domaineActivite,
    ModelFieldValue<String>? adresse,
    ModelFieldValue<String>? logoUrl,
    ModelFieldValue<amplify_core.TemporalDateTime?>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime?>? updatedAt
  }) {
    return Annonceur._internal(
      id: id,
      owner: owner == null ? this.owner : owner.value,
      nom: nom == null ? this.nom : nom.value,
      email: email == null ? this.email : email.value,
      telephone: telephone == null ? this.telephone : telephone.value,
      domaineActivite: domaineActivite == null ? this.domaineActivite : domaineActivite.value,
      adresse: adresse == null ? this.adresse : adresse.value,
      logoUrl: logoUrl == null ? this.logoUrl : logoUrl.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  Annonceur.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _owner = json['owner'],
      _nom = json['nom'],
      _email = json['email'],
      _telephone = json['telephone'],
      _domaineActivite = json['domaineActivite'],
      _adresse = json['adresse'],
      _logoUrl = json['logoUrl'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'owner': _owner, 'nom': _nom, 'email': _email, 'telephone': _telephone, 'domaineActivite': _domaineActivite, 'adresse': _adresse, 'logoUrl': _logoUrl, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'owner': _owner,
    'nom': _nom,
    'email': _email,
    'telephone': _telephone,
    'domaineActivite': _domaineActivite,
    'adresse': _adresse,
    'logoUrl': _logoUrl,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<AnnonceurModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<AnnonceurModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final OWNER = amplify_core.QueryField(fieldName: "owner");
  static final NOM = amplify_core.QueryField(fieldName: "nom");
  static final EMAIL = amplify_core.QueryField(fieldName: "email");
  static final TELEPHONE = amplify_core.QueryField(fieldName: "telephone");
  static final DOMAINEACTIVITE = amplify_core.QueryField(fieldName: "domaineActivite");
  static final ADRESSE = amplify_core.QueryField(fieldName: "adresse");
  static final LOGOURL = amplify_core.QueryField(fieldName: "logoUrl");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Annonceur";
    modelSchemaDefinition.pluralName = "Annonceurs";
    
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
          amplify_core.ModelOperation.CREATE
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Annonceur.OWNER,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Annonceur.NOM,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Annonceur.EMAIL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Annonceur.TELEPHONE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Annonceur.DOMAINEACTIVITE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Annonceur.ADRESSE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Annonceur.LOGOURL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Annonceur.CREATEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Annonceur.UPDATEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _AnnonceurModelType extends amplify_core.ModelType<Annonceur> {
  const _AnnonceurModelType();
  
  @override
  Annonceur fromJson(Map<String, dynamic> jsonData) {
    return Annonceur.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Annonceur';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Annonceur] in your schema.
 */
class AnnonceurModelIdentifier implements amplify_core.ModelIdentifier<Annonceur> {
  final String id;

  /** Create an instance of AnnonceurModelIdentifier using [id] the primary key. */
  const AnnonceurModelIdentifier({
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
  String toString() => 'AnnonceurModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is AnnonceurModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}