import os
import requests
from PIL import Image
import io

def download_image(image_url, save_path):
    
    if os.path.exists(save_path):
        os.remove(save_path)
    
    if image_url.startswith('http'):
        if 'drive.google.com' in image_url:
            file_id = image_url.split('/d/')[1].split('/view')[0]
            download_url = f'https://drive.google.com/uc?id={file_id}'
            response = requests.get(download_url)
        else:
            response = requests.get(image_url)
        
        image_data = io.BytesIO(response.content)
        img = Image.open(image_data)
    else:
        img = Image.open(image_url)

    img.save(save_path)
    return save_path

# Example usage
image_url = "https://content.iospress.com/media/ifs/2023/44-5/ifs-44-5-ifs222954/ifs-44-ifs222954-g004.jpg"
save_path = "saved_images/image.jpg"

# Create directory if not exists
os.makedirs(os.path.dirname(save_path), exist_ok=True)

download_path = download_image(image_url, save_path)
print(f"Image downloaded and saved at {download_path}")
