from flask.globals import request
from flask.json import JSONEncoder
from . import app, conn, cur
from flask import jsonify, make_response
import json
from werkzeug.exceptions import HTTPException
from mysql.connector.errors import Error
from datetime import datetime, timedelta

class AggregatedDataEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, str):
            return o
        if isinstance(o, timedelta) or isinstance(o, datetime):
            return str(o)
        
        return json.JSONEncoder.default(self,o)

@app.route("/recipes", methods=["GET", "POST"])
def get_recipes():
    times = request.get_json(force=True,silent=True)
    if times==None:
        times=0
    start = 0 + (20* times)
    rows=20
    cur.execute(f"SELECT * FROM recipe LIMIT {start},{rows};")
    res = cur.fetchall();
    res = json.dumps(res, cls=AggregatedDataEncoder)

    return jsonify(json.loads(res))
    
@app.route('/recipes/<id>', methods=["GET"])
def get_recipe_details(id):
    cur.execute(f"CALL get_recipe_detail({id});")
    res = cur.fetchall();
    res = json.dumps(res, cls=AggregatedDataEncoder)
    return jsonify(json.loads(res))


@app.route("/user/<id>", methods=["GET"])
def get_user(id):
    cur.execute(f"CALL get_one_user({id});")
    
    res = cur.fetchone()


    return jsonify(json.loads(json.dumps(res,default=str)))


@app.route("/login", methods=["POST"])
def login():
    pass

app.route("/signup", methods=["POST"])
def signup():
    pass

@app.route("/shoppinglist/<uid>", methods=["GET"])
def get_shopping_list(uid):
    pass

@app.route("/mealplan/<uid>", methods=["GET"])
def get_meal_plan(uid):
    pass


@app.errorhandler(HTTPException)
def json_http_errors(err):
    """
    General error handler to ensure that the server always returns JSON
    """

    response = {
        "message": str(err.description),
    }
    response = jsonify(response)
    response.status_code = err.code
    return response

@app.errorhandler(Error)
def json_errors(err):

    response = {
        "message": str(err.description),
    }
    response = jsonify(response)
    response.status_code = err.code or 1
    return response
