import torch
import os
from ultralytics import YOLO
from PIL import Image
import numpy as np
import matplotlib.pyplot as plt
import cv2

def model_inference(model, source):
    return model(source)

def show_images(results, original_path):
    original_image = cv2.imread(original_path)
    original_image = cv2.cvtColor(original_image, cv2.COLOR_BGR2RGB)
    fig, axes = plt.subplots(1, 2, figsize=(20, 10))
    axes[0].imshow(original_image)
    axes[0].set_title('Original Image')
    for r in results:
        im_array = r.plot()
        processed_image = Image.fromarray(im_array[..., ::-1])
        axes[1].imshow(processed_image)
        axes[1].set_title('Predicted Image')
    plt.show()

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

if __name__ == '__main__':
    model = YOLO('model\yolov8s-seg_tomatoes.pt')
    source = 'test\image\lu.png'
    results = model_inference(model, source)
    show_images(results, source)
    stats = class_summary(results)

    names = {
        0: "b_fully_ripened",
        1: "b_green",
        2: "b_half_ripened",
        3: "l_fully_ripened",
        4: "l_green",
        5: "l_half_ripened"
    }

    for cls, stat in stats.items():
        print(f"Class: {names[cls]}, Count: {stat['count']}, Average Confidence: {100*stat['avg_confidence']:.2f}")

    # Now, you can use 'stats' with your API.
