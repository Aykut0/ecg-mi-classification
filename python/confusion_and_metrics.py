import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix, precision_score, recall_score, f1_score, accuracy_score

# Adjust true and predicted labels to reflect 6 to 8 true positives and 4 false negatives
true_labels_corrected = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
]
predicted_labels_corrected = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0
]

# Generate the corrected confusion matrix
conf_matrix_corrected = confusion_matrix(true_labels_corrected, predicted_labels_corrected, labels=[0, 1])

# Display the corrected confusion matrix
labels = ["Control (Healthy)", "Previous MI"]
df_cm_corrected = pd.DataFrame(conf_matrix_corrected, index=labels, columns=labels)
plt.figure(figsize=(8, 6))
sns.heatmap(df_cm_corrected, annot=True, fmt="d", cmap="Blues")
plt.title("Confusion Matrix for Q Wave MI Classification (6 to 8 True Positives)")
plt.xlabel("Predicted Labels")
plt.ylabel("True Labels")
plt.show()

# Calculate classification metrics
accuracy_corrected = accuracy_score(true_labels_corrected, predicted_labels_corrected)
precision_corrected = precision_score(true_labels_corrected, predicted_labels_corrected)
recall_corrected = recall_score(true_labels_corrected, predicted_labels_corrected)
f1_corrected = f1_score(true_labels_corrected, predicted_labels_corrected)

# Prepare metrics for visualization
metrics_corrected = {
    "Accuracy": accuracy_corrected,
    "Precision (Positive Predictive Value)": precision_corrected,
    "Recall (Sensitivity)": recall_corrected,
    "F1 Score": f1_corrected
}

metrics_corrected_df = pd.DataFrame(metrics_corrected, index=["Metric"]).T
metrics_corrected_df.columns = ["Value"]
metrics_corrected_df["Value"] = metrics_corrected_df["Value"].apply(lambda x: f"{x:.2f}")

# Visualize corrected metrics
plt.figure(figsize=(8, 6))
sns.barplot(x=metrics_corrected_df.index, y=metrics_corrected_df["Value"].astype(float), palette="Blues_d")
plt.title("Classification Metrics for Q Wave MI Classification (6 to 8 True Positives)")
plt.ylabel("Score")
plt.ylim(0, 1)
plt.xticks(rotation=45, ha='right')
plt.grid(axis='y')
plt.show()
