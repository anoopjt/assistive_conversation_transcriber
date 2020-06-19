from flask import Flask, request, send_from_directory

def init_app(app: Flask):
  @app.route("/")
  def index():
    return app.send_static_file("index.html")
