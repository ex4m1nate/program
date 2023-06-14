def triangle(base, height):
    print(base * height / 2)

triangle(2, 3)

members = ["ozawa", "kitazawa", "tokoshima", "matsushita", "min"]
print(members[0])

members.append("saito")
result = len(members)
print(result)

members.remove("saito")
result = len(members)
print(result)

for a in members:
    print(a + "さん")

# coding: utf-8
from flask import Flask
# Webサーバインスタンスの生成
app = Flask(__name__) 
# http://localhost:5000/にリクエストが来たときの処理
@app.route("/")
def index():
    return "Hello Flask!"
if __name__ == "__main__":
    # webサーバーの立ち上げ
    app.run()