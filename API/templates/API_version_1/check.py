import torch

# Dummy data for cls and conf tensors (Replace these with your actual tensors)
cls = torch.tensor([3., 3., 3., 3., 3., 3., 3., 3., 3., 3., 3., 3., 3., 4., 3., 3., 3., 4.])
conf = torch.tensor([0.9400, 0.9395, 0.9329, 0.9311, 0.9308, 0.9297, 0.9241, 0.9216, 0.9210, 0.9192, 0.9091, 0.8894, 0.8887, 0.8862, 0.8627, 0.8413, 0.7277, 0.5113])

# Initialize dictionary to keep track of class statistics
class_stats = {}

# Loop over unique class labels in the cls tensor
for unique_cls in cls.unique():
    # Find the indices of this class label in cls tensor
    indices = (cls == unique_cls).nonzero().squeeze()

    # Count the number of occurrences and average confidence for this class
    count = indices.size(0)
    avg_conf = conf[indices].mean().item()

    # Store the statistics in the dictionary
    class_stats[int(unique_cls.item())] = {'count': count, 'avg_confidence': avg_conf}

# Names for each class label for better readability
names = {
    0: "b_fully_ripened",
    1: "b_green",
    2: "b_half_ripened",
    3: "l_fully_ripened",
    4: "l_green",
    5: "l_half_ripened"
}

# Print the statistics
for cls, stats in class_stats.items():
    print(f"Class: {names[cls]}, Count: {stats['count']}, Average Confidence: {stats['avg_confidence']:.4f}")
