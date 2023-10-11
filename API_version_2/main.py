# import
import io
import os
from PIL import Image
from io import BytesIO
import requests
import numpy as np
from werkzeug.utils import secure_filename
from flask import Flask, request, jsonify ,send_file,render_template
from werkzeug.utils import secure_filename
from ultralytics import YOLO
import sqlite3
import firebase_admin
from firebase_admin import credentials, initialize_app, storage ,db
import json
import time

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

def save_to_json(data, filename):
    with open(filename, 'w') as f:
        json.dump(data, f)

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
    save_to_json(class_stats, 'static/class_summary.json')  # บันทึกเป็นไฟล์ JSON
    return class_stats

def get_speed_values(speed):
    preprocess_time = speed['preprocess']
    inference_time = speed['inference']
    postprocess_time = speed['postprocess']
    return preprocess_time, inference_time, postprocess_time



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
    return render_template('index.html')

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

INPUT_IMAGE_PATH = "static/input_image.jpg"
PREDICTED_IMAGE_PATH = "static/predicted_image.jpg"

@app.route('/path_to_input_image', methods=['GET'])
def get_input_image():
    try:
        if os.path.exists(INPUT_IMAGE_PATH):  # ถ้าภาพเดิมมีอยู่ลบทิ้ง
            os.remove(INPUT_IMAGE_PATH)
        
        blob = bucket.blob('input_images/image_to_predict.jpeg')
        img_data = blob.download_as_bytes()
        with open(INPUT_IMAGE_PATH, 'wb') as f:
            f.write(img_data)
        return send_file(INPUT_IMAGE_PATH, mimetype='image/jpeg')
    except Exception as e:
        return jsonify({"error": str(e)})

@app.route('/latest_predicted_image', methods=['GET'])
def get_latest_predicted_image():
    try:
        if os.path.exists(PREDICTED_IMAGE_PATH):  # ถ้าภาพเดิมมีอยู่ลบทิ้ง
            os.remove(PREDICTED_IMAGE_PATH)
        
        blob = bucket.blob('predicted_images/last_predict.jpeg')
        img_data = blob.download_as_bytes()
        with open(PREDICTED_IMAGE_PATH, 'wb') as f:
            f.write(img_data)
        return send_file(PREDICTED_IMAGE_PATH, mimetype='image/jpeg')
    except Exception as e:
        return jsonify({"error": str(e)})


@app.route('/download_stats', methods=['GET'])
def download_stats():
    try:
        with open('static/class_summary.json', 'r') as f:
            data = json.load(f)
        return jsonify(data)
    except Exception as e:
        return jsonify({"error": str(e)})


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
            speed = results[0].speed
            preprocess, inference, postprocess = get_speed_values(speed)
            # คำนวณเวลาที่ใช้ในการทำนาย
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
                "summary": summary ,
                "preprocess_time": round(preprocess, 2),
                "inference_time": round(inference, 2),
                "postprocess_time": round(postprocess, 2)
            })
        else:
            return jsonify({"error": "No file uploaded"})
    except Exception as e:
        return jsonify({"error": str(e)})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
