from flask import Flask, session

def init_app(app, session):
  app = app # type: Flask
  session = session # type: session