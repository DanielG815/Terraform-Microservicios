from flask import Flask, jsonify
from datetime import datetime
import requests

app = Flask(__name__)

@app.route('/')
def comportamiento():
    clima = requests.get("http://clima:5000/").json()
    temblor = requests.get("http://temblor:5000/").json()

    return jsonify({
        "fecha": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "ciudad": "Lima",
        "comportamiento": f"Clima: {clima['clima']}, Riesgo Temblor: {temblor['proyeccion_temblor']}"
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
