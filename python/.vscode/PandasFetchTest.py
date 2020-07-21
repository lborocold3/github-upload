#%%
import snowflake.connector
import db_config
import pandas as pd
import json
from pandas.io.json import build_table_schema, json_normalize  


#%%
ctx = snowflake.connector.connect(
          user=db_config.sfuser,
          password=db_config.sfpassword,
          account=db_config.sfaccount,
          warehouse=db_config.sfwarehouse,
          database=db_config.sfdatabase,
          schema=db_config.sfschema,
          )

# Create a cursor object.
cur = ctx.cursor()

# Execute a statement that will generate a result set.
sql = "select top 10 * from HDL_T_EQUIFAX_JSON_COMMERCIAL"
cur.execute(sql)

#%%
# Fetch the result set from the cursor and deliver it as the Pandas DataFrame.
df = cur.fetch_pandas_all()

# %%

for i in range(df.shape[0]) :
    pd[i]=json.loads(df.iloc[i]['EQUIFAX_DATA'])

# %%
data=json_normalize(data=pd,record_path='characteristics',meta=['transactionId'],errors='ignore')

# %%dapi6837e9b40ae4f63b47c7c9b386c89acc
# https://adb-7217304362640423.3.azuredatabricks.net/?o=7217304362640423
#databricks configure --token

# %%
