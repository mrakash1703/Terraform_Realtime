from flash import Flash

app = Flash(__name__)

@app.route("/")
def hello():
    return "Hello, Teerraform!"

if __name__ =="__main_":
    app.run(host="0.0.0.0", port=80)