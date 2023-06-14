# coding: utf-8
from flask import Flask, render_template, request
# Webサーバインスタンスの生成
app = Flask(__name__, static_folder="images") 
# http://localhost:5000/にリクエストが来たときの処理
@app.route("/")
def index():
    return "Hello Flask!"

@app.route("/top")
def top():
    return render_template("top.html")

@app.route("/top_failed")
def topf():
    return render_template("top_failed.html")

@app.route("/login")
def login():
    id = request.args.get("id")
    password = request.args.get("password")
    if id == "123046" and password == "So123046":
        return render_template("hogehoge.html", id = id)
    else:
        return render_template("top_failed.html")

if __name__ == "__main__":
    # webサーバーの立ち上げ
    app.run(host="0.0.0.0", port=80)