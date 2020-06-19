from flask import Flask, request
from ..model.user import User
from mongoengine import QuerySet
import jwt, datetime

def init_app(app):
  app = app # type: Flask

  def get_jwt(user: User):
    encoded_jwt = jwt.encode({
      'email': user.email,
      'name': user.name,
      'exp': datetime.datetime.utcnow() + datetime.timedelta(days=365)
    }, 'secret', algorithm='HS256')
    return encoded_jwt.decode('utf-8')

  @app.route("/api/google-login", methods=["POST"])
  def google_auth():
    """
    POST {
      email: <>
      name: <>
      google_id
      google_access_token: <>
    }
    """
    data = request.json
    existing_users: QuerySet = User.objects(provider_id=data["google_id"], provider_type="google")
    if existing_users.count() > 0:
      user = existing_users.first()
    else:
      user = User(email=data["email"], name=data["name"], provider_id=data["google_id"], provider_type="google")
      user.save()
    
    return {
      "jwt_token": get_jwt(user)
    }

  @app.route("/api/fb-login", methods=["POST"])
  def facebook_login():
    """
    POST {
      email: <>
      name: <>
      fb_id: <>
      fb_access_token: <>
    }
    """
    data = request.json
    existing_users: QuerySet = User.objects(provider_id=data["fb_id"], provider_type="fb")
    if existing_users.count() > 0:
      user = existing_users.first()
    else:
      user = User(email=data["email"], name=data["name"], provider_id=data["fb_id"], provider_type="fb")
      user.save()
    
    return {
      "jwt_token": get_jwt(user)
    }
  
  @app.route("/api/auth-user")
  def currentUser():
    data = request.json
    try:
      user = get_user(data["jwt"])
      return {
        "status": "success",
        "email": user.email
      }
    except:
      return {
        "status": "fail"
      }


def get_user(token):
  payload = jwt.decode(token, 'secret', algorithms='HS256')
  existing_users: QuerySet = User.objects(email=payload["email"])
  if existing_users.count():
    return existing_users.first()
  else:
    raise Exception("Invalid User")