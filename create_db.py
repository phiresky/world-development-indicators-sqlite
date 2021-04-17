# %%
import pandas as pd
import sqlite3


def data():
    frame = pd.read_csv("WDIData.csv")
    frame = proc_tbl(frame)
    frame = frame.drop(columns=["country_name", "indicator_name"])

    frame = frame.set_index(["indicator_code", "country_code"], verify_integrity=True)
    # frame = frame.stack()
    frame = frame.stack().rename_axis(index={None: "year"}).rename("value")
    # convert year to int
    frame.index = frame.index.set_levels(frame.index.levels[-1].astype(int), level=-1)
    return frame

def proc_tbl(df: pd.DataFrame) -> pd.DataFrame:
    # data contains an unnamed column with only null values
    return df.dropna(axis="columns", how="all").rename(axis="columns", mapper=lambda n: n.lower().replace(" ", "_"))

def table_name(csv: str):
    return csv.replace("-","_").replace("WDI", "wdi_").lower()
# %%
with sqlite3.connect("wdi.sqlite3") as c:
    print("reading data")
    d = data()
    print("saving data")
    d.to_sql(table_name("WDIData"), con=c)
    for csv in [
        "WDICountry",
        "WDICountry-Series",
        "WDIFootNote",
        "WDISeries",
        "WDISeries-Time",
    ]:
        tblname = table_name(csv)
        print(f"{csv} -> {tblname}")
        proc_tbl(pd.read_csv(f"{csv}.csv")).to_sql(tblname, con=c, index=False)
        # c.execute(f"create index on {tblname}")
    print("vacuuming")
    c.execute("vacuum")