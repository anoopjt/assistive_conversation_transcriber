"""
faztp12
B7VYcy57EDV72yQO

mongodb+srv://faztp12:<password>@cluster0-l1t8j.mongodb.net/test?retryWrites=true&w=majority
"""

from mongoengine import connect


mongo_host = "mongodb+srv://faztp12:B7VYcy57EDV72yQO@cluster0-l1t8j.mongodb.net/test?retryWrites=true&w=majority"
connect("ACT", host=mongo_host)