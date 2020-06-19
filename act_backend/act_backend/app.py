from flask import Flask, session
from flask_session import Session
from flask_socketio import SocketIO
import os

import act_backend.db

dev_port = (os.environ.get('DEV_PORT', None)) or 3000
if isinstance(dev_port, str):
  dev_port = int(dev_port)

app = Flask(__name__, static_url_path='', static_folder='static')
Session(app)
socketio = SocketIO(app)

from .controllers.web import init_app as init_app_routes
init_app_routes(app)

from .controllers.auth import init_app as init_auth_routes
init_auth_routes(app)

from .controllers.transcription import init_app as init_trans_routes
init_trans_routes(app, session, socketio)

def start_dev_server():
  socketio.run(app, port=dev_port, host="0.0.0.0", debug=True)
