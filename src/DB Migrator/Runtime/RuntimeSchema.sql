CREATE EXTENSION IF NOT EXISTS "pgcrypto";


CREATE SCHEMA IF NOT EXISTS azureservicebusconnectorruntime;

CREATE SCHEMA IF NOT EXISTS dashboardruntime;

CREATE SCHEMA IF NOT EXISTS dbo;

CREATE SCHEMA IF NOT EXISTS emailconnectorruntime;

CREATE SCHEMA IF NOT EXISTS endpointruntime;

CREATE SCHEMA IF NOT EXISTS filetransferconnectorruntime;

CREATE SCHEMA IF NOT EXISTS fixedwidthmappingruntime;

CREATE SCHEMA IF NOT EXISTS formruntime;

CREATE SCHEMA IF NOT EXISTS ftniconnectorruntime;

CREATE SCHEMA IF NOT EXISTS hipchatconnectorsruntime;

CREATE SCHEMA IF NOT EXISTS httpconnectorruntime;

CREATE SCHEMA IF NOT EXISTS mappingruntime;

CREATE SCHEMA IF NOT EXISTS modelruntime;

CREATE SCHEMA IF NOT EXISTS pdfmappingruntime;

CREATE SCHEMA IF NOT EXISTS platform;

CREATE SCHEMA IF NOT EXISTS processruntime;

-- ------------ Write CREATE-SEQUENCE-stage scripts -----------

CREATE SEQUENCE IF NOT EXISTS dbo.platform_applicationversion_sequence AS bigint
INCREMENT BY 1
START WITH 1
MAXVALUE 2147483647
MINVALUE 1
NO CYCLE
CACHE 5;

CREATE SEQUENCE IF NOT EXISTS dbo.platform_applicationversion_versionmajor AS bigint
INCREMENT BY 1
START WITH 1
MAXVALUE 2147483647
MINVALUE 1
NO CYCLE
CACHE 5;

CREATE SEQUENCE IF NOT EXISTS platform.valueset_valuesetreferenceid_sequence AS bigint
INCREMENT BY 1
START WITH 1
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

-- ------------ Write CREATE-TABLE-stage scripts -----------

CREATE TABLE azureservicebusconnectorruntime.azureservicebusconnectortemplate(
    id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    versionid UUID,
    resourcetypeid UUID,
    datetime TIMESTAMP(6) WITH TIME ZONE NOT NULL DEFAULT timezone('UTC', CURRENT_TIMESTAMP(6)),
    connectionstring TEXT,
    resourcename VARCHAR(255),
    serializedinputschema TEXT,
    serializedoutputschema TEXT,
    serializertype INTEGER NOT NULL DEFAULT (1),
    contenttype VARCHAR(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE azureservicebusconnectorruntime.databaseversion(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    version BIGINT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE azureservicebusconnectorruntime.failedazureservicebusmessage(
    id UUID NOT NULL,
    environmentid UUID NOT NULL,
    correlationid VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    connectionstring TEXT NOT NULL,
    resourcename VARCHAR(255) NOT NULL,
    serializertype INTEGER NOT NULL,
    contenttype VARCHAR(255) NOT NULL,
    exception TEXT NOT NULL,
    timestamp TIMESTAMP(6) WITH TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE azureservicebusconnectorruntime.templatemap(
    id UUID NOT NULL,
    templateid UUID NOT NULL,
    resourceid UUID NOT NULL,
    applicationversionid UUID NOT NULL,
    changesetid UUID NOT NULL,
    resourcestatus_lastmodified TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    type SMALLINT NOT NULL DEFAULT (1),
    resourcename VARCHAR(255),
    resourcetype VARCHAR(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE dashboardruntime.databaseversion(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    version BIGINT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE dashboardruntime.file(
    id UUID NOT NULL,
    resourcetypeid UUID NOT NULL,
    versionid UUID,
    path VARCHAR(255),
    content TEXT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE dashboardruntime.filerole(
    id UUID NOT NULL,
    versionid UUID,
    applicationroleid UUID NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE dashboardruntime.runtimeform(
    id UUID NOT NULL,
    actionid UUID NOT NULL,
    versionid UUID,
    clientcallback VARCHAR(255),
    environmentid UUID NOT NULL,
    callreferenceid UUID NOT NULL,
    mapid UUID NOT NULL,
    ownerid UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE dashboardruntime.templatemap(
    id UUID NOT NULL,
    templateid UUID NOT NULL,
    resourceid UUID NOT NULL,
    applicationversionid UUID NOT NULL,
    changesetid UUID NOT NULL,
    resourcestatus_lastmodified TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    type SMALLINT NOT NULL DEFAULT (1),
    resourcename VARCHAR(255),
    resourcetype VARCHAR(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE emailconnectorruntime.databaseversion(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    version BIGINT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE emailconnectorruntime.emailconnectortemplate(
    id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    versionid UUID,
    resourcetypeid UUID,
    datetime TIMESTAMP(6) WITH TIME ZONE NOT NULL DEFAULT timezone('UTC', CURRENT_TIMESTAMP(6)),
    serializedinputschema TEXT,
    serializedoutputschema TEXT,
    "To" TEXT,
    subject TEXT,
    bodymessage TEXT,
    sendername TEXT,
    replyto TEXT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE emailconnectorruntime.templatemap(
    id UUID NOT NULL,
    templateid UUID NOT NULL,
    resourceid UUID NOT NULL,
    applicationversionid UUID NOT NULL,
    changesetid UUID NOT NULL,
    resourcestatus_lastmodified TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    type SMALLINT NOT NULL DEFAULT (1),
    resourcename VARCHAR(255),
    resourcetype VARCHAR(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE endpointruntime.databaseversion(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    version BIGINT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE endpointruntime.endpointrole(
    id UUID NOT NULL,
    endpointtemplateid UUID NOT NULL,
    applicationroleid UUID NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE endpointruntime.endpointtemplate(
    id UUID NOT NULL,
    outputsettings_contenttype VARCHAR(255),
    name VARCHAR(255) NOT NULL,
    path VARCHAR(255) NOT NULL,
    inputsettings_method VARCHAR(255) NOT NULL,
    actionid UUID NOT NULL,
    owneractionid UUID NOT NULL,
    mapid UUID NOT NULL,
    versionid UUID,
    inputsettings_serializedschema TEXT NOT NULL,
    outputsettings_serializedschema TEXT NOT NULL,
    outputsettings_returnvaluesettingid UUID NOT NULL,
    inputsettings_returnvaluesettingid UUID NOT NULL,
    outputsettings_ignorenullvalues NUMERIC(1,0) NOT NULL,
    outputsettings_includetimeondatetype NUMERIC(1,0) NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE endpointruntime.templatemap(
    id UUID NOT NULL,
    templateid UUID NOT NULL,
    resourceid UUID NOT NULL,
    applicationversionid UUID NOT NULL,
    changesetid UUID NOT NULL,
    resourcestatus_lastmodified TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    type SMALLINT NOT NULL DEFAULT (1),
    resourcename VARCHAR(255),
    resourcetype VARCHAR(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE filetransferconnectorruntime.databaseversion(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    version BIGINT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE filetransferconnectorruntime.filetransferconnectorparametertemplate(
    id UUID NOT NULL,
    filetransferconnectorparameterid UUID NOT NULL,
    name VARCHAR(255),
    filetransferconnectortemplateid UUID,
    type INTEGER NOT NULL,
    isarray NUMERIC(1,0) NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE filetransferconnectorruntime.filetransferconnectortemplate(
    id UUID NOT NULL,
    filetransferconnectorid UUID NOT NULL,
    name VARCHAR(255),
    username VARCHAR(255),
    password VARCHAR(255),
    serveraddress VARCHAR(255),
    serverport TEXT,
    folderpath TEXT,
    usepassive NUMERIC(1,0),
    type INTEGER,
    serializedinputschema TEXT,
    serializedoutputschema TEXT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE filetransferconnectorruntime.templatemap(
    id UUID NOT NULL,
    templateid UUID NOT NULL,
    resourceid UUID NOT NULL,
    applicationversionid UUID NOT NULL,
    changesetid UUID NOT NULL,
    resourcestatus_lastmodified TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    type SMALLINT NOT NULL DEFAULT (1),
    resourcename VARCHAR(255),
    resourcetype VARCHAR(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE fixedwidthmappingruntime.databaseversion(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    version BIGINT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE fixedwidthmappingruntime.fixedwidthfieldtemplate(
    id UUID NOT NULL,
    actionid UUID NOT NULL,
    fixedwidthmaptemplateid UUID,
    name TEXT NOT NULL,
    type INTEGER NOT NULL,
    width INTEGER NOT NULL,
    "Order" BIGINT NOT NULL,
    format VARCHAR(255),
    isfiller NUMERIC(1,0) NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE fixedwidthmappingruntime.fixedwidthmaptemplate(
    id UUID NOT NULL,
    actionid UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    filename VARCHAR(255) NOT NULL,
    showscolumnheaders NUMERIC(1,0) NOT NULL,
    separator VARCHAR(255),
    serializedinputschema TEXT NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE fixedwidthmappingruntime.fixedwidthparametertemplate(
    id UUID NOT NULL,
    actionid UUID NOT NULL,
    fixedwidthmaptemplateid UUID,
    name TEXT NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE fixedwidthmappingruntime.templatemap(
    id UUID NOT NULL,
    templateid UUID NOT NULL,
    resourceid UUID NOT NULL,
    applicationversionid UUID NOT NULL,
    changesetid UUID NOT NULL,
    resourcestatus_lastmodified TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    type SMALLINT NOT NULL DEFAULT (1),
    resourcename VARCHAR(255),
    resourcetype VARCHAR(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE formruntime.databaseversion(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    version BIGINT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE ftniconnectorruntime.databaseversion(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    version BIGINT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE ftniconnectorruntime.errortranslationtemplate(
    id UUID NOT NULL,
    connectorid UUID NOT NULL,
    original VARCHAR(512),
    translated VARCHAR(512)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE ftniconnectorruntime.ftniclientinfo(
    id UUID NOT NULL,
    sessionid UUID NOT NULL,
    clientid VARCHAR(1024)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE ftniconnectorruntime.ftniconnectortemplate(
    id UUID NOT NULL,
    actionid UUID NOT NULL,
    versionid UUID,
    name VARCHAR(255),
    url VARCHAR(1024),
    username VARCHAR(255),
    password VARCHAR(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE ftniconnectorruntime.templatemap(
    id UUID NOT NULL,
    templateid UUID NOT NULL,
    resourceid UUID NOT NULL,
    applicationversionid UUID NOT NULL,
    changesetid UUID NOT NULL,
    resourcestatus_lastmodified TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    type SMALLINT NOT NULL DEFAULT (1),
    resourcename VARCHAR(255),
    resourcetype VARCHAR(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE hipchatconnectorsruntime.databaseversion(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    version BIGINT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE hipchatconnectorsruntime.hipchatconnectortemplate(
    id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    versionid UUID,
    resourcetypeid UUID,
    datetime TIMESTAMP(6) WITH TIME ZONE NOT NULL DEFAULT timezone('UTC', CURRENT_TIMESTAMP(6)),
    serializedinputschema TEXT,
    serializedoutputschema TEXT,
    roomid TEXT,
    apikey TEXT,
    message TEXT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE hipchatconnectorsruntime.hipchatcreateuserconnectortemplate(
    id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    versionid UUID,
    resourcetypeid UUID,
    datetime TIMESTAMP(6) WITH TIME ZONE NOT NULL DEFAULT timezone('UTC', CURRENT_TIMESTAMP(6)),
    serializedinputschema TEXT,
    serializedoutputschema TEXT,
    userfullname TEXT,
    email TEXT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE hipchatconnectorsruntime.templatemap(
    id UUID NOT NULL,
    templateid UUID NOT NULL,
    resourceid UUID NOT NULL,
    applicationversionid UUID NOT NULL,
    changesetid UUID NOT NULL,
    resourcestatus_lastmodified TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    type SMALLINT NOT NULL DEFAULT (1),
    resourcename VARCHAR(255),
    resourcetype VARCHAR(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE httpconnectorruntime.authenticationprovidertemplate(
    id UUID NOT NULL,
    httpconnectorid UUID NOT NULL,
    key VARCHAR(255),
    secret TEXT,
    discriminator VARCHAR(255) NOT NULL,
    tenantid VARCHAR(255),
    resourceid VARCHAR(255),
    clientid VARCHAR(255),
    appkey VARCHAR(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE httpconnectorruntime.customhttpheader(
    id UUID NOT NULL,
    httpconnectorid UUID NOT NULL,
    key VARCHAR(255) NOT NULL,
    value TEXT NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE httpconnectorruntime.databaseversion(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    version BIGINT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE httpconnectorruntime.duplicaterequeststorage(
    id UUID NOT NULL,
    instanceid UUID NOT NULL,
    xmldata XML NOT NULL,
    createdepoch BIGINT NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE httpconnectorruntime.httpconnectortemplate(
    id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    versionid UUID,
    resourcetypeid UUID,
    datetime TIMESTAMP(6) WITH TIME ZONE NOT NULL DEFAULT timezone('UTC', CURRENT_TIMESTAMP(6)),
    method INTEGER NOT NULL,
    customrequestcontenttype VARCHAR(255),
    url TEXT NOT NULL,
    serializedinputschema TEXT,
    serializedoutputschema TEXT,
    requestcontenttype INTEGER NOT NULL,
    usestatuscodefortimeout NUMERIC(1,0) NOT NULL,
    retrystrategy_retries INTEGER NOT NULL DEFAULT (0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE httpconnectorruntime.httpparameterkey(
    id UUID NOT NULL,
    httpconnectorid UUID NOT NULL,
    key VARCHAR(255) NOT NULL,
    parameterid UUID NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE httpconnectorruntime.templatemap(
    id UUID NOT NULL,
    templateid UUID NOT NULL,
    resourceid UUID NOT NULL,
    applicationversionid UUID NOT NULL,
    changesetid UUID NOT NULL,
    resourcestatus_lastmodified TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    type SMALLINT NOT NULL DEFAULT (1),
    resourcename VARCHAR(255),
    resourcetype VARCHAR(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE mappingruntime.actioninfo(
    id UUID NOT NULL,
    actionid UUID NOT NULL,
    versionid UUID,
    module VARCHAR(255) NOT NULL,
    serializedoutputschema TEXT NOT NULL,
    serializedinputschema TEXT NOT NULL,
    name VARCHAR(255) NOT NULL DEFAULT ''
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE mappingruntime.databaseversion(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    version BIGINT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE mappingruntime.fieldmap(
    id UUID NOT NULL,
    runtimemapid UUID NOT NULL,
    callerfieldid UUID NOT NULL,
    actionfieldid UUID NOT NULL,
    direction INTEGER NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE mappingruntime.runtimemap(
    id UUID NOT NULL,
    mapid UUID NOT NULL,
    versionid UUID,
    callerid UUID NOT NULL,
    actionid UUID NOT NULL,
    name VARCHAR(255) NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE mappingruntime.templatemap(
    id UUID NOT NULL,
    templateid UUID NOT NULL,
    resourceid UUID NOT NULL,
    applicationversionid UUID NOT NULL,
    changesetid UUID NOT NULL,
    resourcestatus_lastmodified TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    type SMALLINT NOT NULL DEFAULT (1),
    resourcename VARCHAR(255),
    resourcetype VARCHAR(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE modelruntime.databaseversion(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    version BIGINT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE modelruntime.modelinstance(
    id UUID NOT NULL,
    environmentid UUID NOT NULL,
    versionid UUID,
    typeid UUID NOT NULL,
    xmldata XML
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE modelruntime.runtimeschematype(
    id UUID NOT NULL,
    editid UUID NOT NULL,
    versionid UUID,
    name VARCHAR(255) NOT NULL,
    loadid UUID,
    serializedschema TEXT NOT NULL,
    entitymetaid UUID NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE modelruntime.templatemap(
    id UUID NOT NULL,
    templateid UUID NOT NULL,
    resourceid UUID NOT NULL,
    applicationversionid UUID NOT NULL,
    changesetid UUID NOT NULL,
    resourcestatus_lastmodified TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    type SMALLINT NOT NULL DEFAULT (1),
    resourcename VARCHAR(255),
    resourcetype VARCHAR(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE pdfmappingruntime.databaseversion(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    version BIGINT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE pdfmappingruntime.pdffilemaptemplate(
    id UUID NOT NULL,
    actionid UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    filecontent BYTEA,
    filename TEXT,
    filetype TEXT,
    possiblecheckboxyesvalues TEXT,
    possiblecheckboxnovalues TEXT,
    versionid UUID
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE pdfmappingruntime.pdfparametertemplate(
    id UUID NOT NULL,
    actionid UUID NOT NULL,
    pdffilemaptemplateid UUID,
    name TEXT NOT NULL,
    type INTEGER NOT NULL,
    fieldtype SMALLINT NOT NULL,
    versionid UUID
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE pdfmappingruntime.templatemap(
    id UUID NOT NULL,
    templateid UUID NOT NULL,
    resourceid UUID NOT NULL,
    applicationversionid UUID NOT NULL,
    changesetid UUID NOT NULL,
    resourcestatus_lastmodified TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    type SMALLINT NOT NULL DEFAULT (1),
    resourcename VARCHAR(255),
    resourcetype VARCHAR(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE platform.applicationrole(
    id UUID NOT NULL,
    name VARCHAR(255) NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE platform.applicationrolebyversion(
    id UUID NOT NULL,
    versionid UUID NOT NULL,
    roleid UUID NOT NULL,
    name VARCHAR(255) NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE platform.applicationversion(
    id UUID NOT NULL,
    sequenceid INTEGER,
    changesetid UUID,
    created TIMESTAMP(6) WITH TIME ZONE,
    completed TIMESTAMP(6) WITH TIME ZONE,
    byname VARCHAR(100),
    byemail VARCHAR(100),
    status SMALLINT NOT NULL DEFAULT (0),
    notes TEXT,
    changesetname VARCHAR(100),
    versionlabel VARCHAR(255),
    versiontype SMALLINT NOT NULL,
    sourceversionid UUID,
    changedresourcename VARCHAR(255),
    versionmajor INTEGER NOT NULL DEFAULT (0),
    versionminor INTEGER NOT NULL DEFAULT (0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE platform.databaseversion(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    version BIGINT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE platform.environment(
    id UUID NOT NULL,
    name VARCHAR(255),
    domain VARCHAR(255),
    activedomain VARCHAR(255) NOT NULL,
    activeversionid UUID,
    deployeddate TIMESTAMP(6) WITH TIME ZONE,
    isproduction NUMERIC(1,0) NOT NULL DEFAULT (0),
    ismigratedtodocumentdb NUMERIC(1,0) NOT NULL DEFAULT (0),
    debugenableddate TIMESTAMP(6) WITH TIME ZONE
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE platform.environmentapplicationrolemap(
    id UUID NOT NULL,
    groupid VARCHAR(255),
    environmentid UUID,
    roleid UUID,
    applicationidentity VARCHAR(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE platform.environmentdeployment(
    id UUID NOT NULL,
    environmentid UUID NOT NULL,
    versionid UUID NOT NULL,
    completed TIMESTAMP(6) WITH TIME ZONE,
    byname VARCHAR(255) NOT NULL,
    byemail VARCHAR(255) NOT NULL,
    started TIMESTAMP(6) WITH TIME ZONE,
    status INTEGER NOT NULL DEFAULT (0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE platform.environmentnotification(
    id UUID NOT NULL,
    enablenotification NUMERIC(1,0) NOT NULL,
    payload TEXT,
    endpoint TEXT,
    environmentid UUID NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE platform.environmentnotificationcustomhttpheader(
    id UUID NOT NULL,
    key TEXT,
    value TEXT,
    environmentnotificationid UUID NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE platform.environmentorigin(
    id UUID NOT NULL,
    origin VARCHAR(512) NOT NULL,
    environmentid UUID NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE platform.environmentrolemap(
    id UUID NOT NULL,
    groupid VARCHAR(255) NOT NULL,
    environmentid UUID,
    roleid UUID
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE platform.environmentvariablebyversion(
    id UUID NOT NULL,
    versionid UUID NOT NULL,
    variableid UUID NOT NULL,
    name VARCHAR(255) NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE platform.environmentvariabledefinition(
    id UUID NOT NULL,
    name VARCHAR(255),
    discontinued NUMERIC(1,0) NOT NULL DEFAULT (0),
    discontinueddate TIMESTAMP(6) WITH TIME ZONE,
    ispristine NUMERIC(1,0) NOT NULL DEFAULT (1)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE platform.environmentvariablevalue(
    id UUID NOT NULL,
    environmentvariableid UUID NOT NULL,
    value TEXT NOT NULL,
    environmentid UUID NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE platform.logevent(
    id UUID NOT NULL,
    message TEXT NOT NULL,
    timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    environmentid UUID NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE platform.valueset(
    id INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(255) NOT NULL,
    valuesetreferenceid INTEGER,
    deletedat TIMESTAMP(6) WITH TIME ZONE
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE platform.valuesetitem(
    id INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY,
    valuesetreferenceid INTEGER NOT NULL,
    value VARCHAR(255) NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE processruntime.databaseversion(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    version BIGINT
)
        WITH (
        OIDS=FALSE
        );

-- ------------ Write CREATE-INDEX-stage scripts -----------

CREATE INDEX ix_templatemap_applicationversionid_templateid
ON dashboardruntime.templatemap
USING BTREE (applicationversionid ASC, templateid ASC);

CREATE INDEX ix_templatemap_resourceid_resourcestatuslastmodified_includeall
ON dashboardruntime.templatemap
USING BTREE (resourceid ASC, resourcestatus_lastmodified ASC) INCLUDE(applicationversionid, changesetid, templateid);

CREATE INDEX ix_templatemap_applicationversionid_templateid
ON endpointruntime.templatemap
USING BTREE (applicationversionid ASC, templateid ASC);

CREATE INDEX ix_templatemap_resourceid_resourcestatuslastmodified_includeall
ON endpointruntime.templatemap
USING BTREE (resourceid ASC, resourcestatus_lastmodified ASC) INCLUDE(applicationversionid, changesetid, templateid);

CREATE INDEX ix_templatemap_applicationversionid_templateid
ON fixedwidthmappingruntime.templatemap
USING BTREE (applicationversionid ASC, templateid ASC);

CREATE INDEX ix_templatemap_resourceid_resourcestatuslastmodified_includeall
ON fixedwidthmappingruntime.templatemap
USING BTREE (resourceid ASC, resourcestatus_lastmodified ASC) INCLUDE(applicationversionid, changesetid, templateid);

CREATE INDEX ix_templatemap_applicationversionid_templateid
ON ftniconnectorruntime.templatemap
USING BTREE (applicationversionid ASC, templateid ASC);

CREATE INDEX ix_templatemap_resourceid_resourcestatuslastmodified_includeall
ON ftniconnectorruntime.templatemap
USING BTREE (resourceid ASC, resourcestatus_lastmodified ASC) INCLUDE(applicationversionid, changesetid, templateid);

CREATE INDEX ix_runtimemapid
ON mappingruntime.fieldmap
USING BTREE (runtimemapid ASC) INCLUDE(callerfieldid, actionfieldid, direction);

CREATE INDEX ix_runtimemap_versionid
ON mappingruntime.runtimemap
USING BTREE (versionid ASC);

CREATE INDEX ix_templatemap_applicationversionid_templateid
ON mappingruntime.templatemap
USING BTREE (applicationversionid ASC, templateid ASC);

CREATE INDEX ix_templatemap_resourceid_resourcestatuslastmodified_includeall
ON mappingruntime.templatemap
USING BTREE (resourceid ASC, resourcestatus_lastmodified ASC) INCLUDE(applicationversionid, changesetid, templateid);

CREATE INDEX ix_environmentid_typeid_includexmldata
ON modelruntime.modelinstance
USING BTREE (environmentid ASC, typeid ASC) INCLUDE(xmldata);

CREATE INDEX ix_modelinstance_environmentid_index
ON modelruntime.modelinstance
USING BTREE (id ASC, environmentid ASC);

CREATE INDEX ix_typeid_environmentid
ON modelruntime.modelinstance
USING BTREE (environmentid ASC, typeid ASC);

--CREATE INDEX modelruntime_modelinstance_xmldata_primaryindex
--ON modelruntime.modelinstance
--USING BTREE (xmldata ASC);

--CREATE INDEX modelruntime_modelinstance_xmldata_secondaryindex
--ON modelruntime.modelinstance
--USING BTREE (xmldata ASC);

CREATE INDEX ix_templatemap_applicationversionid_templateid
ON modelruntime.templatemap
USING BTREE (applicationversionid ASC, templateid ASC);

CREATE INDEX ix_templatemap_resourceid_resourcestatuslastmodified_includeall
ON modelruntime.templatemap
USING BTREE (resourceid ASC, resourcestatus_lastmodified ASC) INCLUDE(applicationversionid, changesetid, templateid);

CREATE INDEX ix_templatemap_applicationversionid_templateid
ON pdfmappingruntime.templatemap
USING BTREE (applicationversionid ASC, templateid ASC);

CREATE INDEX ix_templatemap_resourceid_resourcestatuslastmodified_includeall
ON pdfmappingruntime.templatemap
USING BTREE (resourceid ASC, resourcestatus_lastmodified ASC) INCLUDE(applicationversionid, changesetid, templateid);

CREATE UNIQUE INDEX uq_environmentvariablevalue_environmentid_environmentvariableid
ON platform.environmentvariablevalue
USING BTREE (environmentid ASC, environmentvariableid ASC);

-- ------------ Write CREATE-CONSTRAINT-stage scripts -----------

ALTER TABLE azureservicebusconnectorruntime.azureservicebusconnectortemplate
ADD CONSTRAINT pk_azureservicebusconnectortemplate_1669580986 PRIMARY KEY (id);

ALTER TABLE azureservicebusconnectorruntime.databaseversion
ADD CONSTRAINT pk__database__3214ec0722caf3d8 PRIMARY KEY (id);

ALTER TABLE azureservicebusconnectorruntime.failedazureservicebusmessage
ADD CONSTRAINT pk_failedazureservicebusmessage_1781581385 PRIMARY KEY (id);

ALTER TABLE azureservicebusconnectorruntime.templatemap
ADD CONSTRAINT pk_azureservicebusconnectorstemplatemap_1717581157 PRIMARY KEY (id);

ALTER TABLE dashboardruntime.databaseversion
ADD CONSTRAINT pk__database__3214ec0730fde354 PRIMARY KEY (id);

ALTER TABLE dashboardruntime.file
ADD CONSTRAINT pk_file_2099048 PRIMARY KEY (id);

ALTER TABLE dashboardruntime.filerole
ADD CONSTRAINT pk_filerole_130099504 PRIMARY KEY (id);

ALTER TABLE dashboardruntime.runtimeform
ADD CONSTRAINT pk_runtimeform_2021582240 PRIMARY KEY (id);

ALTER TABLE dashboardruntime.templatemap
ADD CONSTRAINT pk_templatemap_226099846 PRIMARY KEY (id);

ALTER TABLE emailconnectorruntime.databaseversion
ADD CONSTRAINT pk__database__3214ec07654e43ba PRIMARY KEY (id);

ALTER TABLE emailconnectorruntime.emailconnectortemplate
ADD CONSTRAINT pk_emailconnectortemplate_322100188 PRIMARY KEY (id);

ALTER TABLE emailconnectorruntime.templatemap
ADD CONSTRAINT pk_emailconnectorstemplatemap_370100359 PRIMARY KEY (id);

ALTER TABLE endpointruntime.databaseversion
ADD CONSTRAINT pk__database__3214ec0735a44e9f PRIMARY KEY (id);

ALTER TABLE endpointruntime.endpointrole
ADD CONSTRAINT pk_endpointrole_546100986 PRIMARY KEY (id);

ALTER TABLE endpointruntime.endpointtemplate
ADD CONSTRAINT pk_endpointtemplate_466100701 PRIMARY KEY (id);

ALTER TABLE endpointruntime.templatemap
ADD CONSTRAINT pk_templatemap_594101157 PRIMARY KEY (id);

ALTER TABLE filetransferconnectorruntime.databaseversion
ADD CONSTRAINT pk__database__3214ec077bd11ffe PRIMARY KEY (id);

ALTER TABLE filetransferconnectorruntime.filetransferconnectorparametertemplate
ADD CONSTRAINT pk_filetransferconnectorparametertemplate_1218103380 PRIMARY KEY (id);

ALTER TABLE filetransferconnectorruntime.filetransferconnectortemplate
ADD CONSTRAINT pk_ftpconnectortemplate_1186103266 PRIMARY KEY (id);

ALTER TABLE filetransferconnectorruntime.templatemap
ADD CONSTRAINT pk_filetransferconnectortemplatemap_1266103551 PRIMARY KEY (id);

ALTER TABLE fixedwidthmappingruntime.databaseversion
ADD CONSTRAINT pk__database__3214ec0735245665 PRIMARY KEY (id);

ALTER TABLE fixedwidthmappingruntime.fixedwidthfieldtemplate
ADD CONSTRAINT pk_fixedwidthfieldtemplate_738101670 PRIMARY KEY (id);

ALTER TABLE fixedwidthmappingruntime.fixedwidthmaptemplate
ADD CONSTRAINT pk_fixedwidthmaptemplate_706101556 PRIMARY KEY (id);

ALTER TABLE fixedwidthmappingruntime.fixedwidthparametertemplate
ADD CONSTRAINT pk_fixedwidthparametertemplate_786101841 PRIMARY KEY (id);

ALTER TABLE fixedwidthmappingruntime.templatemap
ADD CONSTRAINT pk_templatemap_834102012 PRIMARY KEY (id);

ALTER TABLE formruntime.databaseversion
ADD CONSTRAINT pk__database__3214ec073fc63177 PRIMARY KEY (id);

ALTER TABLE ftniconnectorruntime.databaseversion
ADD CONSTRAINT pk__database__3214ec07903c738d PRIMARY KEY (id);

ALTER TABLE ftniconnectorruntime.errortranslationtemplate
ADD CONSTRAINT pk_errortranslationtemplate_1042102753 PRIMARY KEY (id);

ALTER TABLE ftniconnectorruntime.ftniclientinfo
ADD CONSTRAINT pk_ftniclientinfo_1010102639 PRIMARY KEY (id);

ALTER TABLE ftniconnectorruntime.ftniconnectortemplate
ADD CONSTRAINT pk_ftniconnectortemplate_978102525 PRIMARY KEY (id);

ALTER TABLE ftniconnectorruntime.templatemap
ADD CONSTRAINT pk_templatemap_1090102924 PRIMARY KEY (id);

ALTER TABLE hipchatconnectorsruntime.databaseversion
ADD CONSTRAINT pk__database__3214ec072e47227d PRIMARY KEY (id);

ALTER TABLE hipchatconnectorsruntime.hipchatconnectortemplate
ADD CONSTRAINT pk_hipchatconnectortemplate_1362103893 PRIMARY KEY (id);

ALTER TABLE hipchatconnectorsruntime.hipchatcreateuserconnectortemplate
ADD CONSTRAINT pk_hipchatcreateuserconnectortemplate_1410104064 PRIMARY KEY (id);

ALTER TABLE hipchatconnectorsruntime.templatemap
ADD CONSTRAINT pk_templatemap_1458104235 PRIMARY KEY (id);

ALTER TABLE httpconnectorruntime.authenticationprovidertemplate
ADD CONSTRAINT pk_authenticationprovidertemplate_1698105090 PRIMARY KEY (id);

ALTER TABLE httpconnectorruntime.customhttpheader
ADD CONSTRAINT pk_customhttpheader_1650104919 PRIMARY KEY (id);

ALTER TABLE httpconnectorruntime.databaseversion
ADD CONSTRAINT pk__database__3214ec070cdcd385 PRIMARY KEY (id);

ALTER TABLE httpconnectorruntime.duplicaterequeststorage
ADD CONSTRAINT pk_duplicaterequeststorage_1746105261 PRIMARY KEY (id);

ALTER TABLE httpconnectorruntime.httpconnectortemplate
ADD CONSTRAINT pk_httpconnectortemplate_1554104577 PRIMARY KEY (id);

ALTER TABLE httpconnectorruntime.httpparameterkey
ADD CONSTRAINT pk_httpparameterkey_1602104748 PRIMARY KEY (id);

ALTER TABLE httpconnectorruntime.templatemap
ADD CONSTRAINT pk_azureservicebusconnectorstemplatemap_1778105375 PRIMARY KEY (id);

ALTER TABLE mappingruntime.actioninfo
ADD CONSTRAINT pk_actioninfo_1906105831 PRIMARY KEY (id);

ALTER TABLE mappingruntime.databaseversion
ADD CONSTRAINT pk__database__3214ec07a3aec6f3 PRIMARY KEY (id);

ALTER TABLE mappingruntime.fieldmap
ADD CONSTRAINT pk_fieldmap_1954106002 PRIMARY KEY (id);

ALTER TABLE mappingruntime.runtimemap
ADD CONSTRAINT pk_runtimemap_1986106116 PRIMARY KEY (id);

ALTER TABLE mappingruntime.templatemap
ADD CONSTRAINT pk_templatemap_2082106458 PRIMARY KEY (id);

ALTER TABLE modelruntime.databaseversion
ADD CONSTRAINT pk__database__3214ec07d4b1ea4f PRIMARY KEY (id);

ALTER TABLE modelruntime.modelinstance
ADD CONSTRAINT pk_modelinstance_30623152 PRIMARY KEY (id);

ALTER TABLE modelruntime.runtimeschematype
ADD CONSTRAINT pk_runtimeschematype_62623266 PRIMARY KEY (id);

ALTER TABLE modelruntime.templatemap
ADD CONSTRAINT pk_templatemap_158623608 PRIMARY KEY (id);

ALTER TABLE pdfmappingruntime.databaseversion
ADD CONSTRAINT pk__database__3214ec078e11ec5f PRIMARY KEY (id);

ALTER TABLE pdfmappingruntime.pdffilemaptemplate
ADD CONSTRAINT pk_pdfmappingpdffilemaptemplate_254623950 PRIMARY KEY (id);

ALTER TABLE pdfmappingruntime.pdfparametertemplate
ADD CONSTRAINT pk_pdfmappingpdfparametertemplate_286624064 PRIMARY KEY (id);

ALTER TABLE pdfmappingruntime.templatemap
ADD CONSTRAINT pk_templatemap_334624235 PRIMARY KEY (id);

ALTER TABLE platform.applicationrole
ADD CONSTRAINT pk_applicationrole_949578421 PRIMARY KEY (id);

ALTER TABLE platform.applicationrolebyversion
ADD CONSTRAINT pk_applicationrolebyversion_1205579333 PRIMARY KEY (id);

ALTER TABLE platform.applicationversion
ADD CONSTRAINT pk_version_1045578763 PRIMARY KEY (id);

ALTER TABLE platform.applicationversion
ADD CONSTRAINT unique_platform_applicationversion_sequenceid_1397580017 UNIQUE (sequenceid);

ALTER TABLE platform.databaseversion
ADD CONSTRAINT pk__database__3214ec07e699404c PRIMARY KEY (id);

ALTER TABLE platform.environment
ADD CONSTRAINT pk_environment_677577452 PRIMARY KEY (id);

ALTER TABLE platform.environmentapplicationrolemap
ADD CONSTRAINT pk_environmentapplicationrolemap_1285579618 PRIMARY KEY (id);

ALTER TABLE platform.environmentdeployment
ADD CONSTRAINT pk_environmentdeployment_885578193 PRIMARY KEY (id);

ALTER TABLE platform.environmentnotification
ADD CONSTRAINT pk_environmentnotification_1525580473 PRIMARY KEY (id);

ALTER TABLE platform.environmentnotificationcustomhttpheader
ADD CONSTRAINT pk_environmentnotificationcustomhttpheader_1573580644 PRIMARY KEY (id);

ALTER TABLE platform.environmentorigin
ADD CONSTRAINT pk_environmentorigin_981578535 PRIMARY KEY (id);

ALTER TABLE platform.environmentrolemap
ADD CONSTRAINT pk_environmentrolemap_725577623 PRIMARY KEY (id);

ALTER TABLE platform.environmentvariablebyversion
ADD CONSTRAINT pk_environmentvariablebyversion_1157579162 PRIMARY KEY (id);

ALTER TABLE platform.environmentvariabledefinition
ADD CONSTRAINT pk_environmentvariable_773577794 PRIMARY KEY (id);

ALTER TABLE platform.environmentvariabledefinition
ADD CONSTRAINT uq_envinronmentvariablename_917578307 UNIQUE (name);

ALTER TABLE platform.environmentvariablevalue
ADD CONSTRAINT pk_environmentvariablevalue_821577965 PRIMARY KEY (id);

ALTER TABLE platform.logevent
ADD CONSTRAINT pk_logevent_645577338 PRIMARY KEY (id);

ALTER TABLE platform.valueset
ADD CONSTRAINT pk_valueset_1461580245 PRIMARY KEY (id);

ALTER TABLE platform.valuesetitem
ADD CONSTRAINT pk_valuesetitem_1493580359 PRIMARY KEY (id, valuesetreferenceid);

ALTER TABLE processruntime.databaseversion
ADD CONSTRAINT pk__database__3214ec07b8b3e241 PRIMARY KEY (id);

-- ------------ Write CREATE-FOREIGN-KEY-CONSTRAINT-stage scripts -----------

ALTER TABLE endpointruntime.endpointrole
ADD CONSTRAINT fk_endpointrole_endpointtemplate_562101043 FOREIGN KEY (endpointtemplateid) 
REFERENCES endpointruntime.endpointtemplate (id)
ON UPDATE NO ACTION
ON DELETE CASCADE;

ALTER TABLE filetransferconnectorruntime.filetransferconnectorparametertemplate
ADD CONSTRAINT fk_filetransferconnectorparametertemplate_filetransferconnectortemplate_1234103437 FOREIGN KEY (filetransferconnectortemplateid) 
REFERENCES filetransferconnectorruntime.filetransferconnectortemplate (id)
ON UPDATE NO ACTION
ON DELETE CASCADE;

ALTER TABLE fixedwidthmappingruntime.fixedwidthfieldtemplate
ADD CONSTRAINT fk_fixedwidthfieldtemplate_fixedwidthmaptemplate_754101727 FOREIGN KEY (fixedwidthmaptemplateid) 
REFERENCES fixedwidthmappingruntime.fixedwidthmaptemplate (id)
ON UPDATE NO ACTION
ON DELETE CASCADE;

ALTER TABLE fixedwidthmappingruntime.fixedwidthparametertemplate
ADD CONSTRAINT fk_fixedwidthparametertemplate_fixedwidthmaptemplate_802101898 FOREIGN KEY (fixedwidthmaptemplateid) 
REFERENCES fixedwidthmappingruntime.fixedwidthmaptemplate (id)
ON UPDATE NO ACTION
ON DELETE CASCADE;

ALTER TABLE ftniconnectorruntime.errortranslationtemplate
ADD CONSTRAINT fk_errortranslationtemplate_ftniconnectortemplate_1058102810 FOREIGN KEY (connectorid) 
REFERENCES ftniconnectorruntime.ftniconnectortemplate (id)
ON UPDATE NO ACTION
ON DELETE CASCADE;

ALTER TABLE httpconnectorruntime.authenticationprovidertemplate
ADD CONSTRAINT fk_authenticationprovidertemplatekey_httpconnectortemplate_1714105147 FOREIGN KEY (httpconnectorid) 
REFERENCES httpconnectorruntime.httpconnectortemplate (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE httpconnectorruntime.customhttpheader
ADD CONSTRAINT fk_customhttpheaderkey_httpconnectortemplate_1666104976 FOREIGN KEY (httpconnectorid) 
REFERENCES httpconnectorruntime.httpconnectortemplate (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE httpconnectorruntime.httpparameterkey
ADD CONSTRAINT fk_httpparameterkey_httpconnectortemplate_1618104805 FOREIGN KEY (httpconnectorid) 
REFERENCES httpconnectorruntime.httpconnectortemplate (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE mappingruntime.fieldmap
ADD CONSTRAINT fk_fieldmap_runtimemap_2034106287 FOREIGN KEY (runtimemapid) 
REFERENCES mappingruntime.runtimemap (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE pdfmappingruntime.pdfparametertemplate
ADD CONSTRAINT fk_pdfparametertemplate_pdffilemaptemplate_302624121 FOREIGN KEY (pdffilemaptemplateid) 
REFERENCES pdfmappingruntime.pdffilemaptemplate (id)
ON UPDATE NO ACTION
ON DELETE CASCADE;

ALTER TABLE platform.applicationrolebyversion
ADD CONSTRAINT fk_applicationrolebyversion_applicationversion_1221579390 FOREIGN KEY (versionid) 
REFERENCES platform.applicationversion (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE platform.applicationversion
ADD CONSTRAINT fk_applicationversion_applicationversion_1253579504 FOREIGN KEY (sourceversionid) 
REFERENCES platform.applicationversion (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE platform.environmentapplicationrolemap
ADD CONSTRAINT fk_environmentapplicationrolemap_environment_1301579675 FOREIGN KEY (environmentid) 
REFERENCES platform.environment (id)
ON UPDATE NO ACTION
ON DELETE CASCADE;

ALTER TABLE platform.environmentdeployment
ADD CONSTRAINT fk_environmentdeployment_environment_901578250 FOREIGN KEY (environmentid) 
REFERENCES platform.environment (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE platform.environmentdeployment
ADD CONSTRAINT fk_environmentdeployment_version_1061578820 FOREIGN KEY (versionid) 
REFERENCES platform.applicationversion (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE platform.environmentnotification
ADD CONSTRAINT fk_environmentnotification_environment_1541580530 FOREIGN KEY (environmentid) 
REFERENCES platform.environment (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE platform.environmentnotificationcustomhttpheader
ADD CONSTRAINT fk_environmentnotificationcustomhttpheader_environmentnotification_1589580701 FOREIGN KEY (environmentnotificationid) 
REFERENCES platform.environmentnotification (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE platform.environmentorigin
ADD CONSTRAINT fk_environmentorigin_environmentvariable_997578592 FOREIGN KEY (environmentid) 
REFERENCES platform.environment (id)
ON UPDATE NO ACTION
ON DELETE CASCADE;

ALTER TABLE platform.environmentrolemap
ADD CONSTRAINT fk_environmentrolemap_environment_741577680 FOREIGN KEY (environmentid) 
REFERENCES platform.environment (id)
ON UPDATE NO ACTION
ON DELETE CASCADE;

ALTER TABLE platform.environmentvariablebyversion
ADD CONSTRAINT fk_environmentvariablebyversion_applicationversion_1173579219 FOREIGN KEY (versionid) 
REFERENCES platform.applicationversion (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE platform.environmentvariablevalue
ADD CONSTRAINT fk_environmentvariablevalue_environmentvariable_837578022 FOREIGN KEY (environmentvariableid) 
REFERENCES platform.environmentvariabledefinition (id)
ON UPDATE NO ACTION
ON DELETE CASCADE;

