CREATE SCHEMA "AzureServiceBusConnectorRuntime";
CREATE SCHEMA "DashboardRuntime";
CREATE SCHEMA "EmailConnectorRuntime";
CREATE SCHEMA "EndpointRuntime";
CREATE SCHEMA "FileTransferConnectorRuntime";
CREATE SCHEMA "FixedWidthMappingRuntime";
CREATE SCHEMA "FormRuntime";
CREATE SCHEMA "FtniConnectorRuntime";
CREATE SCHEMA "HipchatConnectorsRuntime";
CREATE SCHEMA "HttpConnectorRuntime";
CREATE SCHEMA "JSRuleRuntime";
CREATE SCHEMA "MappingRuntime";
CREATE SCHEMA "ModelRuntime";
CREATE SCHEMA "PdfMappingRuntime";
CREATE SCHEMA "Platform";
CREATE SCHEMA "ProcessRuntime";
CREATE SCHEMA "QueryingRuntime";
CREATE SCHEMA "RuleRuntime";
CREATE SCHEMA "SmartyStreetsConnectorRuntime";
CREATE SCHEMA "TableRuleRuntime";

CREATE TABLE "AzureServiceBusConnectorRuntime"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    CONSTRAINT "PK_AzureServiceBusConnectorRuntime_DatabaseVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "AzureServiceBusConnectorRuntime"."AzureServiceBusConnectorTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "VersionId" UUID,
    "ResourceTypeId" UUID,
    "DateTime" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "ConnectionString" TEXT,
    "ResourceName" VARCHAR(255),
    "SerializedInputSchema" TEXT,
    "SerializedOutputSchema" TEXT,
    "SerializerType" INTEGER NOT NULL DEFAULT 1,
    "ContentType" VARCHAR(255),
    CONSTRAINT "PK_AzureServiceBusConnectorTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "AzureServiceBusConnectorRuntime"."FailedAzureServiceBusMessage" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "EnvironmentId" UUID NOT NULL,
    "CorrelationId" VARCHAR(255) NOT NULL,
    "Message" TEXT NOT NULL,
    "ConnectionString" TEXT NOT NULL,
    "ResourceName" VARCHAR(255) NOT NULL,
    "SerializerType" INTEGER NOT NULL,
    "ContentType" VARCHAR(255) NOT NULL,
    "Exception" TEXT NOT NULL,
    "Timestamp" TIMESTAMPTZ NOT NULL,
    CONSTRAINT "PK_FailedAzureServiceBusMessage" PRIMARY KEY ("Id")
);

CREATE TABLE "AzureServiceBusConnectorRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_AzureServiceBusConnectorsTemplateMap" PRIMARY KEY ("Id")
);

CREATE TABLE "DashboardRuntime"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    CONSTRAINT "PK_DashboardRuntime_DatabaseVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "DashboardRuntime"."File" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ResourceTypeId" UUID NOT NULL,
    "VersionId" UUID,
    "Path" VARCHAR(255),
    "Content" TEXT,
    CONSTRAINT "PK_File" PRIMARY KEY ("Id")
);

CREATE TABLE "DashboardRuntime"."FileRole" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "VersionId" UUID,
    "ApplicationRoleId" UUID NOT NULL,
    CONSTRAINT "PK_FileRole" PRIMARY KEY ("Id")
);

CREATE TABLE "DashboardRuntime"."RuntimeForm" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ActionId" UUID NOT NULL,
    "VersionId" UUID,
    "ClientCallback" VARCHAR(255),
    "EnvironmentId" UUID NOT NULL,
    "CallReferenceId" UUID NOT NULL,
    "MapId" UUID NOT NULL,
    "OwnerId" UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    CONSTRAINT "PK_RuntimeForm" PRIMARY KEY ("Id")
);

CREATE TABLE "DashboardRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_TemplateMap" PRIMARY KEY ("Id")
);

CREATE TABLE "EmailConnectorRuntime"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    CONSTRAINT "PK_EmailConnectorRuntime_DatabaseVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "EmailConnectorRuntime"."EmailConnectorTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "VersionId" UUID,
    "ResourceTypeId" UUID,
    "DateTime" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "SerializedInputSchema" TEXT,
    "SerializedOutputSchema" TEXT,
    "To" TEXT,
    "Subject" TEXT,
    "BodyMessage" TEXT,
    "SenderName" TEXT,
    "ReplyTo" TEXT,
    CONSTRAINT "PK_EmailConnectorTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "EmailConnectorRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_EmailConnectorsTemplateMap" PRIMARY KEY ("Id")
);

CREATE TABLE "EndpointRuntime"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    CONSTRAINT "PK_EndpointRuntime_DatabaseVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "EndpointRuntime"."EndpointTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "OutputSettings_ContentType" VARCHAR(255),
    "Name" VARCHAR(255) NOT NULL,
    "Path" VARCHAR(255) NOT NULL,
    "InputSettings_Method" VARCHAR(255) NOT NULL,
    "ActionId" UUID NOT NULL,
    "OwnerActionId" UUID NOT NULL,
    "MapId" UUID NOT NULL,
    "VersionId" UUID,
    "InputSettings_SerializedSchema" TEXT NOT NULL,
    "OutputSettings_SerializedSchema" TEXT NOT NULL,
    "OutputSettings_ReturnValueSettingId" UUID NOT NULL,
    "InputSettings_ReturnValueSettingId" UUID NOT NULL,
    "OutputSettings_IgnoreNullValues" BOOLEAN NOT NULL,
    "OutputSettings_IncludeTimeOnDateType" BOOLEAN NOT NULL,
    "IsDownload" BOOLEAN NOT NULL,
    CONSTRAINT "PK_EndpointTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "EndpointRuntime"."EndpointRole" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "EndpointTemplateId" UUID NOT NULL,
    "ApplicationRoleId" UUID NOT NULL,
    CONSTRAINT "PK_EndpointRole" PRIMARY KEY ("Id")
);

CREATE TABLE "EndpointRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_TemplateMap" PRIMARY KEY ("Id")
);

CREATE TABLE "FileTransferConnectorRuntime"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    CONSTRAINT "PK_FileTransferConnectorRuntime_DatabaseVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "FileTransferConnectorRuntime"."FileTransferConnectorTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "FileTransferConnectorId" UUID NOT NULL,
    "Name" VARCHAR(255),
    "UserName" VARCHAR(255),
    "Password" VARCHAR(255),
    "ServerAddress" VARCHAR(255),
    "ServerPort" TEXT,
    "FolderPath" TEXT,
    "UsePassive" BOOLEAN,
    "Type" INTEGER,
    "SerializedInputSchema" TEXT,
    "SerializedOutputSchema" TEXT,
    CONSTRAINT "PK_FileTransferConnectorTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "FileTransferConnectorRuntime"."FileTransferConnectorParameterTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "FileTransferConnectorParameterId" UUID NOT NULL,
    "Name" VARCHAR(255),
    "FileTransferConnectorTemplateId" UUID,
    "Type" INTEGER NOT NULL,
    "IsArray" BOOLEAN NOT NULL,
    CONSTRAINT "PK_FileTransferConnectorParameterTemplate" PRIMARY KEY ("Id")    
);

CREATE TABLE "FileTransferConnectorRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_FileTransferConnectorTemplateMap" PRIMARY KEY ("Id")
);

CREATE TABLE "FixedWidthMappingRuntime"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    CONSTRAINT "PK_FixedWidthMappingRuntime_DatabaseVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "FixedWidthMappingRuntime"."FixedWidthMapTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ActionId" UUID NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    "FileName" VARCHAR(255) NOT NULL,
    "ShowsColumnHeaders" BOOLEAN NOT NULL,
    "Separator" VARCHAR(255),
    "SerializedInputSchema" TEXT NOT NULL,
    CONSTRAINT "PK_FixedWidthMapTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "FixedWidthMappingRuntime"."FixedWidthFieldTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ActionId" UUID NOT NULL,
    "FixedWidthMapTemplateId" UUID,
    "Name" TEXT NOT NULL,
    "Type" INTEGER NOT NULL,
    "Width" INTEGER NOT NULL,
    "Order" BIGINT NOT NULL,
    "Format" VARCHAR(255),
    "IsFiller" BOOLEAN NOT NULL,
    CONSTRAINT "PK_FixedWidthFieldTemplate" PRIMARY KEY ("Id")   
);

CREATE TABLE "FixedWidthMappingRuntime"."FixedWidthParameterTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ActionId" UUID NOT NULL,
    "FixedWidthMapTemplateId" UUID,
    "Name" TEXT NOT NULL,
    CONSTRAINT "PK_FixedWidthParameterTemplate" PRIMARY KEY ("Id")    
);

CREATE TABLE "FixedWidthMappingRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_TemplateMap" PRIMARY KEY ("Id")
);

CREATE TABLE "FormRuntime"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    CONSTRAINT "PK_FormRuntime_DatabaseVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "FormRuntime"."FormTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ActionId" UUID NOT NULL,
    "VersionId" UUID,
    "Name" VARCHAR(255) NOT NULL,
    "Label" VARCHAR(255) NOT NULL,
    "IsLabelHidden" BOOLEAN NOT NULL DEFAULT FALSE,
    "SubmitTitle" VARCHAR(255),
    "ButtonWidth" VARCHAR(30) DEFAULT 'classic',
    "AllowSingleExpandedSection" BOOLEAN NOT NULL DEFAULT FALSE,
    "EnableAutoSubmitForSingleSelect" BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT "PK_FormTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "FormRuntime"."FormElementTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "InputFieldId" UUID NOT NULL,
    "Name" TEXT,
    "Order" BIGINT NOT NULL,
    "Discriminator" VARCHAR(255) NOT NULL,
    "FormTemplateId" UUID,
    "IsRequired" BOOLEAN,
    "InputFormat_MaxLength" INTEGER,
    "InputFormat_MinLength" INTEGER,
    "InputFormat_Max" INTEGER,
    "InputFormat_Min" INTEGER,
    "DisplayType" INTEGER,
    "ContainerId" UUID,
    "RootId" UUID NOT NULL,
    "HiddenExpression" TEXT,
    "DisabledExpression" TEXT,
    "Text" VARCHAR(255),
    "AreOptionsMappable" BOOLEAN DEFAULT FALSE,
    "TextId" UUID,
    "ValueId" UUID,
    "Pattern" TEXT,
    "Label" TEXT,
    "IsLabelHidden" BOOLEAN,
    "Content" TEXT,
    "MinRestriction_StaticDate" DATE,
    "MaxRestriction_StaticDate" DATE,
    "MaskOptions_ShowNone" BOOLEAN DEFAULT FALSE,
    "MaskOptions_NumberCharactersShownFromStart" INTEGER,
    "MaskOptions_NumberCharactersShownFromEnd" INTEGER,
    "IsArray" BOOLEAN,
    "ValidExpression" TEXT,
    "ValidExpressionErrorMessage" TEXT,
    "MinDateTime" TIMESTAMPTZ,
    "MaxDateTime" TIMESTAMPTZ,
    "PatternErrorMessage" TEXT,
    "SortType" INTEGER,
    "InputFormat_Type" INTEGER,
    "InputFormat_UseCountryCode" BOOLEAN DEFAULT FALSE,
    "AreColumnHeadersHidden" BOOLEAN,
    "ValueType" INTEGER,
    "DefaultValue" TEXT,
    "MaxRestriction_Years" INTEGER,
    "MaxRestriction_Months" INTEGER,
    "MaxRestriction_Days" INTEGER,
    "MaxRestriction_Type" INTEGER,
    "MinRestriction_Years" INTEGER,
    "MinRestriction_Months" INTEGER,
    "MinRestriction_Days" INTEGER,
    "MinRestriction_Type" INTEGER,
    "InputFormat_WhitespaceTrimming" INTEGER,
    "DateDisplayType" INTEGER,
    "StylingOptionValue" VARCHAR(25),
    "IsCollapsible" BOOLEAN,
    "CollapsibleGroupId" UUID,
    "AllowSingleExpandedSection" BOOLEAN,
    "ImageUri" TEXT,
    "ImageContent" BYTEA,
    "ImageFormat" VARCHAR(10),
    "IsInterceptable" BOOLEAN,
    "InterceptionDestinationField" VARCHAR(255),
    "IsSoftHideable" BOOLEAN NOT NULL,
    "UseIcon" BOOLEAN,
    "AllowOptionGroupElement" BOOLEAN,
    "GroupId" UUID,
    "MinNumberOfSelection" INTEGER,
    "MaxNumberOfSelection" INTEGER,
    "IsSensitive" BOOLEAN,
    CONSTRAINT "PK_InputFieldTemplate" PRIMARY KEY ("Id")    
);

CREATE TABLE "FormRuntime"."ColumnTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ColumnId" UUID NOT NULL,
    "RootId" UUID NOT NULL,
    "Name" VARCHAR(255),
    "TableTemplateId" UUID NOT NULL,
    "Type" INTEGER,
    "Order" BIGINT,
    "Visible" BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT "PK_FormColumn" PRIMARY KEY ("Id")
);

CREATE TABLE "FormRuntime"."FormElementValidationTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "FormElementTemplateId" UUID NOT NULL,
    "Expression" TEXT NOT NULL,
    "Message" VARCHAR(255) NOT NULL,
    "Type" SMALLINT NOT NULL,
    CONSTRAINT "PK_FormElementValidationTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "FormRuntime"."FormParameterTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "FormTemplateId" UUID NOT NULL,
    "FormParameterId" UUID NOT NULL,
    "Name" VARCHAR(255),
    "Type" INTEGER NOT NULL,
    CONSTRAINT "PK_ParameterTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "FormRuntime"."HelperItemTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "HelperItemId" UUID NOT NULL,
    "HelperFieldTemplateId" UUID NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    "Url" VARCHAR(255) NOT NULL,
    "Order" INTEGER,
    "RootId" UUID NOT NULL,
    CONSTRAINT "PK_HelperItemTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "FormRuntime"."OptionTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "OptionId" UUID NOT NULL,
    "InputFieldTemplateId" UUID NOT NULL,
    "Text" VARCHAR(255),
    "Value" VARCHAR(255) NOT NULL,
    "Order" INTEGER,
    "RootId" UUID NOT NULL,
    "HiddenExpression" TEXT,
    "Group" VARCHAR(255),
    CONSTRAINT "PK_OptionTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "FormRuntime"."TableParameterTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ParameterId" UUID NOT NULL,
    "RootId" UUID NOT NULL,
    "Name" VARCHAR(255),
    "TableTemplateId" UUID NOT NULL,
    "Type" INTEGER,
    CONSTRAINT "PK_TableParameterTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "FormRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_TemplateMap" PRIMARY KEY ("Id")
);

CREATE TABLE "FormRuntime"."TextVariationTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "RootId" UUID NOT NULL,
    "ElementId" UUID,
    "ExpressionText" TEXT NOT NULL,
    "TextVariant" TEXT NOT NULL,
    "ElementProperty" VARCHAR(512) NOT NULL,
    CONSTRAINT "PK_TextVariation" PRIMARY KEY ("Id")
);

CREATE TABLE "FormRuntime"."FormInstance" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ActionId" UUID NOT NULL,
    "VersionId" UUID,
    "EnvironmentId" UUID NOT NULL,
    "MapId" UUID NOT NULL,
    "XmlData" XML,
    "TypeId" UUID NOT NULL,
    "HasChanges" BOOLEAN NOT NULL,
    "JsonActiveData" TEXT,
    CONSTRAINT "PK_FormInstance" PRIMARY KEY ("Id")
);

CREATE TABLE "FtniConnectorRuntime"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    CONSTRAINT "PK_FtniConnectorRuntime_DatabaseVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "FtniConnectorRuntime"."FtniConnectorTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ActionId" UUID NOT NULL,
    "VersionId" UUID,
    "Name" VARCHAR(255),
    "Url" VARCHAR(1024),
    "Username" VARCHAR(255),
    "Password" VARCHAR(255),
    CONSTRAINT "PK_FtniConnectorTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "FtniConnectorRuntime"."ErrorTranslationTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ConnectorId" UUID NOT NULL,
    "Original" VARCHAR(512),
    "Translated" VARCHAR(512),
    CONSTRAINT "PK_ErrorTranslationTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "FtniConnectorRuntime"."FtniClientInfo" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "SessionId" UUID NOT NULL,
    "ClientId" VARCHAR(1024),
    CONSTRAINT "PK_FtniClientInfo" PRIMARY KEY ("Id")
);

CREATE TABLE "FtniConnectorRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_TemplateMap" PRIMARY KEY ("Id")
);

CREATE TABLE "HipchatConnectorsRuntime"."HipchatConnectorTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "VersionId" UUID,
    "ResourceTypeId" UUID,
    "DateTime" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "SerializedInputSchema" TEXT,
    "SerializedOutputSchema" TEXT,
    "RoomId" TEXT,
    "ApiKey" TEXT,
    "Message" TEXT,
    CONSTRAINT "PK_HipchatConnectorTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "HipchatConnectorsRuntime"."HipchatCreateUserConnectorTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "VersionId" UUID,
    "ResourceTypeId" UUID,
    "DateTime" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "SerializedInputSchema" TEXT,
    "SerializedOutputSchema" TEXT,
    "UserFullName" TEXT,
    "Email" TEXT,
    CONSTRAINT "PK_HipchatCreateUserConnectorTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "HipchatConnectorsRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_TemplateMap" PRIMARY KEY ("Id")
);

CREATE TABLE "HttpConnectorRuntime"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    CONSTRAINT "PK_HttpConnectorRuntime_DatabaseVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "HttpConnectorRuntime"."HttpConnectorTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "VersionId" UUID,
    "ResourceTypeId" UUID,
    "DateTime" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "Method" INTEGER NOT NULL,
    "CustomRequestContentType" VARCHAR(255),
    "Url" TEXT NOT NULL,
    "SerializedInputSchema" TEXT,
    "SerializedOutputSchema" TEXT,
    "RequestContentType" INTEGER NOT NULL,
    "UseStatusCodeForTimeout" BOOLEAN NOT NULL,
    "RetryStrategy_Retries" INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT "PK_HttpConnectorTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "HttpConnectorRuntime"."AuthenticationProviderTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "HttpConnectorId" UUID NOT NULL,
    "Key" VARCHAR(255),
    "Secret" TEXT,
    "Discriminator" VARCHAR(255) NOT NULL,
    "TenantId" VARCHAR(255),
    "ResourceId" VARCHAR(255),
    "ClientId" VARCHAR(255),
    "AppKey" VARCHAR(255),
    CONSTRAINT "PK_AuthenticationProviderTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "HttpConnectorRuntime"."CustomHttpHeader" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "HttpConnectorId" UUID NOT NULL,
    "Key" VARCHAR(255) NOT NULL,
    "Value" TEXT NOT NULL,
    CONSTRAINT "PK_CustomHttpHeader" PRIMARY KEY ("Id")
);

CREATE TABLE "HttpConnectorRuntime"."HttpParameterKey" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "HttpConnectorId" UUID NOT NULL,
    "Key" VARCHAR(255) NOT NULL,
    "ParameterId" UUID NOT NULL,
    CONSTRAINT "PK_HttpParameterKey" PRIMARY KEY ("Id")
);

CREATE TABLE "HttpConnectorRuntime"."DuplicateRequestStorage" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "InstanceId" UUID NOT NULL,
    "XmlData" XML NOT NULL,
    "CreatedEpoch" BIGINT NOT NULL,
    CONSTRAINT "PK_DuplicateRequestStorage" PRIMARY KEY ("Id")
);

CREATE TABLE "HttpConnectorRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_AzureServiceBusConnectorsTemplateMap" PRIMARY KEY ("Id")
);

CREATE TABLE "JSRuleRuntime"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    CONSTRAINT "PK_JSRuleRuntime_DatabaseVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "JSRuleRuntime"."RuleTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "VersionId" UUID,
    "ResourceTypeId" UUID NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    "Code" TEXT,
    CONSTRAINT "PK_JSRuleTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "JSRuleRuntime"."ParameterTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ParameterId" UUID NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    "Direction" INTEGER NOT NULL,
    "RuleTemplateId" UUID,
    "IsArray" BOOLEAN NOT NULL,
    "Type" INTEGER NOT NULL DEFAULT 3,
    CONSTRAINT "PK_JSParameterTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "JSRuleRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_TemplateMap" PRIMARY KEY ("Id")
);

CREATE TABLE "MappingRuntime"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    CONSTRAINT "PK_MappingRuntime_DatabaseVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "MappingRuntime"."ActionInfo" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ActionId" UUID NOT NULL,
    "VersionId" UUID,
    "Module" VARCHAR(255) NOT NULL,
    "SerializedOutputSchema" TEXT NOT NULL,
    "SerializedInputSchema" TEXT NOT NULL,
    "Name" VARCHAR(255) NOT NULL DEFAULT '' ,
    CONSTRAINT "PK_ActionInfo" PRIMARY KEY ("Id")
);

CREATE TABLE "MappingRuntime"."RuntimeMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "MapId" UUID NOT NULL,
    "VersionId" UUID,
    "CallerId" UUID NOT NULL,
    "ActionId" UUID NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    CONSTRAINT "PK_RuntimeMap" PRIMARY KEY ("Id")
);

CREATE TABLE "MappingRuntime"."FieldMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "RuntimeMapId" UUID NOT NULL,
    "CallerFieldId" UUID NOT NULL,
    "ActionFieldId" UUID NOT NULL,
    "Direction" INTEGER NOT NULL,
    CONSTRAINT "PK_FieldMap" PRIMARY KEY ("Id")
);

CREATE TABLE "MappingRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_TemplateMap" PRIMARY KEY ("Id")
);

CREATE TABLE "ModelRuntime"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    PRIMARY KEY ("Id")
);

CREATE TABLE "ModelRuntime"."ModelInstance" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "EnvironmentId" UUID NOT NULL,
    "VersionId" UUID,
    "TypeId" UUID NOT NULL,
    "XmlData" XML,
    CONSTRAINT "PK_ModelInstance" PRIMARY KEY ("Id")
);

CREATE TABLE "ModelRuntime"."RuntimeSchemaType" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "EditId" UUID NOT NULL,
    "VersionId" UUID,
    "Name" VARCHAR(255) NOT NULL,
    "LoadId" UUID,
    "SerializedSchema" TEXT NOT NULL,
    "EntityMetaId" UUID NOT NULL,
    CONSTRAINT "PK_RuntimeSchemaType" PRIMARY KEY ("Id")
);

CREATE TABLE "ModelRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_TemplateMap" PRIMARY KEY ("Id")
);

CREATE TABLE "PdfMappingRuntime"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    CONSTRAINT "PK_PdfMappingRuntime_DatabaseVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "PdfMappingRuntime"."PdfFileMapTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ActionId" UUID NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    "FileContent" BYTEA,
    "FileName" TEXT,
    "FileType" TEXT,
    "PossibleCheckBoxYesValues" TEXT,
    "PossibleCheckBoxNoValues" TEXT,
    "VersionId" UUID,
    CONSTRAINT "PK_PdfMappingPdfFileMapTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "PdfMappingRuntime"."PdfParameterTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ActionId" UUID NOT NULL,
    "PdfFileMapTemplateId" UUID,
    "Name" TEXT NOT NULL,
    "Type" INTEGER NOT NULL,
    "FieldType" SMALLINT NOT NULL,
    "VersionId" UUID,
    CONSTRAINT "PK_PdfMappingPdfParameterTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "PdfMappingRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_TemplateMap" PRIMARY KEY ("Id")
);

CREATE SEQUENCE "Platform_ApplicationVersion_Sequence"
    AS INTEGER
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 5;

CREATE SEQUENCE "Platform_ApplicationVersion_VersionMajor"
    AS INTEGER
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 5;

CREATE SEQUENCE "Platform"."ValueSet_ValueSetReferenceId_Sequence"
    AS INTEGER
    START WITH 1
    INCREMENT BY 1
    MINVALUE -2147483648
    MAXVALUE 2147483647;

CREATE TABLE "Platform"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    CONSTRAINT "PK_Platform_DatabaseVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "Platform"."ApplicationVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "SequenceId" INTEGER,
    "ChangesetId" UUID,
    "Created" TIMESTAMPTZ,
    "Completed" TIMESTAMPTZ,
    "ByName" VARCHAR(100),
    "ByEmail" VARCHAR(100),
    "Status" SMALLINT NOT NULL DEFAULT 0,
    "Notes" TEXT,
    "ChangesetName" VARCHAR(100),
    "VersionLabel" VARCHAR(255),
    "VersionType" SMALLINT NOT NULL,
    "SourceVersionId" UUID,
    "ChangedResourceName" VARCHAR(255),
    "VersionMajor" INTEGER NOT NULL DEFAULT 0,
    "VersionMinor" INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT "PK_Version" PRIMARY KEY ("Id"),
    CONSTRAINT "Unique_Platform_ApplicationVersion_SequenceId" UNIQUE ("SequenceId")
);

CREATE TABLE "Platform"."ApplicationRole" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    CONSTRAINT "PK_ApplicationRole" PRIMARY KEY ("Id")
);

CREATE TABLE "Platform"."ApplicationRoleByVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "VersionId" UUID NOT NULL,
    "RoleId" UUID NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    CONSTRAINT "PK_ApplicationRoleByVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "Platform"."Environment" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255),
    "Domain" VARCHAR(255),
    "ActiveDomain" VARCHAR(255) NOT NULL,
    "ActiveVersionId" UUID,
    "DeployedDate" TIMESTAMPTZ,
    "IsProduction" BOOLEAN NOT NULL DEFAULT FALSE,
    "IsMigratedToDocumentDb" BOOLEAN NOT NULL DEFAULT FALSE,
    "DebugEnabledDate" TIMESTAMPTZ,
    CONSTRAINT "PK_Environment" PRIMARY KEY ("Id")
);

CREATE TABLE "Platform"."EnvironmentApplicationRoleMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "GroupId" VARCHAR(255),
    "EnvironmentId" UUID,
    "RoleId" UUID,
    "ApplicationIdentity" VARCHAR(255),
    CONSTRAINT "PK_EnvironmentApplicationRoleMap" PRIMARY KEY ("Id")
);

CREATE TABLE "Platform"."EnvironmentDeployment" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "EnvironmentId" UUID NOT NULL,
    "VersionId" UUID NOT NULL,
    "Completed" TIMESTAMPTZ,
    "ByName" VARCHAR(255) NOT NULL,
    "ByEmail" VARCHAR(255) NOT NULL,
    "Started" TIMESTAMPTZ,
    "Status" INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT "PK_EnvironmentDeployment" PRIMARY KEY ("Id")
);

CREATE TABLE "Platform"."EnvironmentNotification" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "EnableNotification" BOOLEAN NOT NULL,
    "Payload" TEXT,
    "Endpoint" TEXT,
    "EnvironmentId" UUID NOT NULL,
    CONSTRAINT "PK_EnvironmentNotification" PRIMARY KEY ("Id")
);

CREATE TABLE "Platform"."EnvironmentNotificationCustomHttpHeader" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Key" TEXT,
    "Value" TEXT,
    "EnvironmentNotificationId" UUID NOT NULL,
    CONSTRAINT "PK_EnvironmentNotificationCustomHttpHeader" PRIMARY KEY ("Id")
);

CREATE TABLE "Platform"."EnvironmentOrigin" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Origin" VARCHAR(512) NOT NULL,
    "EnvironmentId" UUID NOT NULL,
    CONSTRAINT "PK_EnvironmentOrigin" PRIMARY KEY ("Id")
);

CREATE TABLE "Platform"."EnvironmentRoleMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "GroupId" VARCHAR(255) NOT NULL,
    "EnvironmentId" UUID,
    "RoleId" UUID,
    CONSTRAINT "PK_EnvironmentRoleMap" PRIMARY KEY ("Id")
);

CREATE TABLE "Platform"."EnvironmentVariableByVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "VersionId" UUID NOT NULL,
    "VariableId" UUID NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    CONSTRAINT "PK_EnvironmentVariableByVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "Platform"."EnvironmentVariableDefinition" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255),
    "Discontinued" BOOLEAN NOT NULL DEFAULT FALSE,
    "DiscontinuedDate" TIMESTAMPTZ,
    "IsPristine" BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT "PK_EnvironmentVariable" PRIMARY KEY ("Id"),
    CONSTRAINT "UQ_EnvinronmentVariableName" UNIQUE ("Name")
);

CREATE TABLE "Platform"."EnvironmentVariableValue" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "EnvironmentVariableId" UUID NOT NULL,
    "Value" TEXT NOT NULL,
    "EnvironmentId" UUID NOT NULL,
    CONSTRAINT "PK_EnvironmentVariableValue" PRIMARY KEY ("Id")
);

CREATE TABLE "Platform"."LogEvent" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Message" TEXT NOT NULL,
    "Timestamp" TIMESTAMP NOT NULL,
    "EnvironmentId" UUID NOT NULL,
    CONSTRAINT "PK_LogEvent" PRIMARY KEY ("Id")
);

CREATE TABLE "Platform"."ValueSet" (
    "Id" INTEGER GENERATED ALWAYS AS IDENTITY,
    "Name" VARCHAR(255) NOT NULL,
    "ValueSetReferenceId" INTEGER,
    "DeletedAt" TIMESTAMPTZ,
    CONSTRAINT "PK_ValueSet" PRIMARY KEY ("Id")
);

CREATE TABLE "Platform"."ValueSetItem" (
    "Id" INTEGER GENERATED ALWAYS AS IDENTITY,
    "ValueSetReferenceId" INTEGER NOT NULL,
    "Value" VARCHAR(255) NOT NULL,
    CONSTRAINT "PK_ValueSetItem" PRIMARY KEY ("Id", "ValueSetReferenceId")
);

CREATE TABLE "ProcessRuntime"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    CONSTRAINT "PK_ProcessRuntime_DatabaseVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "ProcessRuntime"."ProcessTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ResourceTypeId" UUID NOT NULL,
    "VersionId" UUID,
    "Name" VARCHAR(255) NOT NULL,
    "InitialActivityId" UUID NOT NULL,
    "StartActionId" UUID NOT NULL,
    "ProvideLinkToProcessInResult" BOOLEAN NOT NULL,
    "SecurityConfiguration_CustomAuthenticationStepMapId" UUID,
    "DisregardMultipleDecisionBranchesOrder" BOOLEAN NOT NULL,
    "NavigationNodesSorter" VARCHAR(60) NOT NULL DEFAULT 'firstPredecessor',
    "ProcessEndingBehavior" VARCHAR(30) NOT NULL,
    "EnrichRedirectLocation" BOOLEAN NOT NULL,
    "EnableAutoSaveOnNavigation" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ProcessTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "ProcessRuntime"."ProcessInstance" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "CurrentActionInstanceInfoId" UUID,
    "EnvironmentId" UUID NOT NULL,
    "IsFinished" BOOLEAN NOT NULL,
    "CallerInfo_SessionId" UUID NOT NULL,
    "CallerInfo_ActionMapId" UUID NOT NULL,
    "VersionId" UUID NOT NULL,
    "CallerInfo_ParentId" UUID,
    "TypeId" UUID NOT NULL,
    "XmlData" XML,
    "CreatedDate" TIMESTAMPTZ NOT NULL,
    "NotificationUrlsData" TEXT,
    "LastResumableActionInstanceInfoId" UUID,
    CONSTRAINT "PK_ProcessContext" PRIMARY KEY ("Id")
);

CREATE TABLE "ProcessRuntime"."ActivityTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ActivityId" UUID NOT NULL,
    "ProcessTemplateId" UUID NOT NULL,
    "Discriminator" VARCHAR(255) NOT NULL,
    "TrueActivityId" UUID,
    "FalseActivityId" UUID,
    "NextTemplateId" UUID,
    "MapId" UUID,
    "Expression" TEXT,
    "DefaultNextActivityId" UUID,
    CONSTRAINT "PK_ActivityTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "ProcessRuntime"."ActionInstanceInfo" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ProcessInstanceId" UUID NOT NULL,
    "EnvironmentId" UUID NOT NULL,
    "HasPendingChanges" BOOLEAN NOT NULL,
    "HasBeenCompleted" BOOLEAN NOT NULL,
    "IsValid" BOOLEAN NOT NULL,
    "ActivityId" UUID,
    "InputDataChecksum" VARCHAR(1024),
    "IsUnreachable" BOOLEAN NOT NULL,
    "RequestId" UUID NOT NULL,
    CONSTRAINT "PK_ActionInstanceInfo" PRIMARY KEY ("Id"),
    CONSTRAINT "UQ_ProcessInstance_ActivityId" UNIQUE ("ProcessInstanceId", "ActivityId")
);

CREATE TABLE "ProcessRuntime"."AuthenticationProcessRelation" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "UnAuthenticatedProcessId" UUID NOT NULL,
    "EnvironmentId" UUID NOT NULL,
    CONSTRAINT "PK_CallReference" PRIMARY KEY ("Id")
);

CREATE TABLE "ProcessRuntime"."DecisionBranch" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Expression" TEXT,
    "NextActivityId" UUID,
    "ActivityTemplateId" UUID NOT NULL,
    "Order" INTEGER NOT NULL,
    CONSTRAINT "PK_DecisionBranch" PRIMARY KEY ("Id")
);

CREATE TABLE "ProcessRuntime"."NavigationNode" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ProcessTemplateId" UUID NOT NULL,
    "Title" VARCHAR(255) NOT NULL,
    "NavigateToActivityId" UUID NOT NULL,
    "HiddenExpression" TEXT,
    CONSTRAINT "PK_ProcessNavigationNode" PRIMARY KEY ("Id")
);

CREATE TABLE "ProcessRuntime"."NavigationState" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ProcessInstanceId" UUID NOT NULL,
    "NavigationNodeId" UUID NOT NULL,
    "IsDirty" BOOLEAN NOT NULL,
    "IsValid" BOOLEAN NOT NULL,
    "IsCurrent" BOOLEAN NOT NULL,
    "Modified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "IsUnreachable" BOOLEAN NOT NULL,
    CONSTRAINT "PK_NavigationState" PRIMARY KEY ("Id")
);

CREATE TABLE "ProcessRuntime"."NotifiableField" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ActivityTemplateId" UUID NOT NULL,
    "FieldId" UUID NOT NULL,
    "FriendlyName" TEXT NOT NULL,
    CONSTRAINT "PK_NotifiableField" PRIMARY KEY ("Id"),
    CONSTRAINT "UQ_ActivityTemplateId_FieldId" UNIQUE ("ActivityTemplateId", "FieldId")
);

CREATE TABLE "ProcessRuntime"."ProcessCurrentActivitiesPath" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ProcessInstanceId" UUID NOT NULL,
    "ActivityId" UUID NOT NULL,
    "Order" INTEGER,
    "CreatedDate" TIMESTAMPTZ NOT NULL,
    CONSTRAINT "PK_ProcessCurrentActivitiesPath" PRIMARY KEY ("Id")
);

CREATE TABLE "ProcessRuntime"."ProcessEndpoint" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "IsApiEndpoint" BOOLEAN NOT NULL,
    "OutputContentType" VARCHAR(255),
    "OutputField" VARCHAR(255),
    "Name" VARCHAR(255) NOT NULL,
    "Path" VARCHAR(255) NOT NULL,
    "Method" VARCHAR(255) NOT NULL,
    "ProcessTemplateId" UUID,
    "InputField" VARCHAR(255),
    CONSTRAINT "PK_ProcessEndpoint" PRIMARY KEY ("Id")
);

CREATE TABLE "ProcessRuntime"."ProcessFieldTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ProcessTemplateId" UUID NOT NULL,
    "FieldId" UUID NOT NULL,
    "Type" INTEGER NOT NULL,
    "Name" VARCHAR(250) NOT NULL DEFAULT '',
    "IsList" BOOLEAN NOT NULL,
    "IsInputField" BOOLEAN NOT NULL,
    "IsOutputField" BOOLEAN NOT NULL,
    "IsOptional" BOOLEAN NOT NULL DEFAULT FALSE,
    "IsSensitive" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ProcessFieldTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "ProcessRuntime"."ProcessRole" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ProcessInstanceId" UUID NOT NULL,
    "Role" VARCHAR(255) NOT NULL,
    CONSTRAINT "PK_ProcessRole" PRIMARY KEY ("Id")
);


CREATE TABLE "ProcessRuntime"."SetField" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ActivityTemplateId" UUID NOT NULL,
    "FieldId" UUID NOT NULL,
    "Value" TEXT NOT NULL,
    CONSTRAINT "PK_SetFieldValueActivity" PRIMARY KEY ("Id"),
    CONSTRAINT "UQ_ActivityId_FieldId" UNIQUE ("ActivityTemplateId", "FieldId")
);

CREATE TABLE "ProcessRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_TemplateMap" PRIMARY KEY ("Id")
);

CREATE TABLE "QueryingRuntime"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    CONSTRAINT "PK_QueryingRuntime_DatabaseVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "QueryingRuntime"."QuerySchemaTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "SchemaId" UUID NOT NULL,
    "ModuleId" VARCHAR(255) NOT NULL,
    "VersionId" UUID,
    "SerializedSearchSchema" TEXT NOT NULL,
    "SerializedResultSchema" TEXT NOT NULL,
    CONSTRAINT "PK_TypeMetaTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "QueryingRuntime"."QueryTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "SchemaId" UUID NOT NULL,
    "VersionId" UUID,
    "ActionId" UUID NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    "Expression" TEXT NOT NULL,
    "SerializedInputSchema" TEXT NOT NULL,
    "SerializedOutputSchema" TEXT NOT NULL,
    "IsCaseSensitive" BOOLEAN NOT NULL,
    "IsUsingNewFormat" BOOLEAN NOT NULL,
    CONSTRAINT "PK_QueryTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "QueryingRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_TemplateMap" PRIMARY KEY ("Id")
);

CREATE TABLE "RuleRuntime"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    CONSTRAINT "PK_RuleRuntime_DatabaseVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "RuleRuntime"."RuleTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "VersionId" UUID,
    "ResourceTypeId" UUID,
    "Name" VARCHAR(255),
    "Code" TEXT,
    CONSTRAINT "PK_RuleTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "RuleRuntime"."ParameterTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ParameterId" UUID NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    "Type" INTEGER NOT NULL,
    "Direction" INTEGER,
    "RuleTemplateId" UUID,
    "IsArray" BOOLEAN NOT NULL,
    "CSharpType" VARCHAR(50) NOT NULL,
    CONSTRAINT "PK_ParameterTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "RuleRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_TemplateMap" PRIMARY KEY ("Id")
);

CREATE TABLE "SmartyStreetsConnectorRuntime"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    CONSTRAINT "PK_SmartyStreetsConnectorRuntime_DatabaseVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "SmartyStreetsConnectorRuntime"."StreetAddressConnectorTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ActionId" UUID NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    "VersionId" UUID,
    CONSTRAINT "PK_StreetAddressConnectorTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "SmartyStreetsConnectorRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_TemplateMap" PRIMARY KEY ("Id")
);

CREATE TABLE "SmartyStreetsConnectorRuntime"."ZipCodeConnectorTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ActionId" UUID NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    "VersionId" UUID,
    CONSTRAINT "PK_ZipCodeConnectorTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "TableRuleRuntime"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Version" BIGINT,
    CONSTRAINT "PK_TableRuleRuntime_DatabaseVersion" PRIMARY KEY ("Id")
);

CREATE TABLE "TableRuleRuntime"."SerializedTableRule" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ResourceTypeId" UUID NOT NULL,
    "VersionId" UUID,
    "TableRule" BYTEA NOT NULL,
    CONSTRAINT "PK_SerializedTableRule" PRIMARY KEY ("Id")
);

CREATE TABLE "TableRuleRuntime"."TemplateMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TemplateId" UUID NOT NULL,
    "ResourceId" UUID NOT NULL,
    "ApplicationVersionId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL,
    "Type" SMALLINT NOT NULL DEFAULT 1,
    "ResourceName" VARCHAR(255),
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_TemplateMap" PRIMARY KEY ("Id")
);
