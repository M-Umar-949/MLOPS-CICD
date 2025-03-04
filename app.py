from flask import Flask, request, render_template
import pickle
import numpy as np

app = Flask(__name__,template_folder='templates')  # Initialize the Flask app


# Load the trained model
with open("iris_model.pkl", "rb") as file:
    model = pickle.load(file)

# Map numeric predictions to flower names
flower_labels = {0: "Setosa", 1: "Versicolor", 2: "Virginica"}


@app.route("/")
def home():
    return render_template("index.html")  # Render frontend


@app.route("/predict", methods=["POST"])
def predict():
    try:
        # Get form data from frontend
        sepal_length = float(request.form["sepal_length"])
        sepal_width = float(request.form["sepal_width"])
        petal_length = float(request.form["petal_length"])
        petal_width = float(request.form["petal_width"])

        # Convert input to numpy array
        features = np.array([[sepal_length, sepal_width, petal_length, petal_width]])

        # Predict flower class
        prediction = model.predict(features)[0]
        flower_name = flower_labels[int(prediction)]  # Convert numeric label to name

        return render_template(
            "index.html", prediction=flower_name
        )  # Show result in UI
    except Exception as e:
        return render_template("index.html", error=str(e))  # Display error in UI


# if __name__ == "__main__":  # Note: Fixed from **name** to __name__
app.run(debug=True, host="0.0.0.0", port=8000)
