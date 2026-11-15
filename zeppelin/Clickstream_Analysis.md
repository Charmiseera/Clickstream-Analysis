# Zeppelin notebook: `Clickstream_Analysis`

Paragraphs used in the Zeppelin notebook (http://localhost:9995) to produce the
report figures. Each block is one paragraph.

> **No trailing semicolon.** Zeppelin's JDBC (`%hive`) interpreter passes the
> text straight to HiveServer2, and a final `;` fails with
> `ParseException ... extraneous input ';' expecting EOF`.

## Figure 1 – State-wise website traffic in USA

Chart: **Bar** · keys (x-axis) = `state` · values (y-axis) = `total_visits`

```sql
%hive
SELECT
    LOWER(TRIM(col_53)) AS state,
    COUNT(col_8) AS total_visits
FROM clickstream.omnitureweblogs
WHERE LOWER(TRIM(col_51)) = 'usa'
  AND col_53 IS NOT NULL
  AND TRIM(col_53) <> ''
GROUP BY LOWER(TRIM(col_53))
ORDER BY total_visits DESC
LIMIT 10
```

## Figure 2 – City-wise website traffic in California

Chart: **Bar** · keys (x-axis) = `city` · values (y-axis) = `total_visits`

```sql
%hive
SELECT
    LOWER(TRIM(col_50)) AS city,
    COUNT(col_8) AS total_visits
FROM clickstream.omnitureweblogs
WHERE LOWER(TRIM(col_51)) = 'usa'
  AND UPPER(TRIM(col_53)) = 'CA'
  AND col_50 IS NOT NULL
  AND TRIM(col_50) <> ''
GROUP BY LOWER(TRIM(col_50))
ORDER BY total_visits DESC
LIMIT 10
```

## Figure 3 – Country-wise website traffic

Chart: **Bar** · keys = `country` · values = `total_visits`

```sql
%hive
SELECT
    LOWER(TRIM(col_51)) AS country,
    COUNT(*) AS total_visits
FROM clickstream.omnitureweblogs
WHERE col_51 IS NOT NULL
  AND TRIM(col_51) <> ''
GROUP BY LOWER(TRIM(col_51))
ORDER BY total_visits DESC
LIMIT 10
```

## Figure 4 – City-wise website traffic (all locations)

Chart: **Pie** · keys = `city` · values = `total_visits`

```sql
%hive
SELECT
    LOWER(TRIM(col_50)) AS city,
    COUNT(*) AS total_visits
FROM clickstream.omnitureweblogs
WHERE col_50 IS NOT NULL
  AND TRIM(col_50) <> ''
GROUP BY LOWER(TRIM(col_50))
ORDER BY total_visits DESC
LIMIT 10
```

## Figure 5 – Top 10 most visited webpages

Chart: **Bar** (horizontal if available) · keys = `webpage` · values = `total_visits`

```sql
%hive
SELECT
    col_13 AS webpage,
    COUNT(*) AS total_visits
FROM clickstream.omnitureweblogs
WHERE col_13 IS NOT NULL
  AND TRIM(col_13) <> ''
GROUP BY col_13
ORDER BY total_visits DESC
LIMIT 10
```

## Figure 6 – Website activity by hour

Chart: **Line** · keys (x-axis) = `hour_of_day` · values (y-axis) = `total_visits`

```sql
%hive
SELECT
    CAST(SUBSTR(col_2, 12, 2) AS INT) AS hour_of_day,
    COUNT(*) AS total_visits
FROM clickstream.omnitureweblogs
WHERE col_2 RLIKE '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
GROUP BY CAST(SUBSTR(col_2, 12, 2) AS INT)
ORDER BY hour_of_day
```

## Backing up the notebook

Zeppelin saves paragraphs automatically. For an offline copy, open the notebook
and use the **Export** icon in the toolbar to download it as JSON, then place the
file in this folder as `Clickstream_Analysis.json`.
