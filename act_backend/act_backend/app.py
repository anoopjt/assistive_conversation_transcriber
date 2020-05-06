from flask import Flask, session
from flask_session import Session


def create_app():
  app = Flask(__name__)
  Session(app)

  from .controllers.auth import init_app as init_auth_routes
  init_auth_routes(app)

  from .controllers.transcription import init_app as init_trans_routes
  init_trans_routes(app, session)

  return app


def start_dev_server():
  app = create_app()
  app.run(port=3000)
