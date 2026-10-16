# Netflix Data Analysis & Content Strategy Project

## About Netflix

Netflix is one of the world's leading media and video streaming platforms. As of mid-2021, Netflix boasts over 222 million subscribers globally with a vast library of over 10,000 movies and TV shows. This dataset consists of listings of all available movies and TV shows on the platform, along with attributes such as cast, directors, ratings, release year, duration, genres, and country of origin.

## Business Problem

Analyze the dataset and generate data-driven insights to assist Netflix executive leadership in deciding:

1. **Content Strategy:** Which types of shows and movies to produce or acquire.
2. **Global Expansion:** How to grow subscriber bases and optimize content strategy across different geographic markets.

## Dataset Overview

[Dataset Link](https://d2beiqkhq929f0.cloudfront.net/public_assets/assets/000/000/940/original/netflix.csv)

| Column Name | Data Type | Description |
| --- | --- | --- |
| `show_id` | Object / String | Unique identifier for every Movie / TV Show |
| `type` | Categorical / String | Content identifier (`Movie` or `TV Show`) |
| `title` | Object / String | Title of the Movie or TV Show |
| `director` | Object / String | Director(s) of the movie/show (comma-separated if multiple) |
| `cast` | Object / String | Actors involved in the movie/show (comma-separated) |
| `country` | Object / String | Country or countries where the movie/show was produced |
| `date_added` | Datetime / String | Date the title was added to the Netflix platform |
| `release_year` | Integer | Actual calendar release year of the content |
| `rating` | Categorical / String | TV / Motion Picture rating (e.g., TV-MA, PG-13, TV-14) |
| `duration` | Object / String | Total duration (minutes for Movies, number of Seasons for TV Shows) |
| `listed_in` | Object / String | Genres / Categories (comma-separated) |
| `description` | Object / String | Brief summary or synopsis |


## Exploration & Guidance Rules

1. **Goal-Oriented Analysis:** Focus all exploration on actionable business outcomes—what to produce, where to invest, and how to scale globally.
2. **Data-Backed Insights:** Ensure every strategy and recommendation is directly grounded in statistical evidence and visual findings.
3. **Executive Communication:** Present findings clearly for non-technical stakeholders, avoiding unnecessary machine learning or statistical jargon.
4. **Key Analytical Focus Areas:**
    * How content availability varies across geographic regions.
    * Movie volume trends per year over the last 20–30 years.
    * Comparative volume and retention analysis: TV Shows vs. Movies.
    * Optimal seasonality and timing for launching new titles.
    * Lead actor and director networks per category and country.
    * Evaluating whether Netflix's production focus has shifted toward TV Shows over Movies in recent years.



## Project Evaluation Criteria

1. **Defining Problem Statement and Analysing Basic Metrics**
    * Define clear business objectives, initial data overview, and core operational metrics.


2. **Observations on Data Architecture & Pre-processing**
        * Detail dataset shape, data types of all attributes, conversion of categorical attributes to 'category' where appropriate, missing value detection, and statistical summary.


3. **Non-Graphical Analysis**
    * Perform cardinality checks, value counts, unique attribute analysis, and frequency distributions.


4. **Visual Analysis — Pre-processed Data**
    * *Note: Pre-processing requires unnesting of comma-separated string columns such as Actor, Director, and Country.*
    * **4.1 Continuous Variables:** Univariate analysis using Distplot, Countplot, and Histogram.
    * **4.2 Categorical Variables:** Analysis using Boxplots across categories.


5. **Missing Value & Outlier Check**
    * Identify missing value proportions, analyze outlier distributions, and document appropriate treatment/handling strategies.


6. **Insights Based on Non-Graphical and Visual Analysis**
    * 6.1 Comments on the range of attributes.
    * 6.2 Comments on the distribution of variables and the relationships between them.
    * 6.3 Detailed interpretation for each univariate and bivariate plot.


7. **Business Insights**
    * Synthesize patterns observed in the data alongside clear inferences regarding market trends and viewer habits.


8. **Recommendations**
    * Provide plain-language, actionable business items for leadership—no technical jargon or complex complications.