import os
from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def home():
    return """
    <html>
      <head><title>DevOps Demo</title></head>
      <body>
        <h1>My DevOps Demo Application</h1>
        <p>Application is running successfully!</p>
        <p>Built with Flask, Docker and Kubernetes.</p>
        <a href="/health">Check application health</a>
      </body>
    </html>
    """


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "application": "terraform-demo"
    }), 200


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=int(os.environ.get("PORT", 5000)),
        debug=False
    )