-- Phase 3 - Hive database and raw tables
-- Run from the VM:  hive -f hive/01_create_tables.hql
-- (or through Ambari Hive View, one statement at a time)
--
-- Replace the HDFS path in the LOAD statements if you uploaded
-- the files somewhere other than /user/maria_dev/clickstream/raw.

CREATE DATABASE IF NOT EXISTS clickstream;
USE clickstream;

-- ---------------------------------------------------------------
-- Raw web logs. The export has 53 tab-separated fields and no
-- usable header names, so the columns keep their position as the
-- name. The ones that matter:
--   col_2  = timestamp      col_8  = visitor IP
--   col_13 = page URL       col_14 = SWID (visitor id)
--   col_50 = city           col_51 = country      col_53 = state
-- ---------------------------------------------------------------
DROP TABLE IF EXISTS omnitureweblogs;
CREATE TABLE omnitureweblogs (
    col_1   STRING,
    col_2   STRING,   -- timestamp
    col_3   STRING,
    col_4   STRING,
    col_5   STRING,
    col_6   STRING,
    col_7   STRING,
    col_8   STRING,   -- visitor ip
    col_9   STRING,
    col_10  STRING,
    col_11  STRING,
    col_12  STRING,
    col_13  STRING,   -- url
    col_14  STRING,   -- swid
    col_15  STRING,
    col_16  STRING,
    col_17  STRING,
    col_18  STRING,
    col_19  STRING,
    col_20  STRING,
    col_21  STRING,
    col_22  STRING,
    col_23  STRING,
    col_24  STRING,
    col_25  STRING,
    col_26  STRING,
    col_27  STRING,
    col_28  STRING,
    col_29  STRING,
    col_30  STRING,
    col_31  STRING,
    col_32  STRING,
    col_33  STRING,
    col_34  STRING,
    col_35  STRING,
    col_36  STRING,
    col_37  STRING,
    col_38  STRING,
    col_39  STRING,
    col_40  STRING,
    col_41  STRING,
    col_42  STRING,
    col_43  STRING,
    col_44  STRING,
    col_45  STRING,
    col_46  STRING,
    col_47  STRING,
    col_48  STRING,
    col_49  STRING,
    col_50  STRING,   -- city
    col_51  STRING,   -- country
    col_52  STRING,
    col_53  STRING   -- state
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;
-- Omniture.0.tsv has no header row, so nothing is skipped here.

-- Registered users (CRM extract)
DROP TABLE IF EXISTS regusers;
CREATE TABLE regusers (
    swid      STRING,
    birth_dt  STRING,    -- e.g. 8-Apr-84
    gender_cd STRING     -- M / F / U
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
TBLPROPERTIES ('skip.header.line.count' = '1');

-- URL -> product category lookup (CMS extract)
DROP TABLE IF EXISTS urlmap;
CREATE TABLE urlmap (
    url      STRING,
    category STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
TBLPROPERTIES ('skip.header.line.count' = '1');

-- ---------------------------------------------------------------
-- Load. LOAD DATA INPATH moves the files inside HDFS into the
-- Hive warehouse, it does not copy them.
-- ---------------------------------------------------------------
LOAD DATA INPATH '/user/maria_dev/clickstream/raw/Omniture.0.tsv' OVERWRITE INTO TABLE omnitureweblogs;
LOAD DATA INPATH '/user/maria_dev/clickstream/raw/regusers.tsv'   OVERWRITE INTO TABLE regusers;
LOAD DATA INPATH '/user/maria_dev/clickstream/raw/urlmap.tsv'     OVERWRITE INTO TABLE urlmap;

-- Sanity checks
SHOW TABLES;
SELECT COUNT(*) AS weblog_rows FROM omnitureweblogs;
SELECT COUNT(*) AS user_rows   FROM regusers;
SELECT COUNT(*) AS url_rows    FROM urlmap;
SELECT col_2, col_8, col_13, col_14, col_50, col_51, col_53 FROM omnitureweblogs LIMIT 5;
