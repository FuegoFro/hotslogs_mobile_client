from flask import Flask, Response
from werkzeug.exceptions import NotFound

from data_utils import json_top_builds_file

app = Flask(__name__)

@app.route("/")
def hello() -> str:
    return "Server is running!"

@app.route("/top_builds/<hero_name>")
def top_builds(hero_name: str) -> Response:
    path = json_top_builds_file(hero_name)
    if not path.exists():
        raise NotFound()
    return Response(path.read_text(), mimetype="application/json")
