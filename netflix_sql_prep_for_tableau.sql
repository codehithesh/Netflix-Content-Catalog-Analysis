/* =====================================================================
NETFLIX EDA - MySQL PREP FOR TABLEAU     (MySQL 8.0+)
Mirrors netflix_prep.py step for step: same tables, same columns,
same rules. No region mapping, no genre merge, no audience groups,
no duration buckets.

Output tables (relate them in Tableau on show_id):
netflix_titles          1 row per title
netflix_cast            title x actor     (is_lead = first listed)
netflix_director        title x director
netflix_country         title x country
netflix_genre           title x genre
netflix_director_actor  title x director x actor
===================================================================== */
CREATE DATABASE IF NOT EXISTS netflix_eda CHARACTER
SET
    utf8mb4;

USE netflix_eda;

SET
    SQL_SAFE_UPDATES = 0;

/* ---------------------------------------------------------------------
1. LOAD  (everything as TEXT so the load itself can never overflow)
Your sample has a leading unnamed index column. If your CSV header
does NOT start with a comma, delete the `idx` line.
Needs:  SET GLOBAL local_infile = 1;  and OPT_LOCAL_INFILE=1 in the
Workbench connection (Advanced > Others).
Alternative: Workbench "Table Data Import Wizard" into stg_netflix.
--------------------------------------------------------------------- */
DROP TABLE IF EXISTS stg_netflix;

CREATE TABLE
    stg_netflix (
        idx TEXT,
        show_id TEXT,
        type TEXT,
        title TEXT,
        director TEXT,
        cast_raw TEXT,
        country TEXT,
        date_added TEXT,
        release_year TEXT,
        rating TEXT,
        duration TEXT,
        listed_in TEXT,
        description TEXT
    ) CHARACTER
SET
    utf8mb4;

LOAD DATA LOCAL INFILE 'assets/netflix.csv'
INTO TABLE stg_netflix CHARACTER
SET
    utf8mb4 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' -- Windows file. Use '\n' if the file came from Mac/Linux
    IGNORE 1 LINES;

/* GATES. Wrong line endings silently glue rows together, so check both:
(a) rows_loaded must equal the title count netflix_prep.py prints (8807 in the standard file)
(b) this must return 0 rows; otherwise columns are shifted (idx line wrong) */
SELECT
    COUNT(*) AS rows_loaded
FROM
    stg_netflix;

SELECT
    show_id,
    type
FROM
    stg_netflix
WHERE
    show_id NOT REGEXP '^s[0-9]+$'
LIMIT
    5;

/* ---------------------------------------------------------------------
2. TIDY TEXT  (python: strip, blank -> missing)
--------------------------------------------------------------------- */
UPDATE stg_netflix
SET
    show_id = NULLIF(TRIM(REPLACE (show_id, '\r', '')), ''),
    type = NULLIF(TRIM(REPLACE (type, '\r', '')), ''),
    title = NULLIF(TRIM(REPLACE (title, '\r', '')), ''),
    director = NULLIF(TRIM(REPLACE (director, '\r', '')), ''),
    cast_raw = NULLIF(TRIM(REPLACE (cast_raw, '\r', '')), ''),
    country = NULLIF(TRIM(REPLACE (country, '\r', '')), ''),
    date_added = NULLIF(TRIM(REPLACE (date_added, '\r', '')), ''),
    release_year = NULLIF(TRIM(REPLACE (release_year, '\r', '')), ''),
    rating = NULLIF(TRIM(REPLACE (rating, '\r', '')), ''),
    duration = NULLIF(TRIM(REPLACE (duration, '\r', '')), ''),
    listed_in = NULLIF(TRIM(REPLACE (listed_in, '\r', '')), ''),
    description = NULLIF(TRIM(REPLACE (description, '\r', '')), '');

-- runtime typed into `rating` with `duration` blank
UPDATE stg_netflix
SET
    duration = rating,
    rating = NULL
WHERE
    duration IS NULL
    AND rating REGEXP '^[0-9]+ min$';

-- duplicate checks (report only, nothing deleted): both return 0 rows
SELECT
    show_id,
    COUNT(*)
FROM
    stg_netflix
GROUP BY
    show_id
HAVING
    COUNT(*) > 1;

SELECT
    title,
    type,
    release_year,
    COUNT(*)
FROM
    stg_netflix
GROUP BY
    title,
    type,
    release_year
HAVING
    COUNT(*) > 1;

-- missing share per column
SELECT
    ROUND(AVG(director IS NULL), 3) AS director,
    ROUND(AVG(cast_raw IS NULL), 3) AS cast,
    ROUND(AVG(country IS NULL), 3) AS country,
    ROUND(AVG(date_added IS NULL), 3) AS date_added,
    ROUND(AVG(rating IS NULL), 3) AS rating,
    ROUND(AVG(duration IS NULL), 3) AS duration
FROM
    stg_netflix;

/* ---------------------------------------------------------------------
3. SPLIT comma-separated columns  (python: unnest)
Stack the 4 columns once, split once, drop blanks, drop duplicates
within a title (keep first), renumber pos = 1,2,3...
--------------------------------------------------------------------- */
DROP TABLE IF EXISTS seq_numbers;

CREATE TABLE
    seq_numbers (n INT PRIMARY KEY);

INSERT INTO
    seq_numbers
WITH RECURSIVE
    s AS (
        SELECT
            1 AS n
        UNION ALL
        SELECT
            n + 1
        FROM
            s
        WHERE
            n < 200
    )
SELECT
    n
FROM
    s;

DROP TABLE IF EXISTS stg_split;

CREATE TABLE
    stg_split AS
WITH
    stacked AS (
        SELECT
            show_id,
            'cast' AS field,
            cast_raw AS raw_text
        FROM
            stg_netflix
        WHERE
            cast_raw IS NOT NULL
        UNION ALL
        SELECT
            show_id,
            'director' AS field,
            director AS raw_text
        FROM
            stg_netflix
        WHERE
            director IS NOT NULL
        UNION ALL
        SELECT
            show_id,
            'country' AS field,
            country AS raw_text
        FROM
            stg_netflix
        WHERE
            country IS NOT NULL
        UNION ALL
        SELECT
            show_id,
            'genre' AS field,
            listed_in AS raw_text
        FROM
            stg_netflix
        WHERE
            listed_in IS NOT NULL
    ),
    pieces AS (
        SELECT
            st.show_id,
            st.field,
            n.n AS raw_pos,
            TRIM(
                SUBSTRING_INDEX (SUBSTRING_INDEX (st.raw_text, ',', n.n), ',', -1)
            ) AS item
        FROM
            stacked st
            JOIN seq_numbers n ON n.n <= 1 + CHAR_LENGTH(st.raw_text) - CHAR_LENGTH(REPLACE (st.raw_text, ',', ''))
    ),
    first_seen AS (
        SELECT
            show_id,
            field,
            item,
            MIN(raw_pos) AS raw_pos
        FROM
            pieces
        WHERE
            item <> ''
        GROUP BY
            show_id,
            field,
            item
    )
SELECT
    show_id,
    field,
    item,
    ROW_NUMBER() OVER (
        PARTITION BY
            show_id,
            field
        ORDER BY
            raw_pos
    ) AS pos
FROM
    first_seen;

-- GATE: longest value per field. Must be < 500 (bridge column width), and the
-- most pieces in one cell must be < 200 (seq_numbers size).
SELECT
    field,
    MAX(CHAR_LENGTH(item)) AS longest_value,
    MAX(pos) AS most_values_in_a_title
FROM
    stg_split
GROUP BY
    field;

/* ---------------------------------------------------------------------
4. BRIDGE TABLES
Keys use a 100-character prefix so index size can never overflow.
--------------------------------------------------------------------- */
DROP TABLE IF EXISTS netflix_cast;

CREATE TABLE
    netflix_cast (
        show_id VARCHAR(50),
        pos INT,
        actor VARCHAR(500),
        is_lead TINYINT,
        KEY (show_id),
        KEY (actor (100))
    ) CHARACTER
SET
    utf8mb4;

INSERT INTO
    netflix_cast
SELECT
    show_id,
    pos,
    item,
    (pos = 1)
FROM
    stg_split
WHERE
    field = 'cast';

DROP TABLE IF EXISTS netflix_director;

CREATE TABLE
    netflix_director (
        show_id VARCHAR(50),
        pos INT,
        director VARCHAR(500),
        KEY (show_id),
        KEY (director (100))
    ) CHARACTER
SET
    utf8mb4;

INSERT INTO
    netflix_director
SELECT
    show_id,
    pos,
    item
FROM
    stg_split
WHERE
    field = 'director';

DROP TABLE IF EXISTS netflix_genre;

CREATE TABLE
    netflix_genre (
        show_id VARCHAR(50),
        pos INT,
        genre VARCHAR(500),
        KEY (show_id),
        KEY (genre (100))
    ) CHARACTER
SET
    utf8mb4;

INSERT INTO
    netflix_genre
SELECT
    show_id,
    pos,
    item
FROM
    stg_split
WHERE
    field = 'genre';

DROP TABLE IF EXISTS netflix_country;

CREATE TABLE
    netflix_country (
        show_id VARCHAR(50),
        pos INT,
        country VARCHAR(500),
        KEY (show_id),
        KEY (country (100))
    ) CHARACTER
SET
    utf8mb4;

INSERT INTO
    netflix_country
SELECT
    show_id,
    pos,
    item
FROM
    stg_split
WHERE
    field = 'country';

-- defunct names Tableau cannot place on a map
UPDATE netflix_country
SET
    country = 'Germany'
WHERE
    country = 'West Germany';

UPDATE netflix_country
SET
    country = 'Russia'
WHERE
    country = 'Soviet Union';

-- titles with no country stay in the data as 'Unknown'
INSERT INTO
    netflix_country (show_id, pos, country)
SELECT
    s.show_id,
    1,
    'Unknown'
FROM
    stg_netflix s
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            netflix_country c
        WHERE
            c.show_id = s.show_id
    );

/* ---------------------------------------------------------------------
5. TITLE TABLE: one row per title, typed + derived columns
--------------------------------------------------------------------- */
DROP TABLE IF EXISTS netflix_titles;

CREATE TABLE
    netflix_titles AS
WITH
    base AS (
        SELECT
            CAST(show_id AS CHAR(50)) AS show_id,
            CAST(type AS CHAR(20)) AS content_type,
            CAST(title AS CHAR(1000)) AS title,
            description,
            CAST(release_year AS SIGNED) AS release_year, -- SIGNED: allows negative differences
            STR_TO_DATE (date_added, '%M %e, %Y') AS date_added,
            CAST(
                CASE
                    WHEN rating IS NULL THEN 'Unknown'
                    WHEN rating IN ('NR', 'UR') THEN 'Not Rated'
                    ELSE rating
                END AS CHAR(20)
            ) AS rating,
            CAST(duration AS CHAR(30)) AS duration_raw,
            CASE
                WHEN type = 'Movie'
                AND duration REGEXP '^[0-9]+ min$' THEN CAST(SUBSTRING_INDEX (duration, ' ', 1) AS SIGNED)
            END AS movie_minutes,
            CASE
                WHEN type = 'TV Show'
                AND duration REGEXP '^[0-9]+ Season' THEN CAST(SUBSTRING_INDEX (duration, ' ', 1) AS SIGNED)
            END AS tv_seasons
        FROM
            stg_netflix
    ),
    cast_agg AS (
        SELECT
            show_id,
            COUNT(*) AS cast_count
        FROM
            netflix_cast
        GROUP BY
            show_id
    ),
    director_agg AS (
        SELECT
            show_id,
            COUNT(*) AS director_count
        FROM
            netflix_director
        GROUP BY
            show_id
    ),
    genre_agg AS (
        SELECT
            show_id,
            COUNT(*) AS genre_count
        FROM
            netflix_genre
        GROUP BY
            show_id
    ),
    country_agg AS (
        SELECT
            show_id,
            SUM(country <> 'Unknown') AS country_count
        FROM
            netflix_country
        GROUP BY
            show_id
    )
SELECT
    b.show_id,
    b.content_type,
    b.title,
    b.description,
    b.release_year,
    (b.release_year DIV 10) * 10 AS release_decade,
    b.date_added,
    YEAR (b.date_added) AS year_added,
    MONTH (b.date_added) AS month_added,
    MONTHNAME (b.date_added) AS month_name,
    QUARTER (b.date_added) AS quarter_added,
    YEAR (b.date_added) - b.release_year AS years_release_to_netflix,
    -- data ends 2021-09-25, so 2021 is a partial year
    CASE
        WHEN b.date_added IS NULL THEN NULL
        WHEN YEAR (b.date_added) < 2021 THEN 1
        ELSE 0
    END AS is_complete_year_added,
    b.rating,
    b.duration_raw,
    b.movie_minutes,
    b.tv_seasons,
    COALESCE(ca.country_count, 0) AS country_count,
    CASE
        WHEN COALESCE(ca.country_count, 0) > 1 THEN 1
        ELSE 0
    END AS is_co_production,
    COALESCE(pc.country, 'Unknown') AS primary_country,
    COALESCE(pg.genre, 'Unknown') AS primary_genre,
    COALESCE(ga.genre_count, 0) AS genre_count,
    COALESCE(ct.cast_count, 0) AS cast_count,
    COALESCE(dr.director_count, 0) AS director_count,
    CASE
        WHEN COALESCE(ct.cast_count, 0) > 0 THEN 1
        ELSE 0
    END AS has_cast,
    CASE
        WHEN COALESCE(dr.director_count, 0) > 0 THEN 1
        ELSE 0
    END AS has_director,
    1 AS title_count, -- SUM(title_count) = number of titles
    CASE
        WHEN COALESCE(pc.country, 'Unknown') = 'Unknown' THEN NULL -- unknown country: left out of the % calc
        WHEN pc.country = 'United States' THEN 0
        ELSE 1
    END AS is_non_us
FROM
    base b
    LEFT JOIN cast_agg ct ON ct.show_id = b.show_id
    LEFT JOIN director_agg dr ON dr.show_id = b.show_id
    LEFT JOIN genre_agg ga ON ga.show_id = b.show_id
    LEFT JOIN country_agg ca ON ca.show_id = b.show_id
    LEFT JOIN netflix_country pc ON pc.show_id = b.show_id
    AND pc.pos = 1
    LEFT JOIN netflix_genre pg ON pg.show_id = b.show_id
    AND pg.pos = 1;

ALTER TABLE netflix_titles ADD PRIMARY KEY (show_id);

/* ---------------------------------------------------------------------
6. DIRECTOR x ACTOR NETWORK TABLE
--------------------------------------------------------------------- */
DROP TABLE IF EXISTS netflix_director_actor;

CREATE TABLE
    netflix_director_actor AS
SELECT
    d.show_id,
    d.director,
    c.actor,
    c.is_lead,
    t.content_type,
    t.primary_country,
    CONCAT (d.director, ' & ', c.actor) AS pair -- label for the pairs chart
FROM
    netflix_director d
    JOIN netflix_cast c ON c.show_id = d.show_id
    JOIN netflix_titles t ON t.show_id = d.show_id;

/* ---------------------------------------------------------------------
7. CHECKS  (compare these with the numbers netflix_prep.py prints)
--------------------------------------------------------------------- */
SELECT
    COUNT(*) AS titles,
    COUNT(DISTINCT show_id) AS distinct_ids
FROM
    netflix_titles;

SELECT
    content_type,
    COUNT(*)
FROM
    netflix_titles
GROUP BY
    content_type;

SELECT
    MIN(date_added),
    MAX(date_added),
    MAX(cast_count) AS max_cast
FROM
    netflix_titles;

SELECT
    'netflix_titles' AS tbl,
    COUNT(*) AS n
FROM
    netflix_titles
UNION ALL
SELECT
    'netflix_cast',
    COUNT(*)
FROM
    netflix_cast
UNION ALL
SELECT
    'netflix_director',
    COUNT(*)
FROM
    netflix_director
UNION ALL
SELECT
    'netflix_country',
    COUNT(*)
FROM
    netflix_country
UNION ALL
SELECT
    'netflix_genre',
    COUNT(*)
FROM
    netflix_genre
UNION ALL
SELECT
    'netflix_director_actor',
    COUNT(*)
FROM
    netflix_director_actor;

/* Optional cleanup */
-- DROP TABLE stg_netflix; DROP TABLE stg_split; DROP TABLE seq_numbers;