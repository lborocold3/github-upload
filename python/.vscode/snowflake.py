import snowflake.connector
import db_config
import pandas as pd


con = snowflake.connector.connect(
    user=db_config.sfuser,
    password=db_config.sfpassword,
    account=db_config.sfaccount,
    warehouse=db_config.sfwarehouse,
    database=db_config.sfdatabase,
    schema=db_config.sfschema
)

cur = con.cursor()
sql = "SELECT * FROM HDL_T_EQUIFAX_JSON_CONSUMER"

try:
    cur.execute(sql)
    for col1 in cur:
            print('{0}'.format(col1))
finally:
    cur.close()



#%%
def fetch_pandas_old(cur, sql):
    rows = 0
    while True:
        dat = cur.fetchmany(2)
        if not dat:
            break
        df = pd.DataFrame(dat, columns=cur.description)
        rows += df.shape[0]
    print(rows)
