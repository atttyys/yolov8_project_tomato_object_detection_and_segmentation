from ultralytics import YOLO

# Load model
model = YOLO('model\yolov8s-seg_tomatoes.pt')

# Run inference
results = model('test/image/456.jpg')
print(results[0].speed)
# Get results in JSON format
json_results = results[0].tojson()

# # Save the results to a text file
# with open("results.txt", "w") as file:
#     file.write(json_results)

# Get timing results
timing_results = results[0].speed

# Convert timing results to string format
timing_str = "\n".join([f"{key}: {value:.2f} ms" for key, value in timing_results.items()])

# Save the results and timing to a text file
with open("results.txt", "w") as file:
    file.write("Timing Results:\n")
    file.write(timing_str)
    # file.write("\n\nJSON Results:\n")
    # file.write(json_results)