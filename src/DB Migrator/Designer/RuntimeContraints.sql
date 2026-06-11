CREATE INDEX "IX_TemplateMap_ApplicationVersionId_TemplateId"
    ON "DashboardRuntime"."TemplateMap" ("ApplicationVersionId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ResourceId_ResourceStatusLastModified_IncludeAll"
    ON "DashboardRuntime"."TemplateMap" ("ResourceId", "ResourceStatus_LastModified")
    INCLUDE ("ApplicationVersionId", "ChangesetId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ApplicationVersionId_TemplateId"
    ON "EndpointRuntime"."TemplateMap" ("ApplicationVersionId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ResourceId_ResourceStatusLastModified_IncludeAll"
    ON "EndpointRuntime"."TemplateMap" ("ResourceId", "ResourceStatus_LastModified")
    INCLUDE ("ApplicationVersionId", "ChangesetId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ApplicationVersionId_TemplateId"
    ON "FixedWidthMappingRuntime"."TemplateMap" ("ApplicationVersionId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ResourceId_ResourceStatusLastModified_IncludeAll"
    ON "FixedWidthMappingRuntime"."TemplateMap" ("ResourceId", "ResourceStatus_LastModified")
    INCLUDE ("ApplicationVersionId", "ChangesetId", "TemplateId");

CREATE INDEX "IX_FormElementTemplate_Discriminator_RootId"
    ON "FormRuntime"."FormElementTemplate" ("Discriminator", "RootId")
    INCLUDE ("ContainerId", "Content", "DisabledExpression", "FormTemplateId", "HiddenExpression", "Id", "InputFieldId", "Name", "Order");

CREATE INDEX "IX_FormElementTemplateId"
    ON "FormRuntime"."FormElementValidationTemplate" ("FormElementTemplateId");

CREATE INDEX "FormParameterTemplate_FormTemplateId"
    ON "FormRuntime"."FormParameterTemplate" ("FormTemplateId")
    INCLUDE ("FormParameterId", "Name", "Type");

CREATE INDEX "IX_OptionTemplate_InputFieldTemplateId_RootId"
    ON "FormRuntime"."OptionTemplate" ("InputFieldTemplateId", "RootId")
    INCLUDE ("Id", "OptionId", "Order", "Text", "Value");

CREATE INDEX "OptionTemplate_RootId"
    ON "FormRuntime"."OptionTemplate" ("RootId");

CREATE INDEX "IX_TemplateMap_ApplicationVersionId_TemplateId"
    ON "FormRuntime"."TemplateMap" ("ApplicationVersionId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ResourceId_ResourceStatusLastModified_IncludeAll"
    ON "FormRuntime"."TemplateMap" ("ResourceId", "ResourceStatus_LastModified")
    INCLUDE ("ApplicationVersionId", "ChangesetId", "TemplateId");

CREATE INDEX "IX_TextVariation_RootID"
    ON "FormRuntime"."TextVariationTemplate" ("RootId");

CREATE INDEX "IX_TextVariationTemplate_ElementId_RootId"
    ON "FormRuntime"."TextVariationTemplate" ("ElementId", "RootId")
    INCLUDE ("ExpressionText", "Id", "TextVariant");

CREATE INDEX "IX_TemplateMap_ApplicationVersionId_TemplateId"
    ON "FtniConnectorRuntime"."TemplateMap" ("ApplicationVersionId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ResourceId_ResourceStatusLastModified_IncludeAll"
    ON "FtniConnectorRuntime"."TemplateMap" ("ResourceId", "ResourceStatus_LastModified")
    INCLUDE ("ApplicationVersionId", "ChangesetId", "TemplateId");

--CREATE TABLE "HipchatConnectorsRuntime"."DatabaseVersion" (
--    "Id" UUID DEFAULT gen_random_uuid(),
--    "Version" BIGINT,
--    CONSTRAINT "PK_HipchatConnectorsRuntime_DatabaseVersion" PRIMARY KEY ("Id")
--);

CREATE INDEX "IX_TemplateMap_ApplicationVersionId_TemplateId"
    ON "JSRuleRuntime"."TemplateMap" ("ApplicationVersionId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ResourceId_ResourceStatusLastModified_IncludeAll"
    ON "JSRuleRuntime"."TemplateMap" ("ResourceId", "ResourceStatus_LastModified")
    INCLUDE ("ApplicationVersionId", "ChangesetId", "TemplateId");

CREATE INDEX "IX_RuntimeMap_VersionId"
    ON "MappingRuntime"."RuntimeMap" ("VersionId");

CREATE INDEX "IX_RuntimeMapId"
    ON "MappingRuntime"."FieldMap" ("RuntimeMapId")
    INCLUDE ("CallerFieldId", "ActionFieldId", "Direction");

CREATE INDEX "IX_TemplateMap_ApplicationVersionId_TemplateId"
    ON "MappingRuntime"."TemplateMap" ("ApplicationVersionId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ResourceId_ResourceStatusLastModified_IncludeAll"
    ON "MappingRuntime"."TemplateMap" ("ResourceId", "ResourceStatus_LastModified")
    INCLUDE ("ApplicationVersionId", "ChangesetId", "TemplateId");

CREATE INDEX "IX_EnvironmentId_TypeId_IncludeXmlData"
    ON "ModelRuntime"."ModelInstance" ("EnvironmentId", "TypeId")
    INCLUDE ("XmlData");

CREATE INDEX "IX_ModelInstance_EnvironmentId_Index"
    ON "ModelRuntime"."ModelInstance" ("Id", "EnvironmentId");

CREATE INDEX "IX_TypeId_EnvironmentId"
    ON "ModelRuntime"."ModelInstance" ("EnvironmentId", "TypeId");

CREATE INDEX "IX_TemplateMap_ApplicationVersionId_TemplateId"
    ON "ModelRuntime"."TemplateMap" ("ApplicationVersionId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ResourceId_ResourceStatusLastModified_IncludeAll"
    ON "ModelRuntime"."TemplateMap" ("ResourceId", "ResourceStatus_LastModified")  
    INCLUDE ("ApplicationVersionId", "ChangesetId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ApplicationVersionId_TemplateId"
    ON "PdfMappingRuntime"."TemplateMap" ("ApplicationVersionId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ResourceId_ResourceStatusLastModified_IncludeAll"
    ON "PdfMappingRuntime"."TemplateMap" ("ResourceId", "ResourceStatus_LastModified")
    INCLUDE ("ApplicationVersionId", "ChangesetId", "TemplateId");

CREATE UNIQUE INDEX "IX_EnvironmentVariableValue_EnvironmentId_EnvironmentVariableId"
    ON "Platform"."EnvironmentVariableValue" ("EnvironmentId", "EnvironmentVariableId");

CREATE INDEX "IX_ActionInstanceInfo_ProcessInstanceId"
    ON "ProcessRuntime"."ActionInstanceInfo" ("ProcessInstanceId");

CREATE INDEX "ActivityTemplate_ProcessTemplate_Discriminator"
    ON "ProcessRuntime"."ActivityTemplate" ("ProcessTemplateId", "Discriminator")
    INCLUDE ("ActivityId", "DefaultNextActivityId", "Expression", "FalseActivityId", "Id", "MapId", "NextTemplateId", "TrueActivityId");

CREATE INDEX "IX_ActivityTemplateId"
    ON "ProcessRuntime"."DecisionBranch" ("ActivityTemplateId");

CREATE INDEX "IX_ProcessInstanceId"
    ON "ProcessRuntime"."NavigationState" ("ProcessInstanceId");

CREATE INDEX "ProcessCurrentActivitiesPath_ProcessInstanceId"
    ON "ProcessRuntime"."ProcessCurrentActivitiesPath" ("ProcessInstanceId");

CREATE INDEX "ProcessEndpoint_Path_Index"
    ON "ProcessRuntime"."ProcessEndpoint" ("Path");

CREATE INDEX "ProcessEndpoint_ProcessTemplateId_Index"
    ON "ProcessRuntime"."ProcessEndpoint" ("ProcessTemplateId");

CREATE INDEX "ProcessFieldTemplate_ProcessTemplateId"
    ON "ProcessRuntime"."ProcessFieldTemplate" ("ProcessTemplateId");

CREATE INDEX "ProcessInstance_CallerInfo_SessionId"
    ON "ProcessRuntime"."ProcessInstance" ("CallerInfo_SessionId");

CREATE INDEX "IX_ProcessRole_ProcessInstanceId"
    ON "ProcessRuntime"."ProcessRole" ("ProcessInstanceId");

CREATE INDEX "ProcessTemplate_VersionId_Index"
    ON "ProcessRuntime"."ProcessTemplate" ("VersionId");

CREATE INDEX "IX_TemplateMap_ApplicationVersionId_TemplateId"
    ON "ProcessRuntime"."TemplateMap" ("ApplicationVersionId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ResourceId_ResourceStatusLastModified_IncludeAll"
    ON "ProcessRuntime"."TemplateMap" ("ResourceId", "ResourceStatus_LastModified")
    INCLUDE ("ApplicationVersionId", "ChangesetId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ApplicationVersionId_TemplateId"
    ON "QueryingRuntime"."TemplateMap" ("ApplicationVersionId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ResourceId_ResourceStatusLastModified_IncludeAll"
    ON "QueryingRuntime"."TemplateMap" ("ResourceId", "ResourceStatus_LastModified")
    INCLUDE ("ApplicationVersionId", "ChangesetId", "TemplateId");

CREATE INDEX "ParameterTemplate_RuleTemplateId"
    ON "RuleRuntime"."ParameterTemplate" ("RuleTemplateId")
    INCLUDE ("CSharpType", "Direction", "Id", "IsArray", "Name", "ParameterId", "Type");

CREATE INDEX "IX_TemplateMap_ApplicationVersionId_TemplateId"
    ON "RuleRuntime"."TemplateMap" ("ApplicationVersionId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ResourceId_ResourceStatusLastModified_IncludeAll"
    ON "RuleRuntime"."TemplateMap" ("ResourceId", "ResourceStatus_LastModified")
    INCLUDE ("ApplicationVersionId", "ChangesetId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ApplicationVersionId_TemplateId"
    ON "SmartyStreetsConnectorRuntime"."TemplateMap" ("ApplicationVersionId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ResourceId_ResourceStatusLastModified_IncludeAll"
    ON "SmartyStreetsConnectorRuntime"."TemplateMap" ("ResourceId", "ResourceStatus_LastModified")
    INCLUDE ("ApplicationVersionId", "ChangesetId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ApplicationVersionId_TemplateId"
    ON "TableRuleRuntime"."TemplateMap" ("ApplicationVersionId", "TemplateId");

CREATE INDEX "IX_TemplateMap_ResourceId_ResourceStatusLastModified_IncludeAll"
    ON "TableRuleRuntime"."TemplateMap" ("ResourceId", "ResourceStatus_LastModified")
    INCLUDE ("ApplicationVersionId", "ChangesetId", "TemplateId");

-- EndpointRuntime
ALTER TABLE "EndpointRuntime"."EndpointRole"
ADD CONSTRAINT "FK_EndpointRole_EndpointTemplate"
FOREIGN KEY ("EndpointTemplateId")
REFERENCES "EndpointRuntime"."EndpointTemplate" ("Id")
ON DELETE CASCADE;

-- FileTransferConnectorRuntime
ALTER TABLE "FileTransferConnectorRuntime"."FileTransferConnectorParameterTemplate"
ADD CONSTRAINT "FK_FTConnectorParameterTemplate_FTConnectorTemplate"
FOREIGN KEY ("FileTransferConnectorTemplateId")
REFERENCES "FileTransferConnectorRuntime"."FileTransferConnectorTemplate" ("Id")
ON DELETE CASCADE;

-- FixedWidthMappingRuntime
ALTER TABLE "FixedWidthMappingRuntime"."FixedWidthFieldTemplate"
ADD CONSTRAINT "FK_FixedWidthFieldTemplate_FixedWidthMapTemplate"
FOREIGN KEY ("FixedWidthMapTemplateId")
REFERENCES "FixedWidthMappingRuntime"."FixedWidthMapTemplate" ("Id")
ON DELETE CASCADE;

ALTER TABLE "FixedWidthMappingRuntime"."FixedWidthParameterTemplate"
ADD CONSTRAINT "FK_FixedWidthParameterTemplate_FixedWidthMapTemplate"
FOREIGN KEY ("FixedWidthMapTemplateId")
REFERENCES "FixedWidthMappingRuntime"."FixedWidthMapTemplate" ("Id")
ON DELETE CASCADE;

-- FormRuntime
ALTER TABLE "FormRuntime"."ColumnTemplate"
ADD CONSTRAINT "FK_Column_FormElementTemplate"
FOREIGN KEY ("TableTemplateId")
REFERENCES "FormRuntime"."FormElementTemplate" ("Id");

ALTER TABLE "FormRuntime"."FormElementTemplate"
ADD CONSTRAINT "FK_FormElement_Container"
FOREIGN KEY ("ContainerId")
REFERENCES "FormRuntime"."FormElementTemplate" ("Id");

ALTER TABLE "FormRuntime"."FormElementTemplate"
ADD CONSTRAINT "FK_FormElementTemplate_FormTemplate"
FOREIGN KEY ("RootId")
REFERENCES "FormRuntime"."FormTemplate" ("Id");

ALTER TABLE "FormRuntime"."FormElementTemplate"
ADD CONSTRAINT "FK_InputFieldTemplate_FormTemplate"
FOREIGN KEY ("FormTemplateId")
REFERENCES "FormRuntime"."FormTemplate" ("Id");

ALTER TABLE "FormRuntime"."FormElementValidationTemplate"
ADD CONSTRAINT "FK_FormElementValidationTemplate_FormElementTemplate"
FOREIGN KEY ("FormElementTemplateId")
REFERENCES "FormRuntime"."FormElementTemplate" ("Id");

ALTER TABLE "FormRuntime"."FormParameterTemplate"
ADD CONSTRAINT "FK_FormParameterTemplate_FormTemplate"
FOREIGN KEY ("FormTemplateId")
REFERENCES "FormRuntime"."FormTemplate" ("Id")
ON DELETE CASCADE;

ALTER TABLE "FormRuntime"."HelperItemTemplate"
ADD CONSTRAINT "FK_HelperItemTemplate_HelperFieldTemplate"
FOREIGN KEY ("HelperFieldTemplateId")
REFERENCES "FormRuntime"."FormElementTemplate" ("Id")
ON DELETE CASCADE;

ALTER TABLE "FormRuntime"."OptionTemplate"
ADD CONSTRAINT "FK_OptionTemplate_InputFieldTemplate"
FOREIGN KEY ("InputFieldTemplateId")
REFERENCES "FormRuntime"."FormElementTemplate" ("Id")
ON DELETE CASCADE;

ALTER TABLE "FormRuntime"."TableParameterTemplate"
ADD CONSTRAINT "FK_TableParameterTemplate_FormElementTemplate"
FOREIGN KEY ("TableTemplateId")
REFERENCES "FormRuntime"."FormElementTemplate" ("Id");

ALTER TABLE "FormRuntime"."TextVariationTemplate"
ADD CONSTRAINT "FK_TextVariation_FormElement"
FOREIGN KEY ("ElementId")
REFERENCES "FormRuntime"."FormElementTemplate" ("Id")
ON DELETE CASCADE;

ALTER TABLE "FormRuntime"."TextVariationTemplate"
ADD CONSTRAINT "FK_TextVariation_FormTemplate"
FOREIGN KEY ("RootId")
REFERENCES "FormRuntime"."FormTemplate" ("Id")
ON DELETE CASCADE;

-- FtniConnectorRuntime
ALTER TABLE "FtniConnectorRuntime"."ErrorTranslationTemplate"
ADD CONSTRAINT "FK_ErrorTranslationTemplate_FtniConnectorTemplate"
FOREIGN KEY ("ConnectorId")
REFERENCES "FtniConnectorRuntime"."FtniConnectorTemplate" ("Id")
ON DELETE CASCADE;

-- HttpConnectorRuntime
ALTER TABLE "HttpConnectorRuntime"."AuthenticationProviderTemplate"
ADD CONSTRAINT "FK_AuthProviderTemplate_HttpConnectorTemplate"
FOREIGN KEY ("HttpConnectorId")
REFERENCES "HttpConnectorRuntime"."HttpConnectorTemplate" ("Id");

ALTER TABLE "HttpConnectorRuntime"."CustomHttpHeader"
ADD CONSTRAINT "FK_CustomHttpHeaderKey_HttpConnectorTemplate"
FOREIGN KEY ("HttpConnectorId")
REFERENCES "HttpConnectorRuntime"."HttpConnectorTemplate" ("Id");

ALTER TABLE "HttpConnectorRuntime"."HttpParameterKey"
ADD CONSTRAINT "FK_HttpParameterKey_HttpConnectorTemplate"
FOREIGN KEY ("HttpConnectorId")
REFERENCES "HttpConnectorRuntime"."HttpConnectorTemplate" ("Id");

-- JSRuleRuntime
ALTER TABLE "JSRuleRuntime"."ParameterTemplate"
ADD CONSTRAINT "FK_JSParameterTemplate_RuleTemplate"
FOREIGN KEY ("RuleTemplateId")
REFERENCES "JSRuleRuntime"."RuleTemplate" ("Id");

-- MappingRuntime
ALTER TABLE "MappingRuntime"."FieldMap"
ADD CONSTRAINT "FK_FieldMap_RuntimeMap"
FOREIGN KEY ("RuntimeMapId")
REFERENCES "MappingRuntime"."RuntimeMap" ("Id");

-- PdfMappingRuntime
ALTER TABLE "PdfMappingRuntime"."PdfParameterTemplate"
ADD CONSTRAINT "FK_PdfParameterTemplate_PdfFileMapTemplate"
FOREIGN KEY ("PdfFileMapTemplateId")
REFERENCES "PdfMappingRuntime"."PdfFileMapTemplate" ("Id")
ON DELETE CASCADE;

-- Platform
ALTER TABLE "Platform"."ApplicationVersion"
ADD CONSTRAINT "FK_ApplicationVersion_ApplicationVersion"
FOREIGN KEY ("SourceVersionId")
REFERENCES "Platform"."ApplicationVersion" ("Id");

ALTER TABLE "Platform"."ApplicationRoleByVersion"
ADD CONSTRAINT "FK_ApplicationRoleByVersion_ApplicationVersion"
FOREIGN KEY ("VersionId")
REFERENCES "Platform"."ApplicationVersion" ("Id");

ALTER TABLE "Platform"."EnvironmentApplicationRoleMap"
ADD CONSTRAINT "FK_EnvironmentApplicationRoleMap_Environment"
FOREIGN KEY ("EnvironmentId")
REFERENCES "Platform"."Environment" ("Id")
ON DELETE CASCADE;

ALTER TABLE "Platform"."EnvironmentDeployment"
ADD CONSTRAINT "FK_EnvironmentDeployment_Environment"
FOREIGN KEY ("EnvironmentId")
REFERENCES "Platform"."Environment" ("Id");

ALTER TABLE "Platform"."EnvironmentDeployment"
ADD CONSTRAINT "FK_EnvironmentDeployment_Version"
FOREIGN KEY ("VersionId")
REFERENCES "Platform"."ApplicationVersion" ("Id");

ALTER TABLE "Platform"."EnvironmentNotification"
ADD CONSTRAINT "FK_EnvironmentNotification_Environment"
FOREIGN KEY ("EnvironmentId")
REFERENCES "Platform"."Environment" ("Id");

ALTER TABLE "Platform"."EnvironmentNotificationCustomHttpHeader"
ADD CONSTRAINT "FK_EnvNotificationCustomHttpHeader_EnvNotification"
FOREIGN KEY ("EnvironmentNotificationId")
REFERENCES "Platform"."EnvironmentNotification" ("Id");

ALTER TABLE "Platform"."EnvironmentOrigin"
ADD CONSTRAINT "FK_EnvironmentOrigin_EnvironmentVariable"
FOREIGN KEY ("EnvironmentId")
REFERENCES "Platform"."Environment" ("Id")
ON DELETE CASCADE;

ALTER TABLE "Platform"."EnvironmentRoleMap"
ADD CONSTRAINT "FK_EnvironmentRoleMap_Environment"
FOREIGN KEY ("EnvironmentId")
REFERENCES "Platform"."Environment" ("Id")
ON DELETE CASCADE;

ALTER TABLE "Platform"."EnvironmentVariableByVersion"
ADD CONSTRAINT "FK_EnvironmentVariableByVersion_ApplicationVersion"
FOREIGN KEY ("VersionId")
REFERENCES "Platform"."ApplicationVersion" ("Id");

ALTER TABLE "Platform"."EnvironmentVariableValue"
ADD CONSTRAINT "FK_EnvironmentVariableValue_EnvironmentVariable"
FOREIGN KEY ("EnvironmentVariableId")
REFERENCES "Platform"."EnvironmentVariableDefinition" ("Id")
ON DELETE CASCADE;

-- ProcessRuntime
ALTER TABLE "ProcessRuntime"."ProcessInstance"
ADD CONSTRAINT "FK_ProcessContext_ProcessTemplate"
FOREIGN KEY ("TemplateId")
REFERENCES "ProcessRuntime"."ProcessTemplate" ("Id");

ALTER TABLE "ProcessRuntime"."ActivityTemplate"
ADD CONSTRAINT "FK_ActivityTemplate_ProcessTemplate"
FOREIGN KEY ("ProcessTemplateId")
REFERENCES "ProcessRuntime"."ProcessTemplate" ("Id");

ALTER TABLE "ProcessRuntime"."ActionInstanceInfo"
ADD CONSTRAINT "FK_ActionInstanceInfo_ProcessInstance"
FOREIGN KEY ("ProcessInstanceId")
REFERENCES "ProcessRuntime"."ProcessInstance" ("Id")
ON DELETE CASCADE;

ALTER TABLE "ProcessRuntime"."AuthenticationProcessRelation"
ADD CONSTRAINT "FK_AuthenticationProcessRelation_ProcessInstance"
FOREIGN KEY ("UnAuthenticatedProcessId")
REFERENCES "ProcessRuntime"."ProcessInstance" ("Id")
ON DELETE CASCADE;

ALTER TABLE "ProcessRuntime"."DecisionBranch"
ADD CONSTRAINT "FK_DecisionBranch_ActivityTemplate"
FOREIGN KEY ("ActivityTemplateId")
REFERENCES "ProcessRuntime"."ActivityTemplate" ("Id");

ALTER TABLE "ProcessRuntime"."NavigationNode"
ADD CONSTRAINT "FK_NavigationNode_ProcessTemplate"
FOREIGN KEY ("ProcessTemplateId")
REFERENCES "ProcessRuntime"."ProcessTemplate" ("Id")
ON DELETE CASCADE;

ALTER TABLE "ProcessRuntime"."NavigationState"
ADD CONSTRAINT "FK_NavigationState_NavigationNode"
FOREIGN KEY ("NavigationNodeId")
REFERENCES "ProcessRuntime"."NavigationNode" ("Id")
ON DELETE CASCADE;

ALTER TABLE "ProcessRuntime"."NavigationState"
ADD CONSTRAINT "FK_NavigationState_ProcessInstance"
FOREIGN KEY ("ProcessInstanceId")
REFERENCES "ProcessRuntime"."ProcessInstance" ("Id")
ON DELETE CASCADE;

ALTER TABLE "ProcessRuntime"."NotifiableField"
ADD CONSTRAINT "FK_NotifiableField_ActivityTemplate"
FOREIGN KEY ("ActivityTemplateId")
REFERENCES "ProcessRuntime"."ActivityTemplate" ("Id");

ALTER TABLE "ProcessRuntime"."ProcessCurrentActivitiesPath"
ADD CONSTRAINT "FK_ProcessCurrentActivitiesPath_ProcessInstance"
FOREIGN KEY ("ProcessInstanceId")
REFERENCES "ProcessRuntime"."ProcessInstance" ("Id")
ON DELETE CASCADE;

ALTER TABLE "ProcessRuntime"."ProcessEndpoint"
ADD CONSTRAINT "FK_ProcessEndpoint_ProcessTemplate"
FOREIGN KEY ("ProcessTemplateId")
REFERENCES "ProcessRuntime"."ProcessTemplate" ("Id");

ALTER TABLE "ProcessRuntime"."ProcessFieldTemplate"
ADD CONSTRAINT "FK_ProcessFieldTemplate_ProcessTemplate"
FOREIGN KEY ("ProcessTemplateId")
REFERENCES "ProcessRuntime"."ProcessTemplate" ("Id");

ALTER TABLE "ProcessRuntime"."ProcessRole"
ADD CONSTRAINT "FK_ProcessRole_ProcessInstance"
FOREIGN KEY ("ProcessInstanceId")
REFERENCES "ProcessRuntime"."ProcessInstance" ("Id")
ON DELETE CASCADE;

ALTER TABLE "ProcessRuntime"."SetField"
ADD CONSTRAINT "FK_SetFieldValueActivity_ActivityTemplate"
FOREIGN KEY ("ActivityTemplateId")
REFERENCES "ProcessRuntime"."ActivityTemplate" ("Id");

-- RuleRuntime
ALTER TABLE "RuleRuntime"."ParameterTemplate"
ADD CONSTRAINT "FK_ParameterTemplate_RuleTemplate"
FOREIGN KEY ("RuleTemplateId")
REFERENCES "RuleRuntime"."RuleTemplate" ("Id");

