-- FOREIGN KEYS

ALTER TABLE "TenantRoleMap"
    ADD CONSTRAINT "FK_TenantRoleMap_Tenant" FOREIGN KEY ("TenantId") REFERENCES "Tenant"("Id") ON DELETE CASCADE;

ALTER TABLE "ApplicationBusinessUsageInformation"
    ADD CONSTRAINT "FK_ApplicationBusinessUsageInformation_Application" FOREIGN KEY ("ApplicationId") REFERENCES "Application"("Id") ON DELETE CASCADE;

ALTER TABLE "ApplicationContact"
    ADD CONSTRAINT "FK_ApplicationContact_Application" FOREIGN KEY ("ApplicationId") REFERENCES "Application"("Id") ON DELETE CASCADE;

ALTER TABLE "ApplicationExperimentalFeature"
    ADD CONSTRAINT "FK_Application_ExperimentalFeature" FOREIGN KEY ("ApplicationId") REFERENCES "Application"("Id") ON DELETE CASCADE;

ALTER TABLE "ApplicationExperimentalFeature"
    ADD CONSTRAINT "FK_ExperimentalFeature_Application" FOREIGN KEY ("ExperimentalFeatureId") REFERENCES "ExperimentalFeature"("Id") ON DELETE CASCADE;

ALTER TABLE "ApplicationIdentity"
    ADD CONSTRAINT "FK_ApplicationIdentity_Tenant" FOREIGN KEY ("TenantId") REFERENCES "Tenant"("Id") ON DELETE CASCADE;

ALTER TABLE "ApplicationProvisioningState"
    ADD CONSTRAINT "FK_ApplicationProvisioningState_Application" FOREIGN KEY ("ApplicationId") REFERENCES "Application"("Id") ON DELETE CASCADE;

ALTER TABLE "ApplicationRoleMap"
    ADD CONSTRAINT "FK_ApplicationRoleMap_Application" FOREIGN KEY ("ApplicationId") REFERENCES "Application"("Id") ON DELETE CASCADE;

ALTER TABLE "Changeset"
    ADD CONSTRAINT "FK_Changeset_Application" FOREIGN KEY ("ApplicationId") REFERENCES "Application"("Id") ON DELETE CASCADE;

ALTER TABLE "ChangesetInitiative"
    ADD CONSTRAINT "FK_ChangesetInitiative_Changeset" FOREIGN KEY ("Id") REFERENCES "Changeset"("Id") ON DELETE CASCADE;

ALTER TABLE "ChangesetRoleMap"
    ADD CONSTRAINT "FK_ChangesetRoleMap_Application" FOREIGN KEY ("ApplicationId") REFERENCES "Application"("Id") ON DELETE CASCADE;

ALTER TABLE "ChangesetRoleMap"
    ADD CONSTRAINT "FK_ChangesetRoleMap_Changeset" FOREIGN KEY ("ChangesetId") REFERENCES "Changeset"("Id") ON DELETE CASCADE;

ALTER TABLE "ChangesetLockDetail"
    ADD CONSTRAINT "FK_ChangesetLockDetail_ChangesetLock" FOREIGN KEY ("ChangesetLockId") REFERENCES "ChangesetLock"("Id") ON DELETE CASCADE;

-- UNIQUE CONSTRAINTS

ALTER TABLE "Tenant"
    ADD CONSTRAINT "UQ_Tenant_ActiveDomain" UNIQUE ("ActiveDomain");

ALTER TABLE "ApplicationContact"
    ADD CONSTRAINT "UQ_ApplicationContact_ApplicationId_UserId" UNIQUE ("ApplicationId", "UserId");

ALTER TABLE "ApplicationScopingContext"
    ADD CONSTRAINT "UQ_ApplicationScopingContext_ContextId" UNIQUE ("ContextId");

ALTER TABLE "ApplicationScopingContext"
    ADD CONSTRAINT "UQ_ApplicationScopingContext_Key" UNIQUE ("Key");

ALTER TABLE "ChangesetLock"
    ADD CONSTRAINT "UQ_ChangesetLock_OwnerId" UNIQUE ("OwnerId");

ALTER TABLE "ChangesetLockDetail"
    ADD CONSTRAINT "UQ_ChangesetLockDetail_ChangesetId" UNIQUE ("ChangesetId");

ALTER TABLE "SensitiveName"
    ADD CONSTRAINT "UQ_SensitiveName_Value" UNIQUE ("Value");

ALTER TABLE "FailoverMaintainer"."FailoverGroupDatabases"
    ADD CONSTRAINT "UQ_FailoverGroupDatabases_DatabaseName" UNIQUE ("DatabaseName");
