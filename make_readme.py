import pandas as pd
import sqlite3


db = sqlite3.connect("wdi.sqlite3")

queries = [
    "select count(*) as num_countries from wdi_country",
    "select country_code, long_name, currency_unit from wdi_country limit 5",
    "select series_code, indicator_name, substr(long_definition, 0, 500)||'...' as definition from wdi_series order by random() limit 30",
    """
      with newest_data as (
        select country_code, indicator_code, max(year) as year from wdi_data
        where
          indicator_code = (select series_code from wdi_series where indicator_name = 'Literacy rate, youth total (% of people ages 15-24)')
          and year > 2010
          group by country_code
      )
      select c.long_name as country, printf('%.1f %%', value) as "Youth Literacy Rate"
      from wdi_data, newest_data
        join wdi_country c on c.country_code = wdi_data.country_code
      where wdi_data.indicator_code = newest_data.indicator_code and wdi_data.country_code = newest_data.country_code and wdi_data.year = newest_data.year
      order by value asc limit 20
    """,
    "select * from sqlite_master"
]

for query in queries:
    print(f"**`{query}`**")
    print()
    print(pd.read_sql_query(query, db).to_markdown(tablefmt="pipe"))
    print()

