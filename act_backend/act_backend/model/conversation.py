from mongoengine import Document, StringField, EmailField, ReferenceField, ListField, EmbeddedDocumentField, IntField, EmbeddedDocument
from .user import User

class ConversationMessage(EmbeddedDocument):
  timestamp = IntField(required=True)
  message = StringField(required=True)
  owner = ReferenceField(User)

class Conversation(Document):
  owner = ReferenceField(User)
  members = ListField(ReferenceField(User))
  messages = ListField(EmbeddedDocumentField(ConversationMessage))