import numpy as np
import pandas as pd
import db_config
from sqlalchemy.engine import create_engine

engine = create_engine(URL(
    account = db_config.sfaccount,
    user = db_config.sfuser,
    password = db_config.sfpassword,
    database = db_config.sfdatabase,
    schema = db_config.sfschema,
    warehouse = db_config.sfwarehouse,
    role=db_config.sfrole,

))

specific_date = np.datetime64('2016-03-04T12:03:05.123456789Z')

connection = engine.connect()
connection.execute(
    "CREATE OR REPLACE TABLE ts_tbl(c1 TIMESTAMP_NTZ)")
connection.execute(
    "INSERT INTO ts_tbl(c1) values(%s)", (specific_date,)
)
df = pd.read_sql_query("SELECT * FROM ts_tbl", engine)
assert df.c1.values[0] == specific_date