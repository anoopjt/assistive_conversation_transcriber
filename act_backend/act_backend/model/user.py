from mongoengine import Document, StringField, EmailField

class User(Document):
  email = EmailField(required=True, primary_key=True)
  name = StringField(required=True)
  provider_type = StringField(required=True)
  provider_id = StringField(unique=True)