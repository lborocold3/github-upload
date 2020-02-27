
# myscript.py

from __future__ import print_function

import cx_Oracle

# Connect as user "hr" with password "welcome" to the "orclpdb1" service running on this computer.
connection = cx_Oracle.connect("l20565", "Zong1damimi!", "AEPW04")

cursor = connection.cursor()
cursor.execute("""
        select * from
        ae_dim.dim_v_cc_check_type""",
)
for CHECK_TYPE in cursor:
    print("Values:", CHECK_TYPE)