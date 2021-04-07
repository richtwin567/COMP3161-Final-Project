from functools import wraps
from flask.globals import request
from mysql.connector import connect
from . import app, conn, cur
from flask import jsonify, make_response, abort
import json
import jwt
from jwt.exceptions import ExpiredSignatureError, InvalidSignatureError
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


def token_required(func):
    """Decorator to verify the JWT."""
    @wraps(func)
    def decorator(*args, **kwargs):

        token = None

        # Retrieve the JWT from the request header
        if 'x-access-token' in request.headers:
            token = request.headers['x-access-token']

        # Returns that the token is missing
        if not token:
            return jsonify({'message': 'a valid token is missing'})

        try:
            # Decode the token to retrieve the user requesting the data
            data = jwt.decode(token, app.config.get(
                'SECRET_KEY'), algorithms="HS256")

            # Retrieve the user from the database
            cur.execute(f"CALL get_one_user({data.get('id')});")
            current_user = cur.fetchone()

        except InvalidSignatureError:
            abort(make_response({"message": 'Token is invalid'}, 401))

        except ExpiredSignatureError:
            abort(make_response({"message": 'Token is expired'}, 401))

        return func(current_user, *args, **kwargs)
    return decorator


@app.route("/login", methods=["POST"])
def login():
    """Route for handling user login.

    Args:
        None
    Returns:
        A JSON response with the JWT if the user is succesfully logged in
        and a 202 response code.
        If the user data is invalid or not found, a 401 response is
        returned
    """
    # Referencing global connection and cursor
    global cur
    global conn

    # Retrieve login details from request
    req = request.get_json(force=True)

    # Extract username and password from request
    username = req.get('username')
    password = req.get('password')

    print(username)
    print(password)
    # Check if the fields were successfully recieved, if not return a 401
    if username is None or password is None:
        return make_response(
            'Could not verify user',
            401,
            {'WWW-Authenticate': 'Basic realm ="Login details required"'})

    # Retrieve user credentials from database
    try:
        cur.execute(f"CALL get_user_by_login('{username}','{password}')")
        user_data = cur.fetchone()
    finally:
        cur.close()

        # Reconnecting cursor
        conn = connect(**app.config.get("DB_CONN_INFO"))
        cur = conn.cursor(dictionary=True)

    print(user_data)
    # Return a 401 if no user is found
    if user_data is None:
        return abort(make_response(
            {"message": 'Could not verify user'},
            401,
            {'WWW-Authenticate': 'Basic realm ="User does not exist"'}))
    else:
        expiry_time = app.config.get('JWT_ACCESS_LIFESPAN').get('hours')
        user = {
            'id': user_data.get('user_id'),
            'username': user_data.get('username'),
            'first_name': user_data.get('first_name'),
            'last_name': user_data.get('last_name'),
            'allergies': user_data.get('allergies'),
        }
        token = jwt.encode({
            'id': user_data.get('user_id'),
            'exp': datetime.utcnow() + timedelta(hours=expiry_time),

        }, app.config.get('SECRET_KEY'), algorithm='HS256')

        return make_response(jsonify(
            {'token': token, 'user': user}), 202)


@app.route("/signup", methods=["POST"])
def signup():
    """Route to retrieve details to sign a user up.

    Args:
        None
    Returns:
        response_code: 201 if the registration is succesful
                    401 if the user already exists
    """
    # Reference global variables
    global cur
    global conn

    # Retrieve signup details from form
    req = request.get_json(force=True)

    username = req.get('username')
    password = req.get('password')
    first_name = req.get('firstName')
    last_name = req.get('lastName')

    # Retrieve user credentials from database
    cur.execute(f"CALL get_user_by_login('{username}','{password}')")
    user_data = cur.fetchone()

    # Prevents commands out of sync error
    cur.close()
    conn = connect(**app.config.get("DB_CONN_INFO"))
    cur = conn.cursor(dictionary=True)

    # Insert if user data is none
    if user_data is None:
        print(req)
        print([username, password, first_name, last_name])
        try:
            cur.execute(
                f"CALL insert_user('{username}', '{first_name}', '{last_name}', '{password}', @user_id)")
        finally:
            conn.commit()

        conn = connect(**app.config.get("DB_CONN_INFO"))
        cur = conn.cursor(dictionary=True)
        return make_response('Successfully registered.', 201)
    else:
        return make_response('User already exists. Please Log in.', 202)


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

@app.route("/meal-plan")
def get_meal_plan():
    cur.execute(f"SELECT * FROM meal_plan m join planned_meal p on m.plan_id = p.plan_id join recipe r on r.recipe_id = p.recipe_id where m.for_user = 1;")
    res = cur.fetchall()
    res = json.dumps(res, cls=AggregatedDataEncoder)
    return jsonify(json.loads(res))

@app.route("/meal-plan/new/<uid>", methods=["POST"])
def add_meal_plan(uid):

    global conn
    global cur

    req = request.get_json(force=True, silent=True)
    mealPlan = req.get('mealPlan')
    try:
        cur.execute(f"DELETE p FROM planned_meal p JOIN meal_plan m ON p.plan_id = m.plan_id where m.for_user = {uid};")
    finally:
        conn.commit() 

    conn = connect(**app.config.get("DB_CONN_INFO"))
    cur = conn.cursor(dictionary=True)
    for i in mealPlan:
        tod = i['time_of_day']
        serving_size = i['serving_size']
        rid = i['recipe_id']
        try:
            cur.execute(f"INSERT INTO planned_meal (time_of_day, serving_size, recipe_id, plan_id) values('{tod}', {serving_size}, {rid}, {uid});")
        finally:
            conn.commit() 

        conn = connect(**app.config.get("DB_CONN_INFO"))
        cur = conn.cursor(dictionary=True)
    
    return jsonify(1)

@app.route("/get-recipes")
def get_recipes_by_user():
    cur.execute(f"SELECT * FROM recipe where created_by = 1;")
    res = cur.fetchall()
    res = json.dumps(res, cls=AggregatedDataEncoder)
    return jsonify(json.loads(res))

@app.route("/ingredients-filter/<rid>")
def get_ingredients_per_recipe(rid):
    recipe_id = int(rid)
    cur.execute(f"SELECT * FROM ingredient_measurement_joined where recipe_id = {recipe_id}")
    res = cur.fetchall()
    res = json.dumps(res)
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
    cur.execute(
        f"SELECT * FROM recipe WHERE recipe_name LIKE '%{search_val}%' LIMIT {start},{rows};")
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


@app.route('/allergies', methods=['GET'])
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


@app.route('/new-recipe', methods=["POST"])
def add_recipe():
    req = request.get_json(force=True)

    print(req)
    cur.execute(
        f"""CALL insert_recipe('{req['recipeName']}', '{req['recipeImg']}', '{req['recipePrepTime']}', '{req['recipeCookTime']}','{datetime.now().date()}','{req['recipeCulture']}','{req['recipeDescription']}', 1, @rid);""")
    conn.commit()
    cur.execute("SELECT @rid;")
    res = cur.fetchone()
    print(res)

    new_id = res['@rid']
    instructions = req['recipeInstructions']
    for i in range(1,len(instructions)+1):
        cur.execute(f"INSERT INTO instruction (step_number, instruction_details, recipe_id) VALUES ({i}, '{instructions[i-1]}', {new_id});")

    ings = req["recipeIngredients"]
    for ing in ings:
        cur.execute(f"INSERT INTO recipe_ingredient_measurement(recipe_id, ingredient_id, measurement_id, amount) VALUES ({new_id}, {ing['ingredient_id']}, {ing['measurement_id']}, {ing['amount']});")

    conn.commit()

    path={"path": f"/app/recipes/details/{new_id}"}

    return jsonify(path)

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
