Region mapping, genre merging, audience groups, duration buckets are ignored.

## Data cleaning steps

1. **Load everything as plain text** and drop the stray unnamed index column from your sample.
2. **Tidy the text.** Trim extra spaces, remove hidden line-break characters, and turn empty strings into proper missing values.
3. **Fix shifted values.** A few titles have the runtime typed into `rating` with `duration` blank. Move it back into `duration` and mark the rating as missing.
4. **Check for duplicates** by show ID, and by title, type and release year. Only check. Don't delete anything.
5. **Split the comma-separated columns** (cast, director, country, genre) into one row per title per value.
   - Trim each value and drop blanks.
   - Drop repeats within the same title.
   - Number the values 1, 2, 3 in listed order, so the first actor, country and genre can be identified.
6. **Handle countries.**
   - Give titles with no country the value "Unknown", so they still count.
   - Rename West Germany to Germany and Soviet Union to Russia, so Tableau can map them.
   - Don't group countries into regions. Plot country names directly.
7. **Keep genres as listed.** Don't merge "Dramas" with "TV Dramas". Note in your report that the Movie and TV versions appear separately.
8. **Flag the lead actor** as the first one listed.
9. **Build one clean row per title with proper types.**
   - Convert release year to a number and `date_added` to a real date.
   - Replace missing ratings with "Unknown", and NR and UR with "Not Rated".
   - Split duration into `movie_minutes` (movies) and `tv_seasons` (TV shows).
10. **Add derived columns.**
    - Year, month, month name and quarter added, plus release decade.
    - Years between release and arrival on Netflix. Use a signed number, since some titles were added before their release year.
    - A complete-year flag. The data ends on 25 September 2021, so 2021 is partial.
    - First-listed country and genre, counts of cast, directors, countries and genres, and a co-production flag.
    - `has_cast` and `has_director` flags.
    - `title_count` (always 1) and `is_non_us` (blank when the country is unknown).
11. **Build a director–actor pairs table** with a `pair` label column, for the network question.
12. **Convert** `content_type`, `rating`, `primary_country` and `primary_genre` to the `category` type in pandas. Your rubric asks for it.
13. **Run validation checks.** Compare row counts across all six tables between SQL and Python, check the missing-value shares, and check that the distinct show IDs equal the row count.

## What not to do 
- Don't delete rows or fill in missing values.
- Don't remove outliers from the data (very long movies, shows with many seasons). Show them in the Tableau box plot and report them.
- Don't add a region mapping, genre merging, audience groups or duration buckets. They are judgment calls your brief doesn't require, and each one is something you'd have to defend.

## Essential vs optional
- **Essential:** steps 1–5, 9, and the complete-year flag.
- **Optional:** the director–actor table, and the extra flags and counts in step 10. Skip them if you don't need the network or co-production charts.



## Nice to have 

1. **Region grouping for countries.**
   - Add a `region` column to the country table (North America, Latin America, Europe, Asia, Middle East & North Africa, Sub-Saharan Africa, Oceania, Unknown).
   - Write the country-to-region rule down in your report, and settle borderline cases (Turkey, Russia, Egypt, Mexico) before you build charts.
   - Add it only if your brief needs continent-level comparisons. The country map already covers geographic availability. In Tableau you can also group countries by hand.

2. **Merged genre names.**
   - Map Movie and TV variants to one name: "Dramas" and "TV Dramas" → Drama, "Comedies" and "TV Comedies" → Comedy, "Documentaries" and "Docuseries" → Documentary, and so on.
   - Keep the raw genre in a separate column so you can always compare with it.
   - Do this if you want to compare the same genre across Movies and TV. It is a maintained list of about 35 pairs, which is why it was the long block.

3. **Audience groups from ratings.**
   - Add an `audience_group` column: Kids (TV-Y, TV-Y7, TV-Y7-FV, TV-G, G), Older Kids (PG, TV-PG), Teens (PG-13, TV-14), Adults (R, TV-MA, NC-17), Not Rated / Unknown.
   - Add it if you want a four-bar audience chart instead of a dozen rating codes.

4. **Duration buckets.**
   - Movies: under 60, 60–89, 90–119, 120–149, and 150+ minutes. TV: 1 season, 2 seasons, 3+ seasons.
   - Skip it if the Tableau histogram on `movie_minutes` and the `tv_seasons` chart are enough. They are.

5. **Weekday added.**
   - Add `weekday_added` (Monday to Sunday).
   - Add it only if you want to study which day titles get added. Month and quarter already cover your seasonality question.

6. **Any US involvement flag.**
   - Add `has_us_involvement` (1 if any listed country is the United States).
   - Use it when `is_non_us`, which looks only at the first-listed country, is too strict. A US–India co-production counts as US under `is_non_us`.

7. **Complete release year flag.**
   - Add `is_complete_release_year` (0 for 2021, 1 for earlier years).
   - Use it if you chart release years through 2021 and don't want to filter by hand.

## Rule for adding any of these
- Add the same column, with the same rule, to both `netflix_prep.py` and `netflix_prep.sql`.
- Re-run the comparison on a small sample file and confirm the two scripts still produce identical tables.

Items 3 and 4 are the cheapest to add (one `CASE` or one `pd.cut`). Items 1 and 2 are the most work, because they need a lookup list that you maintain.