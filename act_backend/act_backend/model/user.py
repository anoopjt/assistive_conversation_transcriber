from mongoengine import Document, StringField, EmailField

class User(Document):
  email = EmailField(required=True, unique=True)
  first_name = StringField(required=True)
  last_name = StringField(required=True)