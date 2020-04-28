USE [900_Metadata]
GO
/****** Object:  View [interface].[INTERFACE_BUSINESS_KEY_COMPONENT]    Script Date: 16/11/2019 8:16:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [interface].[INTERFACE_BUSINESS_KEY_COMPONENT]
AS
SELECT
 src.SCHEMA_NAME AS SOURCE_SCHEMA_NAME,
 src.SOURCE_NAME,
 hub.SCHEMA_NAME AS TARGET_SCHEMA_NAME,
 hub.HUB_NAME AS TARGET_NAME,
 BUSINESS_KEY_DEFINITION,
 COMPONENT_ID AS BUSINESS_KEY_COMPONENT_ID,
 COMPONENT_ORDER AS BUSINESS_KEY_COMPONENT_ORDER,
 COMPONENT_VALUE AS BUSINESS_KEY_COMPONENT_VALUE
FROM MD_BUSINESS_KEY_COMPONENT xref
JOIN MD_SOURCE src ON xref.SOURCE_NAME = src.SOURCE_NAME
JOIN MD_HUB hub ON xref.HUB_NAME = hub.HUB_NAME

GO
/****** Object:  View [interface].[INTERFACE_BUSINESS_KEY_COMPONENT_PART]    Script Date: 16/11/2019 8:16:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [interface].[INTERFACE_BUSINESS_KEY_COMPONENT_PART]
AS
SELECT
  stg.[SCHEMA_NAME] AS [SOURCE_SCHEMA_NAME],
  stg.[SOURCE_NAME],
  hub.[SCHEMA_NAME] AS [TARGET_SCHEMA_NAME],
  hub.[HUB_NAME] AS [TARGET_NAME],
  comp.[BUSINESS_KEY_DEFINITION],
  comp.[COMPONENT_ID] AS [BUSINESS_KEY_COMPONENT_ID], 
  comp.[COMPONENT_ORDER] AS [BUSINESS_KEY_COMPONENT_ORDER],
  elem.[COMPONENT_ELEMENT_ID] AS [BUSINESS_KEY_COMPONENT_ELEMENT_ID], 
  elem.[COMPONENT_ELEMENT_ORDER] AS [BUSINESS_KEY_COMPONENT_ELEMENT_ORDER],
  elem.[COMPONENT_ELEMENT_VALUE] AS [BUSINESS_KEY_COMPONENT_ELEMENT_VALUE],
  elem.[COMPONENT_ELEMENT_TYPE] AS [BUSINESS_KEY_COMPONENT_ELEMENT_TYPE],
  COALESCE(elem.[ATTRIBUTE_NAME], 'Not applicable') AS [BUSINESS_KEY_COMPONENT_ELEMENT_ATTRIBUTE_NAME]
FROM MD_BUSINESS_KEY_COMPONENT comp
JOIN MD_BUSINESS_KEY_COMPONENT_PART elem
  ON comp.SOURCE_NAME = elem.SOURCE_NAME
 AND comp.HUB_NAME = elem.HUB_NAME
 AND comp.BUSINESS_KEY_DEFINITION = elem.BUSINESS_KEY_DEFINITION
 AND comp.COMPONENT_ID = elem.COMPONENT_ID
JOIN MD_SOURCE stg ON comp.SOURCE_NAME = stg.SOURCE_NAME
JOIN MD_HUB hub ON comp.HUB_NAME = hub.HUB_NAME

GO
/****** Object:  View [interface].[INTERFACE_DRIVING_KEY]    Script Date: 16/11/2019 8:16:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [interface].[INTERFACE_DRIVING_KEY]
AS
SELECT
  MD.SATELLITE_NAME, 
  MD.HUB_NAME
FROM MD_DRIVING_KEY_XREF MD

GO
/****** Object:  View [interface].[INTERFACE_HUB_LINK_XREF]    Script Date: 16/11/2019 8:16:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW[interface].[INTERFACE_HUB_LINK_XREF]
AS
SELECT
  stg.[SCHEMA_NAME] AS[SOURCE_SCHEMA_NAME],
  slxref.SOURCE_NAME,
  lnk.[SCHEMA_NAME] AS[LINK_SCHEMA_NAME],
  slxref.LINK_NAME,
  hub.[SCHEMA_NAME] AS[HUB_SCHEMA_NAME],
  hub.[HUB_NAME],
  hub.[SURROGATE_KEY] AS[HUB_SURROGATE_KEY],
  hlxref.[HUB_TARGET_KEY_NAME_IN_LINK] AS [HUB_TARGET_KEY_NAME_IN_LINK],
  [BUSINESS_KEY_PART_SOURCE] AS[HUB_SOURCE_BUSINESS_KEY_DEFINITION],
  hub.[BUSINESS_KEY] AS[HUB_TARGET_BUSINESS_KEY_DEFINITION],
  hlxref.HUB_ORDER
FROM
(
  SELECT
    LINK_NAME,
    SOURCE_NAME,
    LTRIM(Split.a.value('.', 'VARCHAR(4000)')) AS BUSINESS_KEY_PART_SOURCE,
    ROW_NUMBER() OVER(PARTITION BY LINK_NAME, SOURCE_NAME ORDER BY LINK_NAME, SOURCE_NAME) AS HUB_ORDER
  FROM
  (
    SELECT
      LINK_NAME,
      SOURCE_NAME,
      CAST('<M>' + REPLACE(BUSINESS_KEY_DEFINITION, ',', '</M><M>') + '</M>' AS XML) AS BUSINESS_KEY_SOURCE_XML
    FROM [MD_SOURCE_LINK_XREF]
  ) AS A CROSS APPLY BUSINESS_KEY_SOURCE_XML.nodes('/M') AS Split(a)
) slxref
JOIN MD_SOURCE stg ON slxref.SOURCE_NAME = stg.SOURCE_NAME
JOIN MD_LINK lnk ON slxref.LINK_NAME = lnk.LINK_NAME
JOIN MD_HUB_LINK_XREF hlxref ON slxref.LINK_NAME = hlxref.LINK_NAME
AND slxref.HUB_ORDER = hlxref.HUB_ORDER
JOIN MD_HUB hub ON hlxref.HUB_NAME = hub.HUB_NAME

GO
/****** Object:  View [interface].[INTERFACE_PHYSICAL_MODEL]    Script Date: 16/11/2019 8:16:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [interface].[INTERFACE_PHYSICAL_MODEL]
AS
SELECT
  [DATABASE_NAME]
 ,[SCHEMA_NAME]
 ,[TABLE_NAME]
 ,[COLUMN_NAME]
 ,[DATA_TYPE]
 ,[CHARACTER_MAXIMUM_LENGTH]
 ,[NUMERIC_PRECISION]
 ,[ORDINAL_POSITION]
 ,[PRIMARY_KEY_INDICATOR]
FROM [MD_PHYSICAL_MODEL]

GO
/****** Object:  View [interface].[INTERFACE_SOURCE_HUB_XREF]    Script Date: 16/11/2019 8:16:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [interface].[INTERFACE_SOURCE_HUB_XREF]
AS
SELECT
  src.[SCHEMA_NAME] AS [SOURCE_SCHEMA_NAME]
 ,src.[SOURCE_NAME]
 ,tgt.[SCHEMA_NAME] AS [TARGET_SCHEMA_NAME]
 ,xref.[HUB_NAME] AS [TARGET_NAME]
 ,xref.[BUSINESS_KEY_DEFINITION] AS [SOURCE_BUSINESS_KEY_DEFINITION]
 ,tgt.[BUSINESS_KEY] AS [TARGET_BUSINESS_KEY_DEFINITION]
 ,'Hub' AS [TARGET_TYPE]
 ,[SURROGATE_KEY]
 ,[FILTER_CRITERIA]
 ,xref.[LOAD_VECTOR]
FROM [MD_SOURCE_HUB_XREF] xref
JOIN [MD_SOURCE] src ON xref.[SOURCE_NAME] = src.[SOURCE_NAME]
JOIN [MD_HUB] tgt ON xref.HUB_NAME = tgt.[HUB_NAME]

GO
/****** Object:  View [interface].[INTERFACE_SOURCE_LINK_ATTRIBUTE_XREF]    Script Date: 16/11/2019 8:16:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [interface].[INTERFACE_SOURCE_LINK_ATTRIBUTE_XREF]
AS
SELECT
  src.[SCHEMA_NAME] AS [SOURCE_SCHEMA_NAME]
 ,xref.[SOURCE_NAME]
 ,tgt.[SCHEMA_NAME] AS [TARGET_SCHEMA_NAME]
 ,xref.[LINK_NAME] AS [TARGET_NAME]
 ,[ATTRIBUTE_NAME_FROM] AS [SOURCE_ATTRIBUTE_NAME]
 ,[ATTRIBUTE_NAME_TO] AS [TARGET_ATTRIBUTE_NAME]
FROM [MD_SOURCE_LINK_ATTRIBUTE_XREF] xref
JOIN [MD_SOURCE] src ON xref.[SOURCE_NAME] = src.[SOURCE_NAME]
JOIN [MD_LINK] tgt ON xref.[LINK_NAME] = tgt.[LINK_NAME]

GO
/****** Object:  View [interface].[INTERFACE_SOURCE_LINK_XREF]    Script Date: 16/11/2019 8:16:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

                CREATE VIEW [interface].[INTERFACE_SOURCE_LINK_XREF]
                AS
                SELECT
                  src.[SCHEMA_NAME] AS[SOURCE_SCHEMA_NAME]
                 ,src.[SOURCE_NAME]
                 ,tgt.[SCHEMA_NAME] AS[TARGET_SCHEMA_NAME]
                 ,tgt.[LINK_NAME] AS[TARGET_NAME]
				 ,xref.BUSINESS_KEY_DEFINITION AS [SOURCE_BUSINESS_KEY_DEFINITION]
				 ,tgt.[BUSINESS_KEY] as [TARGET_BUSINESS_KEY_DEFINITION]
                 ,'Link' as [TARGET_TYPE]
				 ,tgt.[SURROGATE_KEY]
                 ,[FILTER_CRITERIA]
                 ,xref.[LOAD_VECTOR]
                FROM [MD_SOURCE_LINK_XREF] xref
                JOIN [MD_SOURCE] src ON xref.[SOURCE_NAME] = src.[SOURCE_NAME]
                JOIN [MD_LINK] tgt ON xref.[LINK_NAME] = tgt.[LINK_NAME]
                

GO
/****** Object:  View [interface].[INTERFACE_SOURCE_PERSISTENT_STAGING_ATTRIBUTE_XREF]    Script Date: 16/11/2019 8:16:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [interface].[INTERFACE_SOURCE_PERSISTENT_STAGING_ATTRIBUTE_XREF]
AS
SELECT
   src.[SCHEMA_NAME] AS [SOURCE_SCHEMA_NAME]
  ,src.[SOURCE_NAME]
  ,tgt.[SCHEMA_NAME] AS [TARGET_SCHEMA_NAME]
  ,xref.[PERSISTENT_STAGING_NAME] AS [TARGET_NAME]
  ,xref.[ATTRIBUTE_NAME_FROM] AS [SOURCE_ATTRIBUTE_NAME]
  ,xref.[ATTRIBUTE_NAME_TO] AS [TARGET_ATTRIBUTE_NAME]
FROM [MD_SOURCE_PERSISTENT_STAGING_ATTRIBUTE_XREF] xref
JOIN [MD_SOURCE] src ON xref.SOURCE_NAME = src.SOURCE_NAME
JOIN [MD_PERSISTENT_STAGING] tgt ON xref.PERSISTENT_STAGING_NAME = tgt.PERSISTENT_STAGING_NAME

GO
/****** Object:  View [interface].[INTERFACE_SOURCE_PERSISTENT_STAGING_XREF]    Script Date: 16/11/2019 8:16:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [interface].[INTERFACE_SOURCE_PERSISTENT_STAGING_XREF]
AS
SELECT
  src.[SCHEMA_NAME] AS [SOURCE_SCHEMA_NAME],
  xref.[SOURCE_NAME],
  xref.[KEY_DEFINITION] AS [SOURCE_BUSINESS_KEY_DEFINITION],
  tgt.[SCHEMA_NAME] AS [TARGET_SCHEMA_NAME],
  xref.[PERSISTENT_STAGING_NAME] AS[TARGET_NAME],
  xref.[KEY_DEFINITION] AS [TARGET_BUSINESS_KEY_DEFINITION],
  'PersistentStagingArea' AS [TARGET_TYPE],
  'Not applicable' AS [SURROGATE_KEY],
  [FILTER_CRITERIA],
  'Raw' AS [LOAD_VECTOR]
FROM [MD_SOURCE_PERSISTENT_STAGING_XREF] xref
JOIN [MD_SOURCE] src ON xref.[SOURCE_NAME] = src.[SOURCE_NAME]
JOIN [MD_PERSISTENT_STAGING] tgt ON xref.[PERSISTENT_STAGING_NAME] = tgt.[PERSISTENT_STAGING_NAME]

GO
/****** Object:  View [interface].[INTERFACE_SOURCE_SATELLITE_ATTRIBUTE_XREF]    Script Date: 16/11/2019 8:16:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [interface].[INTERFACE_SOURCE_SATELLITE_ATTRIBUTE_XREF]
AS
SELECT
  src.[SCHEMA_NAME] AS SOURCE_SCHEMA_NAME
 ,xref.[SOURCE_NAME]
 ,tgt.[SCHEMA_NAME] AS TARGET_SCHEMA_NAME
 ,xref.[SATELLITE_NAME] AS [TARGET_NAME]
 ,[ATTRIBUTE_NAME_FROM] AS [SOURCE_ATTRIBUTE_NAME]
 ,[ATTRIBUTE_NAME_TO] AS [TARGET_ATTRIBUTE_NAME]
 ,[MULTI_ACTIVE_KEY_INDICATOR]
FROM [MD_SOURCE_SATELLITE_ATTRIBUTE_XREF] xref
JOIN [MD_SOURCE] src ON xref.[SOURCE_NAME] = src.[SOURCE_NAME]
JOIN [MD_SATELLITE] tgt ON xref.[SATELLITE_NAME] = tgt.[SATELLITE_NAME]

GO
/****** Object:  View [interface].[INTERFACE_SOURCE_SATELLITE_XREF]    Script Date: 16/11/2019 8:16:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [interface].[INTERFACE_SOURCE_SATELLITE_XREF]
AS
SELECT
 stg.[SCHEMA_NAME] AS SOURCE_SCHEMA_NAME,
 xref.SOURCE_NAME,
 sat.[SCHEMA_NAME] AS [TARGET_SCHEMA_NAME],
 sat.SATELLITE_NAME AS [TARGET_NAME],
 xref.BUSINESS_KEY_DEFINITION AS SOURCE_BUSINESS_KEY_DEFINITION,
 hub.[BUSINESS_KEY] AS [TARGET_BUSINESS_KEY_DEFINITION],
 sat.SATELLITE_TYPE AS [TARGET_TYPE],
 hub.SURROGATE_KEY,
 xref.FILTER_CRITERIA,
 xref.[LOAD_VECTOR]
FROM MD_SOURCE_SATELLITE_XREF xref
JOIN MD_SOURCE stg ON xref.SOURCE_NAME = stg.SOURCE_NAME
JOIN MD_SATELLITE sat ON xref.SATELLITE_NAME = sat.SATELLITE_NAME
JOIN MD_HUB hub ON sat.HUB_NAME = hub.HUB_NAME
LEFT JOIN MD_SOURCE_HUB_XREF stghubxref
  ON xref.SOURCE_NAME = stghubxref.SOURCE_NAME
  AND hub.HUB_NAME = stghubxref.HUB_NAME
  AND xref.BUSINESS_KEY_DEFINITION = stghubxref.BUSINESS_KEY_DEFINITION
WHERE sat.SATELLITE_TYPE= 'Normal'

UNION

SELECT
 stg.[SCHEMA_NAME] AS SOURCE_SCHEMA_NAME,
 xref.SOURCE_NAME,
 sat.[SCHEMA_NAME] AS [TARGET_SCHEMA_NAME],
 sat.SATELLITE_NAME AS [TARGET_NAME],
 xref.BUSINESS_KEY_DEFINITION AS SOURCE_BUSINESS_KEY_DEFINITION,
 lnk.BUSINESS_KEY AS [TARGET_BUSINESS_KEY_DEFINITION],
 sat.SATELLITE_TYPE AS [TARGET_TYPE],
 lnk.SURROGATE_KEY,
 xref.FILTER_CRITERIA,
 xref.[LOAD_VECTOR]
FROM MD_SOURCE_SATELLITE_XREF xref
JOIN MD_SOURCE stg ON xref.SOURCE_NAME = stg.SOURCE_NAME
JOIN MD_SATELLITE sat ON xref.SATELLITE_NAME = sat.SATELLITE_NAME
JOIN MD_HUB hub ON sat.HUB_NAME = hub.HUB_NAME
JOIN MD_LINK lnk ON sat.LINK_NAME = lnk.LINK_NAME
LEFT JOIN MD_SOURCE_HUB_XREF stghubxref
  ON xref.SOURCE_NAME = stghubxref.SOURCE_NAME
  AND hub.HUB_NAME = stghubxref.HUB_NAME
  AND xref.BUSINESS_KEY_DEFINITION = stghubxref.BUSINESS_KEY_DEFINITION
WHERE sat.SATELLITE_TYPE= 'Link Satellite'

GO
/****** Object:  View [interface].[INTERFACE_SOURCE_STAGING_ATTRIBUTE_XREF]    Script Date: 16/11/2019 8:16:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [interface].[INTERFACE_SOURCE_STAGING_ATTRIBUTE_XREF]
AS
SELECT
   src.[SCHEMA_NAME] AS [SOURCE_SCHEMA_NAME]
  ,src.[SOURCE_NAME]
  ,tgt.[SCHEMA_NAME] AS [TARGET_SCHEMA_NAME]
  ,xref.[STAGING_NAME] AS [TARGET_NAME]
  ,xref.[ATTRIBUTE_NAME_FROM] AS [SOURCE_ATTRIBUTE_NAME]
  ,xref.[ATTRIBUTE_NAME_TO] AS [TARGET_ATTRIBUTE_NAME]
FROM [MD_SOURCE_STAGING_ATTRIBUTE_XREF] xref
JOIN [MD_SOURCE] src ON xref.[SOURCE_NAME] = src.[SOURCE_NAME]
JOIN [MD_STAGING] tgt ON xref.[STAGING_NAME] = tgt.[STAGING_NAME]

GO
/****** Object:  View [interface].[INTERFACE_SOURCE_STAGING_XREF]    Script Date: 16/11/2019 8:16:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [interface].[INTERFACE_SOURCE_STAGING_XREF]
AS
/*
This view combines the staging area listing / interfaces with the exceptions where a single source file/table is mapped to more than one Staging Area tables.
This is the default source for source-to-staging interfaces.
*/
SELECT
  src.[SCHEMA_NAME] AS [SOURCE_SCHEMA_NAME],
  xref.[SOURCE_NAME],
  xref.[KEY_DEFINITION] AS [SOURCE_BUSINESS_KEY_DEFINITION],
  tgt.[SCHEMA_NAME] AS [TARGET_SCHEMA_NAME],
  xref.[STAGING_NAME] AS [TARGET_NAME],
  xref.[KEY_DEFINITION] AS [TARGET_BUSINESS_KEY_DEFINITION],
  'StagingArea' AS [TARGET_TYPE],
  'Not applicable' AS [SURROGATE_KEY],
  [FILTER_CRITERIA],
  'Raw' AS [LOAD_VECTOR]
FROM[MD_SOURCE_STAGING_XREF] xref
JOIN[MD_SOURCE] src ON xref.[SOURCE_NAME] = src.[SOURCE_NAME]
JOIN[MD_STAGING] tgt ON xref.[STAGING_NAME] = tgt.[STAGING_NAME]

GO
