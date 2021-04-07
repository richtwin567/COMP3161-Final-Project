from flask.globals import request
from flask.json import JSONEncoder
from mysql.connector import connect
from . import app, conn, cur
from flask import jsonify, make_response
import json
from werkzeug.exceptions import HTTPException
from mysql.connector.errors import Error
from datetime import datetime, timedelta


class AggregatedDataEncoder(json.JSONEncoder):
    """
    To serialize datetime and timedelta objects which normally cannot be
    serialized by json.dumps
    """

    def default(self, o):
        if isinstance(o, str):
            return o
        if isinstance(o, timedelta) or isinstance(o, datetime):
            return str(o)

        return json.JSONEncoder.default(self, o)


@app.after_request
def add_response_headers(response=None):
    if not response:
        response = make_response()
    response.headers.add("Access-Control-Allow-Origin", "*")
    response.headers.add("Access-Control-Allow-Headers", "*")
    return response


@app.route("/recipes", methods=["POST"])
def get_recipes():
    times = request.get_json(force=True, silent=True)
    if times == None:
        times = 0
    else:
        times = times['loadMore']
    start = 0 + (20 * times)
    rows = 20
    cur.execute(f"SELECT * FROM recipe LIMIT {start},{rows};")
    res = cur.fetchall()
    res = json.dumps(res, cls=AggregatedDataEncoder)

    return jsonify(json.loads(res))

@app.route("/recipes-search", methods=["POST"])
def filter_recipes():
    global cur
    global conn
    times = request.get_json(force=True, silent=True)
    search_val = request.args.get('recipe_name', type=str)
    if times == None:
        times = 0
    else:
        times = times['loadMore']
    start = 0 + (20 * times)
    rows = 20
    cur.execute(f"SELECT * FROM recipe WHERE recipe_name LIKE '%{search_val}%' LIMIT {start},{rows};")
    res = cur.fetchall()
    

    res = json.dumps(res, cls=AggregatedDataEncoder)


    return jsonify(json.loads(res))


@app.route('/recipes/details/<id>', methods=["GET"])
def get_recipe_details(id):
    global cur
    global conn
    cur.execute(f"CALL get_recipe_detail({id});")
    res = cur.fetchone()

    # prevents commands out of sync error
    cur.close()
    conn = connect(**app.config.get("DB_CONN_INFO"))
    cur = conn.cursor(dictionary=True)

    # convert json strings to dicts before serializing the entire result
    for k in res:
        if type(res[k]) is str:
            try:
                res[k] = json.loads(res[k])
            except Exception:
                pass

    res = json.dumps(res, cls=AggregatedDataEncoder)
    return jsonify(json.loads(res))


@app.route('/allergies',methods=['GET'])
def get_allergies():
    cur.execute("SELECT * FROM allergy;")
    res = cur.fetchall()

    return jsonify(res)

@app.route('/shopping-list/<id>', methods=['GET'])
def get_shopping_list(id):
    global cur
    global conn
    cur.execute(f"CALL get_user_shopping_list({id});")

    res = cur.fetchall()

    # prevents commands out of sync error
    cur.close()
    conn = connect(**app.config.get("DB_CONN_INFO"))
    cur = conn.cursor(dictionary=True)

    return jsonify(res)


@app.route("/user/<id>", methods=["GET"])
def get_user(id):
    global cur
    global conn
    cur.execute(f"CALL get_one_user({id});")

    res = cur.fetchone()

    # prevents commands out of sync error
    cur.close()
    conn = connect(**app.config.get("DB_CONN_INFO"))
    cur = conn.cursor(dictionary=True)

    return jsonify(json.loads(json.dumps(res, default=str)))


@app.route("/login", methods=["POST"])
def login():
    pass


app.route("/signup", methods=["POST"])
def signup():
    pass


@app.route("/mealplan/<uid>", methods=["GET"])
def get_meal_plan(uid):
    pass


@app.route('/measurements', methods=["GET"])
def get_measurements():
    global cur
    global conn
    cur.execute('SELECT * FROM measurement;')
    res = cur.fetchall()

    # prevents commands out of sync error
    cur.close()
    conn = connect(**app.config.get("DB_CONN_INFO"))
    cur = conn.cursor(dictionary=True)

    return jsonify(res)

@app.route('/ingredients', methods=["GET"])
def get_ingredients():
    global cur
    global conn
    cur.execute('SELECT * FROM ingredient;')
    res = cur.fetchall()

    # prevents commands out of sync error
    cur.close()
    conn = connect(**app.config.get("DB_CONN_INFO"))
    cur = conn.cursor(dictionary=True)

    return jsonify(res)

@app.errorhandler(HTTPException)
def json_http_errors(err):
    """
    General error handler to ensure that the server always returns JSON
    """
    print(err)

    response = {
        "message": str(err),
    }
    response = jsonify(response)
    response.status_code = err.code
    return response


@app.errorhandler(Error)
def json_errors(err):
    print(err)
    response = {
        "message": str(err),
    }
    response = jsonify(response)
    response.status_code = 500
    return response
