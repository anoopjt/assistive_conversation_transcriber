from flask import Flask

def init_app(app):
  app = app # type: Flask
  
  @app.route("/api/login")
  def login():
    return "Login"

  @app.route("/api/signup")
  def signup():
    return "signup"

  @app.route("/api/google-auth")
  def google_auth():
    return "google-auth"