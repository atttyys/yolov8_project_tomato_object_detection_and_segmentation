# import
import io
import os
from PIL import Image
from io import BytesIO
import requests
import numpy as np
from werkzeug.utils import secure_filename
from flask import Flask, request, jsonify ,send_file
from werkzeug.utils import secure_filename
from ultralytics import YOLO
import sqlite3
import firebase_admin
from firebase_admin import credentials, initialize_app, storage ,db

#  config
cred = credentials.Certificate("fbad/flutter-api-images-firebase-adminsdk-v2nsd-30fb51350b.json")
firebase_admin.initialize_app(cred, {
    'databaseURL' : 'https://flutter-api-images-default-rtdb.asia-southeast1.firebasedatabase.app'
})
bucket = storage.bucket('flutter-api-images.appspot.com')
ref = db.reference('predicted_stats')
app = Flask(__name__)
model = YOLO('model/yolov8s-seg_tomatoes.pt')
names = {
    0: "b_fully_ripened",
    1: "b_green",
    2: "b_half_ripened",
    3: "l_fully_ripened",
    4: "l_green",
    5: "l_half_ripened"
}

#  SQLITE

def connect_db():
    return sqlite3.connect('images.db')

def save_image_to_db(image_data):
    conn = connect_db()
    c = conn.cursor()
    c.execute("INSERT INTO images (predicted_image_data) VALUES (?)", (image_data,))
    conn.commit()
    conn.close()


# tool func
def class_summary(results):
    cls = results[0].boxes.cls
    conf = results[0].boxes.conf
    class_stats = {}
    for unique_cls in cls.unique():
        indices = (cls == unique_cls).nonzero().squeeze()
        if indices.dim() == 0:  # Scalar tensor
            count = 1
            avg_conf = conf[indices].item()
        else:  # Tensor with dimensions
            count = indices.size(0)
            avg_conf = conf[indices].mean().item()
        class_stats[int(unique_cls.item())] = {'count': count, 'avg_confidence': avg_conf}
    return class_stats



def download_image(image_url, save_path):
    if os.path.exists(save_path):
        os.remove(save_path)
    response = requests.get(image_url)
    image_data = io.BytesIO(response.content)
    img = Image.open(image_data)
    img.save(save_path)
    return save_path


# GET
@app.route('/', methods=['GET'])
def index():
    return '''
    <form action="/upload_and_predict" method="post" enctype="multipart/form-data">
        <input type="file" name="file">
        <input type="submit" value="Upload and Predict">
    </form>
    <br>
    <a href="/latest_predicted_image" target="_blank"><button>Show Latest Predicted Image</button></a>
    <br>
    <button id="showStatsButton">Show Predicted Stats</button>
    <div id="statsView"></div>

    <script>
    document.getElementById("showStatsButton").addEventListener("click", function() {
        fetch("/get_predicted_stats")
            .then(response => response.json())
            .then(data => {
                let statsText = "";
                for (const [key, value] of Object.entries(data)) {
                    statsText += `${key}: ${JSON.stringify(value)}<br>`;
                }
                document.getElementById("statsView").innerHTML = statsText;
            })
            .catch(error => console.error(error));
    });
    </script>
    '''

@app.route('/predict_from_firebase', methods=['GET'])
def predict_from_firebase():
    try:
        blob = bucket.blob('input_images/image_to_predict.jpeg')
        img_data = blob.download_as_bytes()
        im = Image.open(BytesIO(img_data))
        results = model(im)
        r = results[0]
        im_array = r.plot()

        im_result = Image.fromarray(im_array[..., ::-1])
        buffered = BytesIO()
        im_result.save(buffered, format='JPEG')

        blob_result = bucket.blob('predicted_images/last_predict.jpeg')
        blob_result.upload_from_string(buffered.getvalue(), content_type='image/jpeg')

        return jsonify({"message": "Prediction made and image saved to Firebase."})
    except Exception as e:
        return jsonify({"error": str(e)})

@app.route('/latest_predicted_image', methods=['GET'])
def get_latest_predicted_image():
    try:
        blob = bucket.blob('predicted_images/last_predict.jpeg')
        img_data = blob.download_as_bytes()
        return send_file(BytesIO(img_data), attachment_filename='image.jpg', mimetype='image/jpeg')
    except Exception as e:
        return jsonify({"error": str(e)})


@app.route('/get_predicted_stats', methods=['GET'])
def get_predicted_stats():
    try:
        # Fetch the data
        stats = ref.get()
        if stats:
            return jsonify(stats)
        else:
            return jsonify({"message": "No stats available"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/upload_and_predict', methods=['POST'])
def upload_and_predict():
    try:

        file = request.files['file']
        if file:

            blob = bucket.blob('input_images/image_to_predict.jpeg')
            blob.upload_from_string(
                file.read(),
                content_type='image/jpeg'
            )

            img_data = blob.download_as_bytes()
            im = Image.open(BytesIO(img_data))
            results = model(im)
            summary = class_summary(results)
            r = results[0]
            im_array = r.plot()

            im_result = Image.fromarray(im_array[..., ::-1])
            buffered = BytesIO()
            im_result.save(buffered, format='JPEG')

            blob_result = bucket.blob('predicted_images/last_predict.jpeg')
            blob_result.upload_from_string(buffered.getvalue(), content_type='image/jpeg')
            return jsonify({
                "message": "Prediction made and image saved to Firebase.",
                "summary": summary
            })
        else:
            return jsonify({"error": "No file uploaded"})
    except Exception as e:
        return jsonify({"error": str(e)})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
