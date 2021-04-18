# indices with readable names
sqlite3 wdi.sqlite3 -cmd '.echo on' 'drop index ix_wdi_data_indicator_code_country_code_year;'
sqlite3 wdi.sqlite3 -cmd '.echo on' 'create index "index on wdi_data (indicator_code, country_code, year, value)" on wdi_data(indicator_code,country_code,year,value);'
sqlite3 wdi.sqlite3 -cmd '.echo on' 'create index "index on wdi_series (indicator_name)" on wdi_series (indicator_name);'

sqlite3 wdi.sqlite3 -cmd '.echo on' '
drop index ix_wdi_country_country_code; 
create index "index on wdi_country (country_code)" on wdi_country (country_code);
drop index ix_wdi_country_series_country_code_indicator_code; 
create index "index on wdi_country_series (country_code, indicator_code)" on wdi_country_series (country_code, indicator_code);
drop index ix_wdi_series_indicator_code; 
create index "index on wdi_series (indicator_code)" on wdi_series (indicator_code);
'

sqlite3 wdi.sqlite3 -cmd '.echo on'  'create virtual table indicator_search using fts5(
    indicator_code, topic, indicator_name,short_definition,long_definition,statistical_concept_and_methodology, development_relevance,
    content=wdi_series,
    prefix=3
);
insert into indicator_search(rowid, indicator_code, topic, indicator_name,short_definition,long_definition,statistical_concept_and_methodology, development_relevance)
select rowid, indicator_code, topic, indicator_name,short_definition,long_definition,statistical_concept_and_methodology, development_relevance from wdi_series;'
sqlite3 wdi.sqlite3 -cmd '.echo on'  "insert into indicator_search(indicator_search, rank) values ('rank', 'bm25(10, 1, 20, 2, 2, 1, 1)');" # default column rankings
sqlite3 wdi.sqlite3 -cmd '.echo on'  "insert into indicator_search(indicator_search) values ('optimize');"
sqlite3 wdi.sqlite3 -cmd '.echo on'  'pragma page_size = 1024;vacuum;'
sqlite3 wdi.sqlite3 -cmd '.echo on'  'analyze'
