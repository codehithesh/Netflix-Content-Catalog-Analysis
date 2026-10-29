![alt text](https://github.com/codehithesh/Netflix-Content-Catalog-Analysis/blob/main/assets/screenshots/s1.png)

# Netflix Content Catalog Analysis: Movies vs. TV Shows, Geography, and Release Timing
A Tableau and SQL look at Netflix's media records.

## Executive Summary
Most of Netflix's catalog is movies, at 69.6% Movies versus 30.4% TV Shows. But among titles added from 2018 to 2021, TV Shows make up 46.8%. That suggests Netflix is leaning more on serialized content to keep people watching and subscribed, while still holding a big library of movies to attract new viewers. The growth plan should balance both, depend less on any single country, and offer more localized content. Check [Netflix Dashboard](https://public.tableau.com/app/profile/hithesh.v1025/viz/NetflixTimingTalent/d3TimingTalent).

## About Business
Netflix is one of the biggest media and video streaming platforms in the world. By mid-2021 it had over 222 million subscribers and a library of over 10,000 movies and TV shows. The dataset lists everything available on the platform, along with the cast, directors, ratings, release year, duration, genres, and country of origin for each title.

## Problem Statement
The goal is to dig into this dataset and give Netflix's leadership data-backed answers to two questions:

1. **Content Strategy:** What kinds of shows and movies should Netflix produce or acquire?
2. **Global Expansion:** How can Netflix grow its subscriber base and tune its content for different regions?

## Data Schema (ERD)
* Tables: netflix
* Total Records: 8,807

![alt text](https://github.com/codehithesh/Netflix-Content-Catalog-Analysis/blob/main/assets/erd/erd.png)


## Metrics

**Primary metrics**
* **TV Show share of catalog by year added**: TV Shows divided by all titles, grouped by the year in `date_added`. It tells us whether the catalog is moving toward TV Shows.
* **TV Show share by release year**: the same ratio, grouped by `release_year`. It helps separate "Netflix is adding more TV Shows" from "newer content is simply more often a TV Show."

**Secondary metrics**
* Title count by type (Movie vs. TV Show) per year, shown in absolute numbers next to the share
* Title count by country (after unnesting `country`), plus the Movie/TV split within the top countries
* Title count by genre (after unnesting `listed_in`), split by type
* Titles added per month (from `date_added`), to spot release-timing patterns
* Rating mix (`rating`) by type
* Median movie duration (in minutes) and median number of seasons for TV Shows
* Top directors and cast by count, per type and country

**Guardrail metrics**
* Missing values: the share of nulls in `director`, `cast`, `country`, `date_added`, and `rating`. Country and director analyses only cover titles that actually have those fields.
* Unnesting inflation: the number of titles after unnesting `country`, `cast`, and `listed_in` compared with the original rows. A title with several countries is counted once per country, so shares won't add up to 100%.
* Partial-year check: 2021 is flagged because the data ends mid-year, so its lower counts and trends shouldn't be read as a decline.
* Sample size per slice: the minimum number of titles behind any country or genre claim
* Duplicate titles: how many `title` entries repeat


## Insights

#### Content Mix
|  |  |
| ------------- | ------------- |
| ![Chart 1](https://github.com/codehithesh/Netflix-Content-Catalog-Analysis/blob/main/assets/charts/chart_1.jpg) | ![Chart 2](https://github.com/codehithesh/Netflix-Content-Catalog-Analysis/blob/main/assets/charts/chart_2.jpg) |
* Movies make up most of the overall catalog, but TV Shows take a much bigger share of what was added recently.
* The portfolio is slowly tilting toward serialized content, which can help reduce churn and keep viewers more engaged.
* It looks like Netflix is moving away from buying content purely for volume and toward programming that keeps people subscribed.

#### Geographic Concentration
|  |  |
| ------------- | ------------- |
| ![Chart 3](https://github.com/codehithesh/Netflix-Content-Catalog-Analysis/blob/main/assets/charts/chart_3.jpg) | ![Chart 4](https://github.com/codehithesh/Netflix-Content-Catalog-Analysis/blob/main/assets/charts/chart_4.jpg) |
* The United States has the most titles, followed by India and the UK.
* Netflix still leans heavily on US-produced content, which leaves it exposed to regional competitors and limits how much it can localize.
* Fast-growing markets outside the US would likely benefit from more investment in local-language and local-market content.

#### Release Timing and Seasonal Trends
|  |  |
| ------------- | ------------- |
| ![Chart 5](https://github.com/codehithesh/Netflix-Content-Catalog-Analysis/blob/main/assets/charts/chart_5.jpg) | ![Chart 6](https://github.com/codehithesh/Netflix-Content-Catalog-Analysis/blob/main/assets/charts/chart_6.jpg) |
* Most titles are added in Q4, especially from October to December, with smaller bumps in January and July.
* Netflix seems to time its big releases for periods when people watch more.
* So the launch date is a real lever for capturing subscriber attention and getting more out of marketing spend.

#### Genre and Rating Patterns
|  |  |
| ------------- | ------------- |
| ![Chart 7](https://github.com/codehithesh/Netflix-Content-Catalog-Analysis/blob/main/assets/charts/chart_7.jpg) | ![Chart 8](https://github.com/codehithesh/Netflix-Content-Catalog-Analysis/blob/main/assets/charts/chart_8.jpg) |
* Movies are mostly dramas, documentaries, and comedies.
* TV Shows are led by TV dramas, crime shows, and international series.
* The ratings lean toward mature audiences, with TV-MA and TV-14 covering a big part of the library.
* That makes the catalog feel adult-focused, which leaves room to grow in family-friendly and co-viewing content.

## Recommendations

### 1. Accelerate local original production in top non-US markets
- **Action:** Put more content investment into India, the UK, Canada, France, and Japan.
- **Business case:** Local content feels more relevant to viewers and lowers Netflix's reliance on a US-heavy catalog.
- **KPI:** Grow the non-US share of new additions over time.

### 2. Maintain a TV-first strategy in mature markets
- **Action:** Invest more in TV Shows in saturated markets, where keeping subscribers matters more than winning new ones.
- **Business case:** Serialized content usually keeps people watching longer and makes them less likely to cancel.
- **KPI:** Keep TV Shows at a high share of new releases in premium markets.

### 3. Match major launches to seasonal viewing peaks
- **Action:** Schedule flagship TV releases in October and November.
- **Business case:** Demand is stronger in Q4, when people watch more and holiday habits kick in.
- **KPI:** Make sure the biggest series launch during the Q4 window.

### 4. Expand family-friendly content
- **Action:** Invest more in TV-Y7 and TV-G titles.
- **Business case:** Family and co-viewing audiences are still under-served by the current catalog mix.
- **KPI:** Raise the share of family-rated titles in the catalog.

### 5. Build partnerships with local creators and talent
- **Action:** Sign exclusive deals with leading local directors and producers in high-potential markets.
- **Business case:** Regional talent builds trust and authenticity, and it helps content reach more people.
- **KPI:** Develop regional partnerships in key growth markets.

### 6. Focus movies on quality and impact rather than volume
- **Action:** Cut back on low-impact movie acquisitions and put the money into globally appealing, premium titles.
- **Business case:** Movies work best for attracting new subscribers and building prestige, while TV Shows do a better job of keeping people around.
- **KPI:** Back fewer movies, but make each one count for more.

## Limitations
* The dataset tells us what is in the catalog, not what people actually watch or how engaged subscribers are.
* `date_added` shows when a title showed up on the platform, which isn't always when it was originally produced.
* Titles with several genres can make a category look more popular than it really is.
* This is a descriptive analysis. It points out patterns and a strategic direction, but it can't prove what caused them.

## Tech Stack
* Tableau
* Python
* Jupyter Notebook
* pandas
* NumPy
* Matplotlib
* Seaborn

## How to run
* Open `netflix_data_prep_for_tableau.ipynb` in Jupyter Notebook.
* Run all cells in order from the notebook menu (`Cell` -> `Run All` or `Run All Above`).
* Make sure the required Python packages are installed before you run the notebook.
* Import data in Tableau and start plotting OR check `assets/tableau/NetflixTimingTalent.twbx`
* Dashboard link: [Netflix Dashboard](https://public.tableau.com/app/profile/hithesh.v1025/viz/NetflixTimingTalent/d3TimingTalent)
