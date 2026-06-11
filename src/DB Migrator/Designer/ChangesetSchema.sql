CREATE SCHEMA "AzureServiceBusConnectorDesigner";
CREATE SCHEMA "DashboardDesigner";
CREATE SCHEMA "EmailConnectorDesigner";
CREATE SCHEMA "EndpointDesigner";
CREATE SCHEMA "FileTransferConnectorDesigner";
CREATE SCHEMA "FixedWidthMappingDesigner";
CREATE SCHEMA "FormDesigner";
CREATE SCHEMA "HttpConnectorDesigner";
CREATE SCHEMA "JSRuleDesigner";
CREATE SCHEMA "MappingDesigner";
CREATE SCHEMA "ModelDesigner";
CREATE SCHEMA "PdfMappingDesigner";
CREATE SCHEMA "ProcessDesigner";
CREATE SCHEMA "QueryingDesigner";
CREATE SCHEMA "RuleDesigner";
CREATE SCHEMA "SmartyStreetsConnectorDesigner";
CREATE SCHEMA "TableRuleDesigner";

CREATE TABLE "AzureServiceBusConnectorDesigner"."AzureServiceBusConnector" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "ConnectionString" TEXT,
    "ResourceName" VARCHAR(255),
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "DateDeleted" TIMESTAMPTZ,
    "SerializerType" INTEGER NOT NULL DEFAULT 1,
    "ContentType" VARCHAR(255),
    CONSTRAINT PK_AzureServiceBusConnector PRIMARY KEY ("Id")
);

CREATE TABLE "AzureServiceBusConnectorDesigner"."AzureServiceBusConnectorParameter" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255),
    "AzureServiceBusConnectorId" UUID,
    CONSTRAINT PK_AzureServiceBusConnectorParameter PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_AzureServiceBusConnectorParameter_AzureServiceBusConnector" FOREIGN KEY ("AzureServiceBusConnectorId") REFERENCES "AzureServiceBusConnectorDesigner"."AzureServiceBusConnector" ("Id") ON DELETE CASCADE
);

CREATE TABLE "AzureServiceBusConnectorDesigner"."ForceActionPublish" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ForcePublishActions" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ForceActionPublish" PRIMARY KEY ("Id")
);

CREATE TABLE "AzureServiceBusConnectorDesigner"."Revision" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Type" INTEGER NOT NULL,
    "Timestamp" TIMESTAMPTZ NOT NULL,
    "UserName" VARCHAR(255) NOT NULL,
    "UserEmail" VARCHAR(255) NOT NULL,
    "Property" VARCHAR(1000),
    "OldValue" TEXT,
    "Value" TEXT,
    "ResourceId" UUID NOT NULL,
    "ResourceName" VARCHAR(1000) NOT NULL,
    "ParentRevisionId" UUID,
    "IsAction" BOOLEAN NOT NULL,
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_Revision" PRIMARY KEY ("Id")
);

CREATE TABLE "AzureServiceBusConnectorDesigner"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "Version" BIGINT
);

CREATE TABLE "DashboardDesigner"."File" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Path" VARCHAR(255),
    "Content" TEXT,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "DateDeleted" TIMESTAMPTZ,
    CONSTRAINT "PK_File" PRIMARY KEY ("Id")
);

CREATE TABLE "DashboardDesigner"."FileRole" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ApplicationRoleId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    CONSTRAINT "PK_FileRole" PRIMARY KEY ("Id"),
    CONSTRAINT "UQ_FileRole_ApplicationId" UNIQUE ("ApplicationRoleId")
);

CREATE TABLE "DashboardDesigner"."Revision" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Type" INTEGER NOT NULL,
    "Timestamp" TIMESTAMPTZ NOT NULL,
    "UserName" VARCHAR(255) NOT NULL,
    "UserEmail" VARCHAR(255) NOT NULL,
    "Property" VARCHAR(1000),
    "OldValue" TEXT,
    "Value" TEXT,
    "ResourceId" UUID NOT NULL,
    "ResourceName" VARCHAR(1000) NOT NULL,
    "ParentRevisionId" UUID,
    "IsAction" BOOLEAN NOT NULL,
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_Revision" PRIMARY KEY ("Id")
);

CREATE INDEX "IX_Revision_ParentRevisionId"
    ON "DashboardDesigner"."Revision" ("ParentRevisionId");

CREATE TABLE "DashboardDesigner"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "Version" BIGINT
);

CREATE TABLE "EmailConnectorDesigner"."EmailConnector" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "To" TEXT,
    "Subject" TEXT,
    "BodyMessage" TEXT,
    "SenderName" TEXT,
    "ReplyTo" TEXT,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "DateDeleted" TIMESTAMPTZ,
    CONSTRAINT "PK_EmailConnector" PRIMARY KEY ("Id")
);

CREATE TABLE "EmailConnectorDesigner"."EmailConnectorParameter" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255),
    "EmailConnectorId" UUID,
    CONSTRAINT "PK_EmailConnectorParameter" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_EmailConnectorParameter_EmailConnector" FOREIGN KEY ("EmailConnectorId") REFERENCES "EmailConnectorDesigner"."EmailConnector"("Id") ON DELETE CASCADE
);

CREATE TABLE "EmailConnectorDesigner"."ForceActionPublish" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ForcePublishActions" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ForceActionPublish" PRIMARY KEY ("Id")
);

CREATE TABLE "EmailConnectorDesigner"."Revision" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Type" INTEGER NOT NULL,
    "Timestamp" TIMESTAMPTZ NOT NULL,
    "UserName" VARCHAR(255) NOT NULL,
    "UserEmail" VARCHAR(255) NOT NULL,
    "Property" VARCHAR(1000),
    "OldValue" TEXT,
    "Value" TEXT,
    "ResourceId" UUID NOT NULL,
    "ResourceName" VARCHAR(1000) NOT NULL,
    "ParentRevisionId" UUID,
    "IsAction" BOOLEAN NOT NULL,
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_Revision" PRIMARY KEY ("Id")
);

CREATE TABLE "EmailConnectorDesigner"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "Version" BIGINT
);

CREATE TABLE "EndpointDesigner"."Endpoint" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "OutputSettings_ContentType" VARCHAR(255),
    "Name" VARCHAR(255) NOT NULL,
    "Path" VARCHAR(255) NOT NULL,
    "OwnerId" UUID NOT NULL,
    "OwnerPath" VARCHAR(255) NOT NULL,
    "MapId" UUID NOT NULL,
    "InputSettings_SerializedSchema" TEXT NOT NULL,
    "OutputSettings_SerializedSchema" TEXT NOT NULL,
    "OutputSettings_ReturnValueSettingId" UUID NOT NULL,
    "InputSettings_ReturnValueSettingId" UUID NOT NULL,
    "Method" INTEGER NOT NULL,
    "OutputSettings_IgnoreNullValues" BOOLEAN NOT NULL,
    "RowVersion" BYTEA NOT NULL DEFAULT ''::bytea,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "OutputSettings_IncludeTimeOnDateType" BOOLEAN NOT NULL,
    "IsDownload" BOOLEAN NOT NULL,
    CONSTRAINT "PK_Endpoint" PRIMARY KEY ("Id")
);

CREATE TABLE "EndpointDesigner"."EndpointRole" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "EndpointId" UUID NOT NULL,
    "ApplicationRoleId" UUID NOT NULL,
    CONSTRAINT "PK_EndpointRole" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_EndpointRole_Endpoint" FOREIGN KEY ("EndpointId")  REFERENCES "EndpointDesigner"."Endpoint"("Id") ON DELETE CASCADE
);

CREATE TABLE "EndpointDesigner"."ForceActionPublish" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ForcePublishActions" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ForceActionPublish" PRIMARY KEY ("Id")
);

CREATE TABLE "EndpointDesigner"."Revision" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Type" INTEGER NOT NULL,
    "Timestamp" TIMESTAMPTZ NOT NULL,
    "UserName" VARCHAR(255) NOT NULL,
    "UserEmail" VARCHAR(255) NOT NULL,
    "Property" VARCHAR(1000),
    "OldValue" TEXT,
    "Value" TEXT,
    "ResourceId" UUID NOT NULL,
    "ResourceName" VARCHAR(1000) NOT NULL,
    "ParentRevisionId" UUID,
    "IsAction" BOOLEAN NOT NULL,
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_Revision" PRIMARY KEY ("Id")
);

CREATE INDEX "IX_Revision_ParentRevisionId"
    ON "EndpointDesigner"."Revision" ("ParentRevisionId");

CREATE TABLE "EndpointDesigner"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "Version" BIGINT
);

CREATE TABLE "FileTransferConnectorDesigner"."FileTransferConnector" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255),
    "UserName" VARCHAR(255),
    "Password" VARCHAR(255),
    "ServerAddress" VARCHAR(255),
    "ServerPort" VARCHAR(255),
    "FileName" TEXT,
    "FolderPath" TEXT,
    "UsePassive" BOOLEAN,
    "Type" INTEGER,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "DateDeleted" TIMESTAMPTZ,
    CONSTRAINT "PK_FileTransferConnector" PRIMARY KEY ("Id")
);

CREATE TABLE "FileTransferConnectorDesigner"."FileTransferConnectorParameter" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255),
    "FileTransferConnectorId" UUID,
    "Type" INTEGER NOT NULL,
    "IsArray" BOOLEAN NOT NULL,
    CONSTRAINT "PK_FileTransferConnectorParameter" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_FileTransferConnectorParameter_FileTransferConnector" FOREIGN KEY ("FileTransferConnectorId") REFERENCES "FileTransferConnectorDesigner"."FileTransferConnector"("Id") ON DELETE CASCADE
);

CREATE TABLE "FileTransferConnectorDesigner"."ForceActionPublish" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ForcePublishActions" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ForceActionPublish" PRIMARY KEY ("Id")
);

CREATE TABLE "FileTransferConnectorDesigner"."Revision" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Type" INTEGER NOT NULL,
    "Timestamp" TIMESTAMPTZ NOT NULL,
    "UserName" VARCHAR(255) NOT NULL,
    "UserEmail" VARCHAR(255) NOT NULL,
    "Property" VARCHAR(1000),
    "OldValue" TEXT,
    "Value" TEXT,
    "ResourceId" UUID NOT NULL,
    "ResourceName" VARCHAR(1000) NOT NULL,
    "ParentRevisionId" UUID,
    "IsAction" BOOLEAN NOT NULL,
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_Revision" PRIMARY KEY ("Id")
);

CREATE TABLE "FileTransferConnectorDesigner"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "Version" BIGINT
);

CREATE TABLE "FixedWidthMappingDesigner"."FixedWidthMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "FileName" VARCHAR(255) NOT NULL,
    "ShowsColumnHeaders" BOOLEAN NOT NULL,
    "Separator" VARCHAR(255),
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    CONSTRAINT "PK_FixedWidthMap" PRIMARY KEY ("Id")
);

CREATE TABLE "FixedWidthMappingDesigner"."FixedWidthField" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "FixedWidthMapId" UUID,
    "Name" TEXT NOT NULL,
    "NameAlias" VARCHAR(255),
    "Type" INTEGER NOT NULL,
    "Width" INTEGER NOT NULL,
    "Order" BIGINT NOT NULL,
    "Format" VARCHAR(255),
    "IsFiller" BOOLEAN NOT NULL,
    CONSTRAINT "PK_FixedWidthField" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_FixedWidthField_FixedWidthMap" FOREIGN KEY ("FixedWidthMapId") REFERENCES "FixedWidthMappingDesigner"."FixedWidthMap"("Id") ON DELETE CASCADE
);

CREATE TABLE "FixedWidthMappingDesigner"."FixedWidthParameter" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "FixedWidthMapId" UUID,
    "Name" TEXT NOT NULL,
    CONSTRAINT "PK_FixedWidthParameter" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_FixedWidthParameter_FixedWidthMap" FOREIGN KEY ("FixedWidthMapId") REFERENCES "FixedWidthMappingDesigner"."FixedWidthMap"("Id") ON DELETE CASCADE
);

CREATE TABLE "FixedWidthMappingDesigner"."ForceActionPublish" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ForcePublishActions" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ForceActionPublish" PRIMARY KEY ("Id")
);

CREATE TABLE "FixedWidthMappingDesigner"."Revision" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Type" INTEGER NOT NULL,
    "Timestamp" TIMESTAMPTZ NOT NULL,
    "UserName" VARCHAR(255) NOT NULL,
    "UserEmail" VARCHAR(255) NOT NULL,
    "Property" VARCHAR(1000),
    "OldValue" TEXT,
    "Value" TEXT,
    "ResourceId" UUID NOT NULL,
    "ResourceName" VARCHAR(1000) NOT NULL,
    "ParentRevisionId" UUID,
    "IsAction" BOOLEAN NOT NULL,
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_Revision" PRIMARY KEY ("Id")
);

CREATE INDEX "IX_Revision_ParentRevisionId"
    ON "FixedWidthMappingDesigner"."Revision" ("ParentRevisionId");

CREATE TABLE "FixedWidthMappingDesigner"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "Version" BIGINT
);

CREATE TABLE IF NOT EXISTS "FormDesigner"."Form" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255),
    "Label" VARCHAR(255),
    "OverrideDefaultLabel" BOOLEAN NOT NULL DEFAULT FALSE,
    "IsLabelHidden" BOOLEAN NOT NULL DEFAULT FALSE,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "SubmitTitle" VARCHAR(255),
    "ButtonWidth" VARCHAR(30) DEFAULT 'classic',
    "AllowSingleExpandedSection" BOOLEAN NOT NULL DEFAULT FALSE,
    "EnableAutoSubmitForSingleSelect" BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT "PK_Form" PRIMARY KEY ("Id")
);

CREATE TABLE "FormDesigner"."FormElement" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "FormId" UUID,
    "Name" TEXT,
    "Order" BIGINT NOT NULL,
    "Discriminator" VARCHAR(255) NOT NULL,
    "IsRequired" BOOLEAN DEFAULT FALSE,
    "InputFormat_MaxLength" INTEGER,
    "InputFormat_MinLength" INTEGER,
    "InputFormat_Max" INTEGER,
    "InputFormat_Min" INTEGER,
    "TypeOfSelect" INTEGER,
    "ContainerId" UUID,
    "HiddenExpression" TEXT,
    "DisabledExpression" TEXT,
    "Text" VARCHAR(255),
    "AreOptionsMappable" BOOLEAN,
    "TextId" UUID,
    "ValueId" UUID,
    "Pattern" TEXT,
    "DisplayType" INTEGER,
    "Label" TEXT,
    "IsLabelHidden" BOOLEAN,
    "OverrideDefaultLabel" BOOLEAN,
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
    "RootFormId" UUID NOT NULL,
    "StylingOptionValue" VARCHAR(25),
    "IsCollapsible" BOOLEAN,
    "ImageFormat" VARCHAR(10),
    "ImageContent" BYTEA,
    "AllowSingleExpandedSection" BOOLEAN,
    "IsInterceptable" BOOLEAN,
    "InterceptionDestinationField" VARCHAR(255),
    "IsSoftHideable" BOOLEAN NOT NULL,
    "UseIcon" BOOLEAN,
    "AllowOptionGroupElement" BOOLEAN,
    "GroupId" UUID,
    "MinNumberOfSelection" INTEGER,
    "MaxNumberOfSelection" INTEGER,
    "IsSensitive" BOOLEAN,
    "HasSensitiveName" BOOLEAN,
    CONSTRAINT "PK_FormElement" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_FormElement_Form" FOREIGN KEY ("FormId") REFERENCES "FormDesigner"."Form" ("Id") ON DELETE CASCADE,
    --CONSTRAINT "FK_FormElement_Container" FOREIGN KEY ("ContainerId") REFERENCES "FormDesigner"."FormElement" ("Id")
);


CREATE TABLE "FormDesigner"."Column" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255),
    "TableId" UUID NOT NULL,
    "Order" BIGINT,
    CONSTRAINT "PK_FormColumn" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_Column_FormElement" FOREIGN KEY ("TableId") REFERENCES "FormDesigner"."FormElement" ("Id")
);

CREATE TABLE "FormDesigner"."ForceActionPublish" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ForcePublishActions" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ForceActionPublish" PRIMARY KEY ("Id")
);


CREATE TABLE "FormDesigner"."FormElementValidation" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "FormElementId" UUID NOT NULL,
    "Expression" TEXT NOT NULL,
    "Message" VARCHAR(255) NOT NULL,
    "Type" SMALLINT NOT NULL,
    CONSTRAINT "PK_FormElementValidation" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_FormElementValidation_FormElement" FOREIGN KEY ("FormElementId") REFERENCES "FormDesigner"."FormElement" ("Id")
);

CREATE TABLE "FormDesigner"."FormParameter" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "FormId" UUID NOT NULL,
    "Name" VARCHAR(255),
    "Type" INTEGER NOT NULL,
    CONSTRAINT "PK_Parameter" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_FormParameter_Form" FOREIGN KEY ("FormId") REFERENCES "FormDesigner"."Form" ("Id") ON DELETE CASCADE
);

CREATE TABLE "FormDesigner"."HelperItem" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "HelperFieldId" UUID NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    "Url" VARCHAR(255) NOT NULL,
    "Order" BIGINT,
    CONSTRAINT "PK_HelperItem" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_HelperItem_HelperField" FOREIGN KEY ("HelperFieldId") REFERENCES "FormDesigner"."FormElement" ("Id") ON DELETE CASCADE
);

CREATE TABLE "FormDesigner"."Option" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "InputFieldId" UUID NOT NULL,
    "Text" VARCHAR(255),
    "Value" VARCHAR(255) NOT NULL,
    "Order" BIGINT NOT NULL,
    "HiddenExpression" TEXT,
    "Group" VARCHAR(255),
    CONSTRAINT "PK_Option" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_Option_FormElement" FOREIGN KEY ("InputFieldId") REFERENCES "FormDesigner"."FormElement" ("Id") ON DELETE CASCADE
);

CREATE TABLE "FormDesigner"."Revision" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Type" INTEGER NOT NULL,
    "Timestamp" TIMESTAMPTZ NOT NULL,
    "UserName" VARCHAR(255) NOT NULL,
    "UserEmail" VARCHAR(255) NOT NULL,
    "Property" VARCHAR(1000),
    "OldValue" TEXT,
    "Value" TEXT,
    "ResourceId" UUID NOT NULL,
    "ResourceName" VARCHAR(1000) NOT NULL,
    "ParentRevisionId" UUID,
    "IsAction" BOOLEAN NOT NULL,
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_Revision" PRIMARY KEY ("Id")
);

CREATE TABLE "FormDesigner"."StylingOption" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "Value" VARCHAR(25),
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    CONSTRAINT "PK_StylingOption" PRIMARY KEY ("Id")
);

CREATE TABLE "FormDesigner"."TableParameter" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255),
    "TableId" UUID NOT NULL,
    "Type" INTEGER,
    CONSTRAINT "PK_FormTableParameter" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_TableParameter_FormElement" FOREIGN KEY ("TableId") REFERENCES "FormDesigner"."FormElement" ("Id") ON DELETE CASCADE
);

CREATE TABLE "FormDesigner"."TextVariation" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ElementProperty" VARCHAR(512) NOT NULL,
    "ExpressionText" TEXT NOT NULL,
    "TextVariant" TEXT NOT NULL,
    "ElementId" UUID NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    CONSTRAINT "PK_TextVariation" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_TextVariation_FormElement" FOREIGN KEY ("ElementId") REFERENCES "FormDesigner"."FormElement" ("Id") ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS "IX_Revision_ParentRevisionId"
    ON "FormDesigner"."Revision" ("ParentRevisionId");

CREATE TABLE "FormDesigner"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "Version" BIGINT
);

CREATE TABLE "HttpConnectorDesigner"."HttpConnector" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "Method" INTEGER NOT NULL,
    "CustomRequestContentType" VARCHAR(255),
    "Url" TEXT NOT NULL,
    "RequestContentType" INTEGER NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "DateDeleted" TIMESTAMPTZ,
    "UseStatusCodeForTimeout" BOOLEAN NOT NULL,
    "RetryStrategy_Retries" INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT "PK_HttpConnector" PRIMARY KEY ("Id")
);

CREATE TABLE "HttpConnectorDesigner"."HttpConnectorParameter" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255),
    "HttpConnectorId" UUID,
    "Discriminator" VARCHAR(255) NOT NULL DEFAULT 'Url',
    "Key" VARCHAR(255),
    "Type" INTEGER,
    "IsArray" BOOLEAN NOT NULL,
    CONSTRAINT "PK_HttpConnectorParameter" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_HttpConnectorParameter_HttpConnector" FOREIGN KEY ("HttpConnectorId") REFERENCES "HttpConnectorDesigner"."HttpConnector"("Id") ON DELETE CASCADE
);

CREATE TABLE "HttpConnectorDesigner"."AuthenticationProvider" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "HttpConnectorId" UUID NOT NULL,
    "Key" VARCHAR(255),
    "Secret" TEXT,
    "Discriminator" VARCHAR(255) NOT NULL,
    "TenantId" VARCHAR(255),
    "ResourceId" VARCHAR(255),
    "ClientId" VARCHAR(255),
    "AppKey" VARCHAR(255),
    CONSTRAINT "PK_AuthenticationProvider" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_AuthenticationProvider_HttpConnector" FOREIGN KEY ("HttpConnectorId") REFERENCES "HttpConnectorDesigner"."HttpConnector"("Id") ON DELETE CASCADE
);

CREATE TABLE "HttpConnectorDesigner"."CustomHttpHeader" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Key" VARCHAR(255),
    "Value" TEXT,
    "HttpConnectorId" UUID NOT NULL,
    CONSTRAINT "PK_CustomHttpHeader" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_CustomHttpHeader_HttpConnector" FOREIGN KEY ("HttpConnectorId") REFERENCES "HttpConnectorDesigner"."HttpConnector"("Id") ON DELETE CASCADE
);

CREATE TABLE "HttpConnectorDesigner"."ForceActionPublish" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ForcePublishActions" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ForceActionPublish" PRIMARY KEY ("Id")
);

CREATE TABLE "HttpConnectorDesigner"."Revision" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Type" INTEGER NOT NULL,
    "Timestamp" TIMESTAMPTZ NOT NULL,
    "UserName" VARCHAR(255) NOT NULL,
    "UserEmail" VARCHAR(255) NOT NULL,
    "Property" VARCHAR(1000),
    "OldValue" TEXT,
    "Value" TEXT,
    "ResourceId" UUID NOT NULL,
    "ResourceName" VARCHAR(1000) NOT NULL,
    "ParentRevisionId" UUID,
    "IsAction" BOOLEAN NOT NULL,
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_Revision" PRIMARY KEY ("Id")
);

CREATE TABLE "HttpConnectorDesigner"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "Version" BIGINT
);

CREATE TABLE "JSRuleDesigner"."Rule" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "Code" TEXT,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "Migrated" TIMESTAMPTZ,
    CONSTRAINT "PK_JSRule" PRIMARY KEY ("Id")
);

CREATE TABLE "JSRuleDesigner"."Parameter" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "RuleId" UUID,
    "Name" VARCHAR(255) NOT NULL,
    "Type" INTEGER NOT NULL,
    "Direction" INTEGER NOT NULL,
    "IsArray" BOOLEAN NOT NULL,
    "Alias" VARCHAR(255),
    CONSTRAINT "PK_JSParameter" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_JSParameter_JSRule" FOREIGN KEY ("RuleId") REFERENCES "JSRuleDesigner"."Rule" ("Id") ON DELETE CASCADE
);

CREATE TABLE "JSRuleDesigner"."ForceActionPublish" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ForcePublishActions" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ForceActionPublish" PRIMARY KEY ("Id")
);

CREATE TABLE "JSRuleDesigner"."Revision" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Type" INTEGER NOT NULL,
    "Timestamp" TIMESTAMPTZ NOT NULL,
    "UserName" VARCHAR(255) NOT NULL,
    "UserEmail" VARCHAR(255) NOT NULL,
    "Property" VARCHAR(1000),
    "OldValue" TEXT,
    "Value" TEXT,
    "ResourceId" UUID NOT NULL,
    "ResourceName" VARCHAR(1000) NOT NULL,
    "ParentRevisionId" UUID,
    "IsAction" BOOLEAN NOT NULL,
    "Origin_ChangesetId" UUID,
    "Origin_ChangesetName" VARCHAR(255),
    "IsPropagation" BOOLEAN NOT NULL,
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_Revision" PRIMARY KEY ("Id")
);

CREATE INDEX "IX_Revision_ParentRevisionId"
    ON "JSRuleDesigner"."Revision" ("ParentRevisionId");

CREATE TABLE "JSRuleDesigner"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "Version" BIGINT
);

CREATE TABLE "MappingDesigner"."ActionDescription" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ModuleName" VARCHAR(255),
    "Name" VARCHAR(255),
    "Schema" TEXT,
    "IsCaller" BOOLEAN NOT NULL,
    "SerializedOutputSchema" TEXT NOT NULL DEFAULT '',
    "SerializedInputSchema" TEXT NOT NULL DEFAULT '',
    "ActionId" UUID NOT NULL,
    "DateDeleted" TIMESTAMPTZ,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    CONSTRAINT "PK_ActionDescription" PRIMARY KEY ("Id"),
    CONSTRAINT "UQ_ActionId" UNIQUE ("ActionId")
);

CREATE TABLE "MappingDesigner"."Map" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ActionDescriptionId" UUID,
    "CallerDescriptionId" UUID,
    "ParentId" VARCHAR(255) NOT NULL,
    "Direction" INTEGER NOT NULL DEFAULT 2,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    CONSTRAINT "PK_Map" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_Map_SourceId_ActionDescription" FOREIGN KEY ("CallerDescriptionId") REFERENCES "MappingDesigner"."ActionDescription" ("Id"),
    --CONSTRAINT "FK_Map_TargetId_ActionDescription" FOREIGN KEY ("ActionDescriptionId") REFERENCES "MappingDesigner"."ActionDescription" ("Id")
);

CREATE TABLE "MappingDesigner"."FieldMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "CallerFieldId" UUID,
    "ActionFieldId" UUID,
    "MapId" UUID NOT NULL,
    "Direction" INTEGER NOT NULL,
    CONSTRAINT "PK_FieldMap" PRIMARY KEY ("Id"),
    CONSTRAINT "UC_FieldMap_MapId_CallerFieldId_ActionFieldId_Direction" UNIQUE ("MapId", "CallerFieldId", "ActionFieldId", "Direction")--,
    --CONSTRAINT "FK_FieldMap_Map" FOREIGN KEY ("MapId") REFERENCES "MappingDesigner"."Map" ("Id") ON DELETE CASCADE
);

CREATE TABLE "MappingDesigner"."Revision" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Type" INTEGER NOT NULL,
    "Timestamp" TIMESTAMPTZ NOT NULL,
    "UserName" VARCHAR(255) NOT NULL,
    "UserEmail" VARCHAR(255) NOT NULL,
    "Property" VARCHAR(1000),
    "OldValue" TEXT,
    "Value" TEXT,
    "ResourceId" UUID NOT NULL,
    "ResourceName" VARCHAR(1000) NOT NULL,
    "ParentRevisionId" UUID,
    "IsAction" BOOLEAN NOT NULL,
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_Revision" PRIMARY KEY ("Id")
);

CREATE INDEX "IX_Revision_ParentRevisionId"
    ON "MappingDesigner"."Revision" ("ParentRevisionId");

CREATE TABLE "MappingDesigner"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "Version" BIGINT
);

CREATE TABLE "ModelDesigner"."SchemaType" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255),
    "Type" INTEGER NOT NULL,
    "IsEntity" BOOLEAN NOT NULL,
    "IsInlined" BOOLEAN NOT NULL,
    "Length" INTEGER,
    "MaxLength" INTEGER,
    "MinLength" INTEGER,
    "Pattern" VARCHAR(255),
    "MaxValue" DECIMAL(19,5),
    "MinValue" DECIMAL(19,5),
    "TotalDigits" INTEGER,
    "FractionDigits" INTEGER,
    "MinDate" DATE,
    "MaxDate" DATE,
    CONSTRAINT "PK_SchemaType" PRIMARY KEY ("Id")
);

CREATE TABLE "ModelDesigner"."Element" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "SchemaTypeId" UUID NOT NULL,
    "Name" VARCHAR(255),
    "TypeReferenceId" UUID NOT NULL,
    "IsReadOnly" BOOLEAN NOT NULL,
    "IsPrimaryKey" BOOLEAN NOT NULL,
    "IsArray" BOOLEAN NOT NULL,
    CONSTRAINT "PK_Element" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_Element_SchemaType" FOREIGN KEY ("SchemaTypeId") REFERENCES "ModelDesigner"."SchemaType" ("Id"),
    --CONSTRAINT "FK_Element_TypeReferenceId" FOREIGN KEY ("TypeReferenceId") REFERENCES "ModelDesigner"."SchemaType" ("Id")
);

CREATE TABLE "ModelDesigner"."EntityTypeMeta" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "SerializedSchema" TEXT NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    CONSTRAINT "PK_EntityTypeMeta" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_EntityTypeMeta_SchemaType" FOREIGN KEY ("Id") REFERENCES "ModelDesigner"."SchemaType" ("Id") ON DELETE CASCADE
);

CREATE TABLE "ModelDesigner"."ForceActionPublish" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ForcePublishActions" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ForceActionPublish" PRIMARY KEY ("Id")
);

CREATE TABLE "ModelDesigner"."ModelActionsMeta" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "SchemaTypeId" UUID NOT NULL,
    "EditActionId" UUID NOT NULL,
    "LoadActionId" UUID NOT NULL,
    CONSTRAINT "PK_CompiledTypeMeta" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_CompiledTypeMeta_SchemaType" FOREIGN KEY ("SchemaTypeId") REFERENCES "ModelDesigner"."SchemaType" ("Id")
);

CREATE TABLE "ModelDesigner"."Revision" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Type" INTEGER NOT NULL,
    "Timestamp" TIMESTAMPTZ NOT NULL,
    "UserName" VARCHAR(255) NOT NULL,
    "UserEmail" VARCHAR(255) NOT NULL,
    "Property" VARCHAR(1000),
    "OldValue" TEXT,
    "Value" TEXT,
    "ResourceId" UUID NOT NULL,
    "ResourceName" VARCHAR(1000) NOT NULL,
    "ParentRevisionId" UUID,
    "IsAction" BOOLEAN NOT NULL,
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_Revision" PRIMARY KEY ("Id")
);

CREATE INDEX "IX_Revision_ParentRevisionId"
    ON "ModelDesigner"."Revision" ("ParentRevisionId");

CREATE TABLE "ModelDesigner"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "Version" BIGINT
);

CREATE TABLE "PdfMappingDesigner"."PdfFileMap" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "FileContent" BYTEA,
    "FileName" TEXT,
    "PossibleCheckBoxYesValues" TEXT,
    "PossibleCheckBoxNoValues" TEXT,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "FileLastDeleteOrModificationDate" TIMESTAMPTZ,
    CONSTRAINT "PK_PdfMappingPdfFileMap" PRIMARY KEY ("Id")
);

CREATE TABLE "PdfMappingDesigner"."PdfParameter" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "PdfFileMapId" UUID,
    "Name" TEXT NOT NULL,
    "NameAlias" VARCHAR(255),
    "Type" INTEGER NOT NULL,
    "FieldType" SMALLINT NOT NULL,
    CONSTRAINT "PK_PdfMappingPdfParameter" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_PdfParameter_PdfFileMap" FOREIGN KEY ("PdfFileMapId") REFERENCES "PdfMappingDesigner"."PdfFileMap"("Id") ON DELETE CASCADE
);

CREATE TABLE "PdfMappingDesigner"."ForceActionPublish" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ForcePublishActions" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ForceActionPublish" PRIMARY KEY ("Id")
);

CREATE TABLE "PdfMappingDesigner"."Revision" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Type" INTEGER NOT NULL,
    "Timestamp" TIMESTAMPTZ NOT NULL,
    "UserName" VARCHAR(255) NOT NULL,
    "UserEmail" VARCHAR(255) NOT NULL,
    "Property" VARCHAR(1000),
    "OldValue" TEXT,
    "Value" TEXT,
    "ResourceId" UUID NOT NULL,
    "ResourceName" VARCHAR(1000) NOT NULL,
    "ParentRevisionId" UUID,
    "IsAction" BOOLEAN NOT NULL,
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_Revision" PRIMARY KEY ("Id")
);

CREATE INDEX "IX_Revision_ParentRevisionId"
    ON "PdfMappingDesigner"."Revision" ("ParentRevisionId");

CREATE TABLE "PdfMappingDesigner"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "Version" BIGINT
);

CREATE TABLE "ProcessDesigner"."ProcessTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "InitialActivityId" UUID,
    "ResumeActionId" UUID NOT NULL,
    "StartActionId" UUID NOT NULL,
    "ProvideLinkToProcessInResult" BOOLEAN NOT NULL,
    "SecurityConfiguration_MapId" UUID,
    "SecurityConfiguration_SelectedAuthenticationActionId" UUID,
    "SecurityConfiguration_AuthenticationMode" INTEGER NOT NULL DEFAULT 0,
    "DateDeleted" TIMESTAMPTZ,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "DisregardMultipleDecisionBranchesOrder" BOOLEAN NOT NULL,
    "NavigationNodesSorter" VARCHAR(60) NOT NULL DEFAULT 'firstPredecessor',
    "ProcessEndingBehavior" VARCHAR(30) NOT NULL,
    "EnableAutoSaveOnNavigation" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ProcessTemplate" PRIMARY KEY ("Id")
);

CREATE TABLE "ProcessDesigner"."ActivityTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Alias" VARCHAR(255),
    "ProcessTemplateId" UUID NOT NULL,
    "Discriminator" VARCHAR(255) NOT NULL,
    "TrueActivityId" UUID,
    "FalseActivityId" UUID,
    "Expression" TEXT,
    "NextTemplateId" UUID,
    "MapId" UUID,
    "DefaultNextActivityId" UUID,
    CONSTRAINT "PK_ActivityTemplate" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_ActivityTemplate_ProcessTemplate" FOREIGN KEY ("ProcessTemplateId") REFERENCES "ProcessDesigner"."ProcessTemplate" ("Id") ON DELETE CASCADE
);

CREATE TABLE "ProcessDesigner"."DecisionBranch" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Expression" TEXT,
    "NextActivityId" UUID,
    "ActivityTemplateId" UUID NOT NULL,
    "Order" BIGINT NOT NULL,
    CONSTRAINT "PK_DecisionBranch" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_DecisionBranch_ActivityTemplate" FOREIGN KEY ("ActivityTemplateId") REFERENCES "ProcessDesigner"."ActivityTemplate" ("Id") ON DELETE CASCADE
);

CREATE TABLE "ProcessDesigner"."ForceActionPublish" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ForcePublishActions" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ForceActionPublish" PRIMARY KEY ("Id")
);

CREATE TABLE "ProcessDesigner"."NavigationNode" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ProcessTemplateId" UUID NOT NULL,
    "Title" VARCHAR(255) NOT NULL,
    "NavigateToActivityId" UUID,
    "HiddenExpression" TEXT,
    CONSTRAINT "PK_ProcessNavigationNode" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_NavigationNode_ProcessTemplate" FOREIGN KEY ("ProcessTemplateId") REFERENCES "ProcessDesigner"."ProcessTemplate" ("Id") ON DELETE CASCADE
);

CREATE TABLE "ProcessDesigner"."NotifiableField" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ActivityTemplateId" UUID NOT NULL,
    "FieldId" UUID,
    "FriendlyName" TEXT,
    CONSTRAINT "PK_NotifiableFieldValueActivity" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_NotifiableFieldValueActivity_ActivityTemplate" FOREIGN KEY ("ActivityTemplateId") REFERENCES "ProcessDesigner"."ActivityTemplate" ("Id") ON DELETE CASCADE
);

CREATE TABLE "ProcessDesigner"."ProcessEndpoint" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "IsApiEndpoint" BOOLEAN NOT NULL,
    "OutputContentType" VARCHAR(255),
    "OutputField" VARCHAR(255),
    "Name" VARCHAR(255) NOT NULL,
    "Path" VARCHAR(255) NOT NULL,
    "Method" VARCHAR(255) NOT NULL,
    "ProcessTemplateId" UUID,
    "InputField" VARCHAR(255),
    CONSTRAINT "PK_ProcessEndpoint" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_ProcessEndpoint_ProcessTemplate" FOREIGN KEY ("ProcessTemplateId") REFERENCES "ProcessDesigner"."ProcessTemplate" ("Id") ON DELETE CASCADE
);

CREATE TABLE "ProcessDesigner"."ProcessFieldTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "ProcessTemplateId" UUID,
    "Type" INTEGER NOT NULL,
    "LabelParameterIndex" INTEGER,
    "IsList" BOOLEAN NOT NULL,
    "IsInputField" BOOLEAN NOT NULL,
    "IsOutputField" BOOLEAN NOT NULL,
    "IsOptional" BOOLEAN NOT NULL DEFAULT FALSE,
    "IsSensitive" BOOLEAN NOT NULL,
    "HasSensitiveName" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ProcessFieldTemplate" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_ProcessFieldTemplate_ProcessTemplate" FOREIGN KEY ("ProcessTemplateId") REFERENCES "ProcessDesigner"."ProcessTemplate" ("Id") ON DELETE CASCADE
);

CREATE TABLE "ProcessDesigner"."Revision" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Type" INTEGER NOT NULL,
    "Timestamp" TIMESTAMPTZ NOT NULL,
    "UserName" VARCHAR(255) NOT NULL,
    "UserEmail" VARCHAR(255) NOT NULL,
    "Property" VARCHAR(1000),
    "OldValue" TEXT,
    "Value" TEXT,
    "ResourceId" UUID NOT NULL,
    "ResourceName" VARCHAR(1000) NOT NULL,
    "ParentRevisionId" UUID,
    "IsAction" BOOLEAN NOT NULL,
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_Revision" PRIMARY KEY ("Id")
);

CREATE TABLE "ProcessDesigner"."SetField" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ActivityTemplateId" UUID NOT NULL,
    "FieldId" UUID,
    "Value" TEXT,
    CONSTRAINT "PK_SetFieldValueActivity" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_SetFieldValueActivity_ActivityTemplate" FOREIGN KEY ("ActivityTemplateId") REFERENCES "ProcessDesigner"."ActivityTemplate" ("Id") ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS "IX_Revision_ParentRevisionId"
    ON "ProcessDesigner"."Revision" ("ParentRevisionId");

CREATE TABLE "ProcessDesigner"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "Version" BIGINT
);

CREATE TABLE "QueryingDesigner"."Query" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "SchemaId" UUID NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    "Expression" TEXT NOT NULL,
    "IsCaseSensitive" BOOLEAN NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "IsUsingNewFormat" BOOLEAN NOT NULL,
    CONSTRAINT "PK_Query" PRIMARY KEY ("Id")
);

CREATE TABLE "QueryingDesigner"."QueryInputParameter" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "QueryId" UUID NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    "Type" INTEGER NOT NULL,
    CONSTRAINT "PK_QueryInputParameter" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_QueryInputParameter_Query" FOREIGN KEY ("QueryId") REFERENCES "QueryingDesigner"."Query" ("Id") ON DELETE CASCADE
);

CREATE TABLE "QueryingDesigner"."QueryOutputParameter" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "QueryId" UUID NOT NULL,
    "PropertyId" UUID NOT NULL,
    CONSTRAINT "PK_QueryOutputParameter" PRIMARY KEY ("Id"),
    --CONSTRAINT "FK_QueryOutputParameter_Query" FOREIGN KEY ("QueryId") REFERENCES "QueryingDesigner"."Query" ("Id") ON DELETE CASCADE,
    CONSTRAINT "UC_QueryOutputParameter_QueryId_PropertyId" UNIQUE ("QueryId", "PropertyId")
);

CREATE TABLE "QueryingDesigner"."QuerySchema" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "SchemaId" UUID NOT NULL,
    "ModuleId" VARCHAR(255) NOT NULL,
    "SerializedSearchSchema" TEXT NOT NULL,
    "SerializedResultSchema" TEXT NOT NULL,
    "OwnerId" VARCHAR(255) NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    CONSTRAINT "PK_TypeMetaEntity" PRIMARY KEY ("Id"),
    CONSTRAINT "UQ_QueryingDesigner_SchemaId" UNIQUE ("SchemaId")
);

CREATE TABLE "QueryingDesigner"."ForceActionPublish" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ForcePublishActions" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ForceActionPublish" PRIMARY KEY ("Id")
);

CREATE TABLE "QueryingDesigner"."Revision" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Type" INTEGER NOT NULL,
    "Timestamp" TIMESTAMPTZ NOT NULL,
    "UserName" VARCHAR(255) NOT NULL,
    "UserEmail" VARCHAR(255) NOT NULL,
    "Property" VARCHAR(1000),
    "OldValue" TEXT,
    "Value" TEXT,
    "ResourceId" UUID NOT NULL,
    "ResourceName" VARCHAR(1000) NOT NULL,
    "ParentRevisionId" UUID,
    "IsAction" BOOLEAN NOT NULL,
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_Revision" PRIMARY KEY ("Id")
);

CREATE INDEX "IX_Revision_ParentRevisionId"
    ON "QueryingDesigner"."Revision" ("ParentRevisionId");

CREATE TABLE "QueryingDesigner"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "Version" BIGINT
);

CREATE TABLE "RuleDesigner"."RuleTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "Code" TEXT,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    CONSTRAINT "PK_JSRule" PRIMARY KEY ("Id")
);

CREATE TABLE "RuleDesigner"."ParameterTemplate" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "RuleId" UUID,
    "Name" VARCHAR(255) NOT NULL,
    "Type" VARCHAR(255) NOT NULL,
    "Direction" INTEGER NOT NULL,
    "IsArray" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ParameterTemplate" PRIMARY KEY ("Id")--,
    --CONSTRAINT "FK_ParameterTemplate_RuleTemplate" FOREIGN KEY ("RuleId") REFERENCES "RuleDesigner"."RuleTemplate" ("Id") ON DELETE CASCADE
);

CREATE TABLE "RuleDesigner"."ForceActionPublish" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ForcePublishActions" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ForceActionPublish" PRIMARY KEY ("Id")
);

CREATE TABLE "RuleDesigner"."Revision" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Type" INTEGER NOT NULL,
    "Timestamp" TIMESTAMPTZ NOT NULL,
    "UserName" VARCHAR(255) NOT NULL,
    "UserEmail" VARCHAR(255) NOT NULL,
    "Property" VARCHAR(1000),
    "OldValue" TEXT,
    "Value" TEXT,
    "ResourceId" UUID NOT NULL,
    "ResourceName" VARCHAR(1000) NOT NULL,
    "ParentRevisionId" UUID,
    "IsAction" BOOLEAN NOT NULL,
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_Revision" PRIMARY KEY ("Id")
);

CREATE INDEX "IX_Revision_ParentRevisionId"
    ON "RuleDesigner"."Revision" ("ParentRevisionId");

CREATE TABLE "RuleDesigner"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "Version" BIGINT
);

CREATE TABLE "SmartyStreetsConnectorDesigner"."StreetAddressConnector" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "DateDeleted" TIMESTAMPTZ,
    CONSTRAINT "PK_StreetAddressConnector" PRIMARY KEY ("Id")
);

CREATE TABLE "SmartyStreetsConnectorDesigner"."ZipCodeConnector" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255) NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "DateDeleted" TIMESTAMPTZ,
    CONSTRAINT "PK_ZipCodeConnector" PRIMARY KEY ("Id")
);

CREATE TABLE "SmartyStreetsConnectorDesigner"."ForceActionPublish" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ForcePublishActions" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ForceActionPublish" PRIMARY KEY ("Id")
);

CREATE TABLE "SmartyStreetsConnectorDesigner"."Revision" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Type" INTEGER NOT NULL,
    "Timestamp" TIMESTAMPTZ NOT NULL,
    "UserName" VARCHAR(255) NOT NULL,
    "UserEmail" VARCHAR(255) NOT NULL,
    "Property" VARCHAR(1000),
    "OldValue" TEXT,
    "Value" TEXT,
    "ResourceId" UUID NOT NULL,
    "ResourceName" VARCHAR(1000) NOT NULL,
    "ParentRevisionId" UUID,
    "IsAction" BOOLEAN NOT NULL,
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_Revision" PRIMARY KEY ("Id")
);

CREATE INDEX "IX_Revision_ParentRevisionId"
    ON "SmartyStreetsConnectorDesigner"."Revision" ("ParentRevisionId");

CREATE TABLE "SmartyStreetsConnectorDesigner"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "Version" BIGINT
);

CREATE TABLE "TableRuleDesigner"."TableRule" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Name" VARCHAR(255),
    "IsReturningArrayResult" BOOLEAN NOT NULL,
    "IgnoreWildcardOnExactMatch" BOOLEAN NOT NULL DEFAULT FALSE,
    "RowReferenceId" UUID NOT NULL,
    "FixedTimeZone" BOOLEAN,
    "LocalTimeZone" VARCHAR(255),
    "TimeMatching" INTEGER,
    "TimezoneParameterId" UUID NOT NULL,
    "DateDeleted" TIMESTAMPTZ,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "IsBookmarked" BOOLEAN NOT NULL DEFAULT FALSE,
    "IncludeOutputWilcardsInSpecificity" BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT "PK_TableRule" PRIMARY KEY ("Id")
);

CREATE TABLE "TableRuleDesigner"."BuildResult" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ResourceId" UUID NOT NULL,
    "ResourceStatus_LastModified" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    "ResourceType" TEXT,
    "BuildStatus" SMALLINT NOT NULL,
    "Message" TEXT,
    CONSTRAINT "PK_BuildResult" PRIMARY KEY ("Id")
);

CREATE TABLE "TableRuleDesigner"."Column" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TableRuleId" UUID NOT NULL,
    "Type" INTEGER,
    "Name" VARCHAR(255),
    "Order" BIGINT NOT NULL DEFAULT -1,
    "IsCaseSensitive" BOOLEAN NOT NULL DEFAULT TRUE,
    "IsUnique" BOOLEAN NOT NULL DEFAULT FALSE,
    "MatchAny" BOOLEAN NOT NULL,
    "CellReference" INTEGER,
    "ValueType" INTEGER NOT NULL,
    "ValueLength_Min" INTEGER,
    "ValueLength_Max" INTEGER,
    "NumberRange_Min" NUMERIC(19,5),
    "NumberRange_Max" NUMERIC(19,5),
    "ValueSetId" INTEGER,
    "InputValidationType" INTEGER,
    "IsSensitive" BOOLEAN NOT NULL,
    "HasSensitiveName" BOOLEAN NOT NULL,
    CONSTRAINT "PK_Column" PRIMARY KEY ("Id"),
    CONSTRAINT "UQ_CellReference_TableRuleId" UNIQUE ("TableRuleId", "CellReference")--,
    --CONSTRAINT "FK_Column_TableRule" FOREIGN KEY ("TableRuleId") REFERENCES "TableRuleDesigner"."TableRule" ("Id")
);

CREATE TABLE "TableRuleDesigner"."ForceActionPublish" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "ForcePublishActions" BOOLEAN NOT NULL,
    CONSTRAINT "PK_ForceActionPublish" PRIMARY KEY ("Id")
);

CREATE TABLE "TableRuleDesigner"."Row" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "TableRuleRowReferenceId" UUID NOT NULL,
    "Created" TIMESTAMPTZ NOT NULL,
    "Committed" BOOLEAN NOT NULL DEFAULT FALSE,
    "Cells_Cell1" TEXT,
    "Cells_Cell2" TEXT,
    "Cells_Cell3" TEXT,
    "Cells_Cell4" TEXT,
    "Cells_Cell5" TEXT,
    "Cells_Cell6" TEXT,
    "Cells_Cell7" TEXT,
    "Cells_Cell8" TEXT,
    "Cells_Cell9" TEXT,
    "Cells_Cell10" TEXT,
    "Cells_Cell11" TEXT,
    "Cells_Cell12" TEXT,
    "Cells_Cell13" TEXT,
    "Cells_Cell14" TEXT,
    "Cells_Cell15" TEXT,
    "Cells_Cell16" TEXT,
    "Cells_Cell17" TEXT,
    "Cells_Cell18" TEXT,
    "Cells_Cell19" TEXT,
    "Cells_Cell20" TEXT,
    "Cells_Cell21" TEXT,
    "Cells_Cell22" TEXT,
    "Cells_Cell23" TEXT,
    "Cells_Cell24" TEXT,
    "Cells_Cell25" TEXT,
    "Cells_Cell26" TEXT,
    "Cells_Cell27" TEXT,
    "Cells_Cell28" TEXT,
    "Cells_Cell29" TEXT,
    "Cells_Cell30" TEXT,
    "Cells_Cell31" TEXT,
    "Cells_Cell32" TEXT,
    "Cells_Cell33" TEXT,
    "Cells_Cell34" TEXT,
    "Cells_Cell35" TEXT,
    "Cells_Cell36" TEXT,
    "Cells_Cell37" TEXT,
    "Cells_Cell38" TEXT,
    "Cells_Cell39" TEXT,
    "Cells_Cell40" TEXT,
    "IsNew" BOOLEAN NOT NULL,
    "UncommittedCells_Cell1" TEXT,
    "UncommittedCells_Cell2" TEXT,
    "UncommittedCells_Cell3" TEXT,
    "UncommittedCells_Cell4" TEXT,
    "UncommittedCells_Cell5" TEXT,
    "UncommittedCells_Cell6" TEXT,
    "UncommittedCells_Cell7" TEXT,
    "UncommittedCells_Cell8" TEXT,
    "UncommittedCells_Cell9" TEXT,
    "UncommittedCells_Cell10" TEXT,
    "UncommittedCells_Cell11" TEXT,
    "UncommittedCells_Cell12" TEXT,
    "UncommittedCells_Cell13" TEXT,
    "UncommittedCells_Cell14" TEXT,
    "UncommittedCells_Cell15" TEXT,
    "UncommittedCells_Cell16" TEXT,
    "UncommittedCells_Cell17" TEXT,
    "UncommittedCells_Cell18" TEXT,
    "UncommittedCells_Cell19" TEXT,
    "UncommittedCells_Cell20" TEXT,
    "UncommittedCells_Cell21" TEXT,
    "UncommittedCells_Cell22" TEXT,
    "UncommittedCells_Cell23" TEXT,
    "UncommittedCells_Cell24" TEXT,
    "UncommittedCells_Cell25" TEXT,
    "UncommittedCells_Cell26" TEXT,
    "UncommittedCells_Cell27" TEXT,
    "UncommittedCells_Cell28" TEXT,
    "UncommittedCells_Cell29" TEXT,
    "UncommittedCells_Cell30" TEXT,
    "UncommittedCells_Cell31" TEXT,
    "UncommittedCells_Cell32" TEXT,
    "UncommittedCells_Cell33" TEXT,
    "UncommittedCells_Cell34" TEXT,
    "UncommittedCells_Cell35" TEXT,
    "UncommittedCells_Cell36" TEXT,
    "UncommittedCells_Cell37" TEXT,
    "UncommittedCells_Cell38" TEXT,
    "UncommittedCells_Cell39" TEXT,
    "UncommittedCells_Cell40" TEXT,
    CONSTRAINT "PK_Row" PRIMARY KEY ("Id")
);

CREATE TABLE "TableRuleDesigner"."Revision" (
    "Id" UUID DEFAULT gen_random_uuid(),
    "Type" INTEGER NOT NULL,
    "Timestamp" TIMESTAMPTZ NOT NULL,
    "UserName" VARCHAR(255) NOT NULL,
    "UserEmail" VARCHAR(255) NOT NULL,
    "Property" VARCHAR(1000),
    "OldValue" TEXT,
    "Value" TEXT,
    "ResourceId" UUID NOT NULL,
    "ResourceName" VARCHAR(1000) NOT NULL,
    "ParentRevisionId" UUID,
    "IsAction" BOOLEAN NOT NULL,
    "ResourceType" VARCHAR(255),
    CONSTRAINT "PK_Revision" PRIMARY KEY ("Id")
);

CREATE INDEX "IX_Revision_ParentRevisionId"
    ON "TableRuleDesigner"."Revision" ("ParentRevisionId");

CREATE INDEX "IX_Row_RowReferenceId"
    ON "TableRuleDesigner"."Row" ("TableRuleRowReferenceId");

CREATE TABLE "TableRuleDesigner"."DatabaseVersion" (
    "Id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "Version" BIGINT
);
