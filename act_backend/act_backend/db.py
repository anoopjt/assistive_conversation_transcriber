from mongoengine import connect
import os
mongo_host = os.environ.get("mongo_url")
if not mongo_host:
  raise Exception("Please provider mongo_url Env. var")
connect("ACT", host=mongo_host)
print("DB INIT")