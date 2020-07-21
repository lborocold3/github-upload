#!/usr/bin/env python
from sqlalchemy import create_engine

engine = create_engine(
    'snowflake://{user}:{password}@{account}/'.format(
        user='L20565',
        password='Zong1damimi!',
        account='eonuk.west-europe.azure',
    )
)
try:
    connection = engine.connect()
    results = connection.execute('select current_version()').fetchone()
    print(results[0])
finally:
    connection.close()
    engine.dispose()