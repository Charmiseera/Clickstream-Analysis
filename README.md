# Clickstream Analysis on Hadoop (HDP)

Big Data Analytics project: analysing e-commerce website logs with HDFS, Hive
(on Tez) and Apache Zeppelin on a Hortonworks Data Platform VM.

## Problem statement

Every page request on a website leaves a record — timestamp, visitor IP, URL,
visitor id, geo-location. On its own that log is too large and too raw to read.
The goal of this project is to turn it into answers to six questions about
visitor behaviour:

1. Which US states send the most traffic?
2. Within California, which cities send the most traffic?
3. Which countries does our traffic come from?
4. Which cities generate the most visits overall?
5. Which webpages are visited most often?
6. At what hours of the day is the website busiest?

## Environment

| Component        | What we used                                   |
|------------------|------------------------------------------------|
| Platform         | Hortonworks HDP VM on VirtualBox, Hadoop 2.x   |
| Cluster manager  | Ambari — `http://localhost:8080`               |
| Storage          | HDFS                                           |
| Resource manager | YARN                                           |
| Query engine     | Hive on Tez, database `clickstream`            |
| Visualisation    | Zeppelin — `http://localhost:9995`, notebook `Clickstream_Analysis` |
| Access           | SSH terminal + Ambari UI                       |

### Why each tool

- **HDFS** — the web log is a single 66 MB file of 53-column rows; HDFS
  stores it in replicated blocks so every other Hadoop tool can read it in
  parallel.
- **YARN** — allocates memory and CPU to the Hive/Tez jobs on the VM.
- **Hive** — the logs are tab-separated text, and all six questions are
  "group by a column and count" questions. Hive lets us express them in SQL
  instead of writing a Java MapReduce job for each one.
- **Tez** — Hive's execution engine on HDP. It runs a query as one DAG instead
  of a chain of MapReduce jobs, so each aggregation finishes faster on a
  single-node VM.
- **Zeppelin** — runs the Hive queries through the `%hive` interpreter and turns
  each result into a chart in the same page, so no export step is needed.
- **Ambari** — starting/stopping services and checking their health.

## Dataset

`data.zip` contains three tab-separated files:

| File             | Rows   | Contents                                                      |
|------------------|--------|---------------------------------------------------------------|
| `Omniture.0.tsv` | ~114 K | Raw web log, 53 columns, no header                             |
| `regusers.tsv`   | ~38 K  | Registered users: `SWID`, `BIRTH_DT`, `GENDER_CD`             |
| `urlmap.tsv`     | ~30    | Page `url` → product `category`                                |

All three are loaded into Hive. The analysis in this project uses six columns
of the web log:

| Column   | Meaning                           | Used in          |
|----------|-----------------------------------|------------------|
| `col_2`  | timestamp (`yyyy-MM-dd HH:mm:ss`) | Figure 6         |
| `col_8`  | visitor IP                        | Figures 1, 2     |
| `col_13` | page URL                          | Figure 5         |
| `col_50` | city                              | Figures 2, 4     |
| `col_51` | country                           | Figures 1, 2, 3  |
| `col_53` | state                             | Figures 1, 2     |

`regusers` and `urlmap` are available in the same database for extending the
analysis to product categories and user demographics (see *Future work*).

## Repository layout

```
├── data.zip                         the three source files
├── scripts/
│   ├── 01_verify_environment.sh     version and service checks
│   └── 02_load_to_hdfs.sh           unzip + upload to HDFS
├── hive/
│   ├── 01_create_tables.hql         database, tables, load
│   └── 02_analysis.hql              the six analysis queries
├── zeppelin/
│   └── Clickstream_Analysis.md      notebook paragraphs for Figures 1–6
└── screenshots/                     output screenshots
```

## Pipeline

```
 TSV files ──► HDFS ──► Hive tables ──► Hive queries on Tez ──► Zeppelin charts
              (put)    (LOAD DATA)     (clean + aggregate)      (%hive)
```

Cleaning is done inside each query rather than in a separate staging table:
values are trimmed and lower-cased before grouping, empty values are filtered
out, and timestamps are validated with a regular expression before the hour is
extracted.

## How to run

### 1. Check the environment

In Ambari, confirm HDFS, YARN, Hive and Tez are started. Then over SSH:

```bash
bash scripts/01_verify_environment.sh
```

### 2. Load the data into HDFS

```bash
bash scripts/02_load_to_hdfs.sh /user/maria_dev/clickstream/raw
```

The script unpacks `data.zip`, prints the first lines of each file, uploads the
three files and lists the target directory.

### 3. Create the Hive tables

```bash
hive -f hive/01_create_tables.hql
```

Creates the `clickstream` database and the tables `omnitureweblogs`,
`regusers` and `urlmap`, loads them, and prints row counts.

### 4. Analyse

In Zeppelin: open the `Clickstream_Analysis` notebook, add one paragraph per
query from [zeppelin/Clickstream_Analysis.md](zeppelin/Clickstream_Analysis.md),
run it and pick the chart type noted above each query.

The same queries can be run from the terminal:

```bash
hive -f hive/02_analysis.hql
```

## Results

| Figure | Analysis                                  | Visualization |
|--------|-------------------------------------------|---------------|
| 1      | State-wise traffic in USA                 | Bar           |
| 2      | City-wise traffic in California           | Bar           |
| 3      | Country-wise website traffic              | Bar           |
| 4      | City-wise website traffic (all locations) | Pie           |
| 5      | Top 10 most visited webpages              | Bar           |
| 6      | Website activity by hour                  | Line          |

Figures 1 and 2 are a geographic drill-down (country → state → city) following
the approach of the reference repository; Figures 3–6 look at the whole log.

<!-- Add your own screenshots to the screenshots/ folder and link them here, e.g.
![Figure 1](screenshots/fig1_state_traffic_usa.png)
Then write 1–2 lines under each figure describing what YOUR output shows. -->


## Acknowledgements

The dataset (Omniture logs, registered users, URL map) comes from the
Hortonworks clickstream tutorial; 
for reference https://gist.github.com/yawi/9a183bb97d7c4e10061b?utm_source=chatgpt.com