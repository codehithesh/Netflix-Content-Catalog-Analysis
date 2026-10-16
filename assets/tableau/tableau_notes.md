## 0. Setup (once)
1. Use Tableau Public Desktop. Connect → **Text file** → `netflix_titles.csv`.
2. Drag the other five CSVs onto the canvas. Each must link to `netflix_titles` on `show_id`, as a relationship (a line between tables), not a join.
3. In the Data pane, right-click and convert these to **Dimension**: `release_year`, `release_decade`, `year_added`, `month_added`, `quarter_added`, `tv_seasons`.
4. `title_count`. It sums correctly because the tables are related, not joined.
5. Right-click `is_non_us` → Default Properties → Aggregation → **Average**, and Number Format → **Percentage**. Do the same for `is_co_production`.
6. Right-click `netflix_country.country` → Geographic Role → **Country/Region**.
7. Bars grouped by genre, country or person add up to more than your title total, because one title appears in several groups. That is intended. Say so in the report.

## Q1. Where is content available?
**Sheet 1, World map**
- Double-click `country`, drag `title_count` to Color, and set the mark type to Filled Map.
- Filter `country` → exclude **Unknown**.
- Click the "unknown locations" note at the bottom right and check which names Tableau couldn't plot.

**Sheet 2, Top 15 countries**
- `country` on Rows, `title_count` on Columns, `content_type` on Color.
- `country` filter → Top tab → By field → Top 15 by Sum of title_count. Exclude Unknown.
- Sort descending.

## Q2. Movie volume per year (last 20–30 years)
**Sheet 3, Movies by release year**
- Filter `content_type` = Movie.
- Drag `release_year` to Columns, open the pill menu and choose **Continuous**. Put `title_count` on Rows (line).
- Drag `release_year` to Filters → Range of values → 1995–2020. If the dialog shows only a list, tick the years instead.
- 2021 is partial, so leave it out or label it "to September".

## Q3. Movies vs TV: volume and "retention"
**Sheet 4, Titless added per year**
- `year_added` on Columns, `title_count` on Rows, `content_type` on Color (lines).
- Filter `is_complete_year_added` = 1 (this excludes partial 2021). Use min or max ass agg.

**Sheet 5, TV seasons**
- `tv_seasons` on Columns, `title_count` on Rows. Add `title_count` to Label, then right-click it → Quick Table Calculation → Percent of Total.
- There is no viewership data, so seasons per show is the only retention proxy. Name it that in the write-up.

**Sheet 6, Movie length (histogram)**
- Select `movie_minutes` → Show Me → Histogram. Right-click the bin field `(movie minutes (bin))` in columns → Edit → size 10.

## Q4. Best time to launch
**Sheet 7, Month × year heatmap**
- `month_name` on Columns, `year_added` on Rows, `title_count` on Color, mark type Square. Add `title_count` to Label.
- Sort `month_name`: Sort → By Field → `month_added` → Minimum → Ascending.
- Filter `is_complete_year_added` = 1, and show a `content_type` filter.
- This is the month titles were added to Netflix, not released, so it shows Netflix's own schedule.

## Q5. Who is behind the content
**Sheet 8, Top 10 directors**
- `director` on Rows, `title_count` on Columns, Top 10 by Sum of title_count.
- Show filters for `content_type` and `country`.

**Sheet 9, Top 10 lead actors**
- Same as sheet 8 with `actor`. Add a filter `is_lead` = 1.

**Sheet 10, Top director–actor pairs**
- `pair` on Rows, `title_count` on Columns, Top 15 by Sum of title_count.
- Name collisions are possible, because two different people can share a name.

## Q6. Has Netflix shifted to TV?
**Sheet 11, TV share by release year**
- `release_year` (continuous, filtered 1995–2020) on Columns, `title_count` on Rows, `content_type` on Color, as stacked bars.
- Right-click the `title_count` pill → Quick Table Calculation → Percent of Total → Compute Using → `content_type`.
- Also check the opposite view: counts per year, since a rising TV share can hide shrinking movie counts.

## Global expansion
**Sheet 12, Non-US share**
- `year_added` on Columns, `AVG(is_non_us)` on Rows (line), filtered to complete years.
- Add `is_co_production` as a second line.
- title_count with an unknown country are left out of this percentage, by design.

**Sheet 13, Genres**
- `genre` on Rows, `title_count` on Columns, `content_type` on Color, Top 15.
- "Dramas" and "TV Dramas" appear separately, since we dropped the genre merge.

**Sheet 14, Ratings**
- `rating` on Rows, `title_count` on Columns, `content_type` on Color, sorted descending.

## Outliers (rubric item 5)
**Sheet 15, Movie length box plot**
- Turn Analysis → Aggregate Measures **off**. Put `release_decade` on Columns and `movie_minutes` on Rows. Drag `show_id` to Detail.
- Set the mark type to Circle. From the Analytics pane, drag **Box Plot** onto the view.
- Report the outliers. Don't delete them.

## Dashboards
1. **Content Mix & Trends:** sheets 4, 3, 11, 6 and 5.
2. **Global Footprint:** sheets 1, 2, 12 and 13. Select the map and click the filter icon ("Use as Filter").
3. **Timing & Talent:** sheets 7, 14, 8, 9 and 10.

For each dashboard: New Dashboard → Size → Automatic. Drag the sheets in, place the `content_type` filter once and apply it to all sheets, and give each chart a title that states the finding.

## Publish
File → Save to Tableau Public As, and copy the share link.

The filter dialogs and menus may be worded slightly differently in your Tableau version. The field names and aggregations won't change.

## Gaps
- A true director–actor network graph is impractical in Tableau. Show the top pairs as a bar chart with a calculated field `[director] + " & " + [actor]` from `netflix_director_actor`.
- Tableau has no distplot. Use the histogram, and say so in the write-up.