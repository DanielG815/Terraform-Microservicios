from flask import Flask, jsonify
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def clima():
    return jsonify({
        "fecha": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "ciudad": "Lima",
        "clima": "Soleado"
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
