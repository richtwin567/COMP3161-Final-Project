from . import app, conn, cur
from flask import jsonify
import json

@app.route("/recipes")
def get_all_recipes():
    cur.execute("SELECT * FROM all_recipes_agg;")
    res = cur.fetchall()

    return jsonify(json.loads(json.dumps(res,default=str)))


@app.route("/user/<:id>")
def get_user(id):
    cur.execute(f"CALL get_one_user({id});")
    res = cur.fetchAll()

    return jsonify(json.loads(json.dumps(res,default=str)))




