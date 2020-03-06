# myscript.py

from __future__ import print_function

import cx_Oracle
import db_config

# Connect as user "hr" with password "welcome" to the "orclpdb1" service running on this computer.
connection = cx_Oracle.connect(db_config.user, db_config.pw, db_config.dsn)
print("Database version:", connection.version)

cursor = connection.cursor()
cursor.execute("""
        select CHECK_TYPE_ID, CHECK_TYPE, REQUEST_TYPE from 
        ae_dim.dim_v_cc_check_type""")
for a,b,c in cursor:
    print("Values:", a,b,c)