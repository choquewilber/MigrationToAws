-- SCHEMAS
CREATE SCHEMA "Bus";
CREATE SCHEMA "FailoverMaintainer";

-- TABLES

CREATE TABLE "DatabaseVersion" (
 "Id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
 "Version" BIGINT
);

CREATE TABLE "Bus"."DataBus" (
    "Id" VARCHAR(200),
    "Meta" BYTEA,
    "Data" BYTEA,
    "CreationTime" TIMESTAMPTZ,
    "LastReadTime" TIMESTAMPTZ
);

CREATE TABLE "Tenant" (
    "Id" UUID,
    "Name" VARCHAR(255),
    "Domain" VARCHAR(255),
    "ActiveDomain" VARCHAR(255) NOT NULL,
    "AzureAdTenantId" VARCHAR(255),
    "ApiKey" VARCHAR(255),
    "DesignerDatabasePoolName" VARCHAR(255),
    "RuntimeDatabasePoolName" VARCHAR(255),
    CONSTRAINT "PK_Tenant" PRIMARY KEY ("Id")
);

CREATE TABLE "TenantRoleMap" (
    "Id" UUID,
    "GroupId" VARCHAR(255) NOT NULL,
    "TenantId" UUID NOT NULL,
    "RoleId" UUID,
    CONSTRAINT "PK_TenantRoleMap" PRIMARY KEY ("Id")
);

CREATE TABLE "Application" (
    "Id" UUID,
    "TenantId" UUID NOT NULL,
    "Name" VARCHAR(255),
    "Domain" VARCHAR(255),
    "ActiveDomain" VARCHAR(255) NOT NULL,
    "IsProvisioningCompleted" BOOLEAN NOT NULL,
    "Priority" INT NOT NULL,
    "RepositoryEnabled" BOOLEAN DEFAULT FALSE,
    "RepositoryId" UUID,
    CONSTRAINT "PK_Application" PRIMARY KEY ("Id")
);

CREATE TABLE "ApplicationBusinessUsageInformation" (
    "Id" UUID,
    "ApplicationId" UUID,
    "Purpose" TEXT,
    "Consumers" TEXT,
    CONSTRAINT "PK_ApplicationBusinessUsageInformation" PRIMARY KEY ("Id")
);

CREATE TABLE "ApplicationContact" (
    "Id" UUID,
    "UserId" VARCHAR(255) NOT NULL,
    "ApplicationId" UUID NOT NULL,
    "Note" TEXT,
    "IsNonProduction" BOOLEAN DEFAULT TRUE,
    "IsProduction" BOOLEAN DEFAULT FALSE,
    CONSTRAINT "PK_ApplicationContact" PRIMARY KEY ("Id")
);

CREATE TABLE "ExperimentalFeature" (
    "Id" UUID,
    "Name" VARCHAR(255) NOT NULL,
    CONSTRAINT "PK_ExperimentalFeature" PRIMARY KEY ("Id")
);

CREATE TABLE "ApplicationExperimentalFeature" (
    "ApplicationId" UUID NOT NULL,
    "ExperimentalFeatureId" UUID NOT NULL,
    CONSTRAINT "PK_ApplicationExperimentalFeature" PRIMARY KEY ("ApplicationId", "ExperimentalFeatureId")
);

CREATE TABLE "ApplicationIdentity" (
    "Id" UUID,
    "TenantId" UUID NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    "Key" VARCHAR(255) NOT NULL,
    "Secret" VARCHAR(255) NOT NULL,
    CONSTRAINT "PK_ApplicationIdentity" PRIMARY KEY ("Id")
);

CREATE TABLE "ApplicationProvisioningState" (
    "Id" UUID,
    "ApplicationId" UUID NOT NULL,
    "IsDatabaseCreated" BOOLEAN NOT NULL,
    "Failed" BOOLEAN NOT NULL,
    "IsSchemaCreated" BOOLEAN NOT NULL,
    "CreatedDateTime" TIMESTAMPTZ NOT NULL,
    CONSTRAINT "PK_ApplicationProvisioningState" PRIMARY KEY ("Id")
);

CREATE TABLE "ApplicationRoleMap" (
    "Id" UUID,
    "GroupId" VARCHAR(255) NOT NULL,
    "ApplicationId" UUID NOT NULL,
    "RoleId" UUID,
    "ModuleId" UUID,
    CONSTRAINT "PK_ApplicationRoleMap" PRIMARY KEY ("Id")
);

CREATE TABLE "ApplicationScopingContext" (
    "Id" UUID,
    "ContextId" UUID NOT NULL,
    "Key" VARCHAR(1024) NOT NULL,
    "ContextData" TEXT NOT NULL,
    "Updated" TIMESTAMP NOT NULL,
    CONSTRAINT "PK_ApplicationScopingContext" PRIMARY KEY ("Id")
);

CREATE TABLE "ApplicationScopingEvent" (
    "Id" UUID,
    "SequenceNumber" SERIAL NOT NULL,
    "EventType" VARCHAR(200) NOT NULL,
    "PayLoad" TEXT NOT NULL,
    "Written" TIMESTAMP NOT NULL,
    CONSTRAINT "PK_ApplicationScopingEvent" PRIMARY KEY ("Id")
);

CREATE TABLE "AuditLoggerConfig" (
    "Id" UUID,
    "Owner" UUID NOT NULL,
    "Type" VARCHAR(255) NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    "SplunkUsername" VARCHAR(255),
    "SplunkPassword" VARCHAR(255),
    "SplunkSource" VARCHAR(255),
    "SplunkIndex" VARCHAR(255),
    "SplunkHost" VARCHAR(255),
    "SplunkPort" INT,
    "UseForAudit" BOOLEAN DEFAULT FALSE,
    "UseForRuntime" BOOLEAN DEFAULT FALSE,
    "IgnoreSslErrors" BOOLEAN NOT NULL,
    "SplunkToken" VARCHAR(1000),
    "MinimumLevel" INT NOT NULL,
    "QueueLimit" INT NOT NULL,
    CONSTRAINT "PK_AuditLogConfig" PRIMARY KEY ("Id")
);

CREATE TABLE "AzureAuthenticationSetting" (
    "Id" UUID,
    "TenantId" UUID NOT NULL,
    "Name" VARCHAR(3000) NOT NULL,
    "Domain" VARCHAR(255),
    "TargetTenantId" VARCHAR(255),
    "ClientId" VARCHAR(255),
    "ResourceId" VARCHAR(255),
    "AppKey" VARCHAR(255),
    CONSTRAINT "PK_AzureAuthenticationSetting" PRIMARY KEY ("Id")
);

CREATE TABLE "Changeset" (
    "Id" UUID,
    "ApplicationId" UUID NOT NULL,
    "Name" VARCHAR(255),
    "IsMigrated" BOOLEAN NOT NULL,
    "IsProvisioned" BOOLEAN NOT NULL,
    "ProvisionedFailed" BOOLEAN NOT NULL,
    "ParentId" UUID,
    "Order" BIGINT NOT NULL,
    "CreationDate" TIMESTAMP NOT NULL,
    "CloneSucceeded" BOOLEAN,
    "CloningStep" INT,
    "ChangesetType" INT NOT NULL,
    "CreatorId" UUID,
    "CreatorName" VARCHAR(255),
    "CreatorEmail" VARCHAR(255),
    CONSTRAINT "PK_Changeset" PRIMARY KEY ("Id")
);

CREATE TABLE "ChangesetInitiative" (
    "Id" UUID,
    "InitiativeLink" VARCHAR(255),
    "ChangePrefix" VARCHAR(255),
    "CreationDate" TIMESTAMP NOT NULL,
    CONSTRAINT "PK_ChangesetInitiative" PRIMARY KEY ("Id")
);

CREATE TABLE "ChangesetLock" (
    "Id" SERIAL,
    "LockReason" INT NOT NULL,
    "OwnerId" UUID NOT NULL,
    CONSTRAINT "PK_ChangesetLock" PRIMARY KEY ("Id")
);

CREATE TABLE "ChangesetLockDetail" (
    "Id" SERIAL,
    "ChangesetLockId" INT NOT NULL,
    "ChangesetId" UUID NOT NULL,
    CONSTRAINT "PK_ChangesetLockDetail" PRIMARY KEY ("Id")
);

CREATE TABLE "ChangesetRoleMap" (
    "Id" UUID,
    "GroupId" VARCHAR(255),
    "ApplicationId" UUID NOT NULL,
    "ChangesetId" UUID NOT NULL,
    "RoleId" UUID,
    "ApplicationIdentity" VARCHAR(255),
    CONSTRAINT "PK_ChangesetRoleMap" PRIMARY KEY ("Id")
);

CREATE TABLE "DatabasePool" (
    "Id" UUID,
    "Name" VARCHAR(255) NOT NULL,
    "eDTUs" INT NOT NULL,
    "Capacity" INT NOT NULL,
    "FillFactor" INT NOT NULL,
    "Edition" INT NOT NULL,
    CONSTRAINT "PK_DatabasePool" PRIMARY KEY ("Id")
);

CREATE TABLE "DatabasePoolConfiguration" (
    "Id" UUID,
    "PoolName" VARCHAR(255) NOT NULL,
    "DatabaseType" INT NOT NULL,
    "TenantName" VARCHAR(255) NOT NULL,
    "TargetPriority" INT NOT NULL,
    CONSTRAINT "PK_DatabasePoolConfiguration" PRIMARY KEY ("Id")
);

CREATE TABLE "DeploymentNotificationConfig" (
    "Id" UUID,
    "TenantId" UUID NOT NULL,
    "Name" VARCHAR(250) NOT NULL,
    "Type" VARCHAR(100) NOT NULL,
    "EnvironmentPathPattern" VARCHAR(250),
    "ApplicationPathPattern" VARCHAR(250),
    "WebHookUrl" VARCHAR(250),
    CONSTRAINT "PK_DeploymentNotificationConfig" PRIMARY KEY ("Id")
);

CREATE TABLE "InputValidationItem" (
    "Id" SERIAL,
    "InputValidationType" INT NOT NULL,
    "Value" VARCHAR(5) NOT NULL,
    CONSTRAINT "PK_InputValidationItem" PRIMARY KEY ("Id")
);

CREATE TABLE "LongRunningOperation" (
    "Id" UUID,
    "ChangesetId" UUID NOT NULL,
    "Type" INT NOT NULL,
    "Status" INT NOT NULL,
    CONSTRAINT "PK_LongRunningOperation" PRIMARY KEY ("Id")
);

CREATE TABLE "OngoingEventMessages" (
    "Id" UUID,
    "ChangesetId" UUID NOT NULL,
    "CorrelationId" UUID NOT NULL,
    "MessageType" VARCHAR(255) NOT NULL,
    "DateTime" TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    CONSTRAINT "PK_OngoingEventMessages" PRIMARY KEY ("Id")
);

CREATE TABLE "SensitiveName" (
    "Id" UUID,
    "Value" VARCHAR(250) NOT NULL,
    "ComparisonType" INT NOT NULL,
    "ScopeType" INT NOT NULL,
    CONSTRAINT "PK_SensitiveName" PRIMARY KEY ("Id")
);

CREATE TABLE "FailoverMaintainer"."FailoverGroupDatabases" (
    "Id" SERIAL,
    "FailoverGroupId" VARCHAR(25) NOT NULL,
    "DatabaseName" VARCHAR(250) NOT NULL,
    "DatabaseOwnerName" VARCHAR(250) NOT NULL,
    "DatabaseOwnerId" VARCHAR(250),
    "CreatedAt" TIMESTAMPTZ NOT NULL,
    CONSTRAINT "PK_FailoverGroupDatabases" PRIMARY KEY ("Id")
);

CREATE TABLE "FailoverMaintainer"."SchemaVersions" (
    "Id" SERIAL,
    "ScriptName" VARCHAR(255) NOT NULL,
    "Applied" TIMESTAMP NOT NULL,
    CONSTRAINT "PK_SchemaVersions" PRIMARY KEY ("Id")
);

CREATE INDEX "IX_FailoverMaintainer_FailoverGroupDatabases" 
    ON "FailoverMaintainer"."FailoverGroupDatabases" ("FailoverGroupId", "DatabaseName") 
    INCLUDE ("DatabaseOwnerName", "DatabaseOwnerId", "CreatedAt");
