ALTER TABLE "AzureServiceBusConnectorDesigner"."AzureServiceBusConnectorParameter"
ADD CONSTRAINT "FK_AzureServiceBusConnectorParameter_AzureServiceBusConnector"
FOREIGN KEY ("AzureServiceBusConnectorId")
REFERENCES "AzureServiceBusConnectorDesigner"."AzureServiceBusConnector" ("Id")
ON DELETE CASCADE;

ALTER TABLE "EmailConnectorDesigner"."EmailConnectorParameter"
ADD CONSTRAINT "FK_EmailConnectorParameter_EmailConnector"
FOREIGN KEY ("EmailConnectorId")
REFERENCES "EmailConnectorDesigner"."EmailConnector"("Id")
ON DELETE CASCADE;

ALTER TABLE "EndpointDesigner"."EndpointRole"
ADD CONSTRAINT "FK_EndpointRole_Endpoint"
FOREIGN KEY ("EndpointId")
REFERENCES "EndpointDesigner"."Endpoint"("Id")
ON DELETE CASCADE;

ALTER TABLE "FileTransferConnectorDesigner"."FileTransferConnectorParameter"
ADD CONSTRAINT "FK_FileTransferConnectorParameter_FileTransferConnector"
FOREIGN KEY ("FileTransferConnectorId")
REFERENCES "FileTransferConnectorDesigner"."FileTransferConnector"("Id")
ON DELETE CASCADE;

ALTER TABLE "FixedWidthMappingDesigner"."FixedWidthField"
ADD CONSTRAINT "FK_FixedWidthField_FixedWidthMap"
FOREIGN KEY ("FixedWidthMapId")
REFERENCES "FixedWidthMappingDesigner"."FixedWidthMap"("Id")
ON DELETE CASCADE;

ALTER TABLE "FixedWidthMappingDesigner"."FixedWidthParameter"
ADD CONSTRAINT "FK_FixedWidthParameter_FixedWidthMap"
FOREIGN KEY ("FixedWidthMapId")
REFERENCES "FixedWidthMappingDesigner"."FixedWidthMap"("Id")
ON DELETE CASCADE;

ALTER TABLE "FormDesigner"."FormElement"
ADD CONSTRAINT "FK_FormElement_Form"
FOREIGN KEY ("FormId")
REFERENCES "FormDesigner"."Form" ("Id")
ON DELETE CASCADE;

ALTER TABLE "FormDesigner"."FormElement"
ADD CONSTRAINT "FK_FormElement_Container"
FOREIGN KEY ("ContainerId")
REFERENCES "FormDesigner"."FormElement" ("Id");

ALTER TABLE "FormDesigner"."FormElementValidation"
ADD CONSTRAINT "FK_FormElementValidation_FormElement"
FOREIGN KEY ("FormElementId")
REFERENCES "FormDesigner"."FormElement" ("Id");

ALTER TABLE "FormDesigner"."FormParameter"
ADD CONSTRAINT "FK_FormParameter_Form"
FOREIGN KEY ("FormId")
REFERENCES "FormDesigner"."Form" ("Id")
ON DELETE CASCADE;

ALTER TABLE "FormDesigner"."HelperItem"
ADD CONSTRAINT "FK_HelperItem_HelperField"
FOREIGN KEY ("HelperFieldId")
REFERENCES "FormDesigner"."FormElement" ("Id")
ON DELETE CASCADE;

ALTER TABLE "FormDesigner"."Option"
ADD CONSTRAINT "FK_Option_FormElement"
FOREIGN KEY ("InputFieldId")
REFERENCES "FormDesigner"."FormElement" ("Id")
ON DELETE CASCADE;

ALTER TABLE "FormDesigner"."TableParameter"
ADD CONSTRAINT "FK_TableParameter_FormElement"
FOREIGN KEY ("TableId")
REFERENCES "FormDesigner"."FormElement" ("Id")
ON DELETE CASCADE;

ALTER TABLE "FormDesigner"."TextVariation"
ADD CONSTRAINT "FK_TextVariation_FormElement"
FOREIGN KEY ("ElementId")
REFERENCES "FormDesigner"."FormElement" ("Id")
ON DELETE CASCADE;

ALTER TABLE "HttpConnectorDesigner"."HttpConnectorParameter"
ADD CONSTRAINT "FK_HttpConnectorParameter_HttpConnector"
FOREIGN KEY ("HttpConnectorId")
REFERENCES "HttpConnectorDesigner"."HttpConnector"("Id")
ON DELETE CASCADE;

ALTER TABLE "MappingDesigner"."Map"
ADD CONSTRAINT "FK_Map_SourceId_ActionDescription"
FOREIGN KEY ("CallerDescriptionId")
REFERENCES "MappingDesigner"."ActionDescription" ("Id");

ALTER TABLE "MappingDesigner"."Map"
ADD CONSTRAINT "FK_Map_TargetId_ActionDescription"
FOREIGN KEY ("ActionDescriptionId")
REFERENCES "MappingDesigner"."ActionDescription" ("Id");

ALTER TABLE "PdfMappingDesigner"."PdfParameter"
ADD CONSTRAINT "FK_PdfParameter_PdfFileMap"
FOREIGN KEY ("PdfFileMapId")
REFERENCES "PdfMappingDesigner"."PdfFileMap"("Id")
ON DELETE CASCADE;

ALTER TABLE "ProcessDesigner"."ProcessEndpoint"
ADD CONSTRAINT "FK_ProcessEndpoint_ProcessTemplate"
FOREIGN KEY ("ProcessTemplateId")
REFERENCES "ProcessDesigner"."ProcessTemplate" ("Id")
ON DELETE CASCADE;

ALTER TABLE "QueryingDesigner"."QueryInputParameter"
ADD CONSTRAINT "FK_QueryInputParameter_Query"
FOREIGN KEY ("QueryId")
REFERENCES "QueryingDesigner"."Query" ("Id")
ON DELETE CASCADE;

ALTER TABLE "QueryingDesigner"."QueryOutputParameter"
ADD CONSTRAINT "FK_QueryOutputParameter_Query"
FOREIGN KEY ("QueryId")
REFERENCES "QueryingDesigner"."Query" ("Id")
ON DELETE CASCADE;
