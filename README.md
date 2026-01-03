# EdgeHAR: Efficient Human Activity Recognition Using IMU Sensors

### Project Overview
This project addresses the challenge of deploying Human Activity Recognition (HAR) on edge devices with limited processing power. We processed 50Hz accelerometer data from 2 three-axial Axivity AX3 accelerometers to classify distinct activities, including static postures (Sitting, Standing) and dynamic movements (Running, Cycling, Stairs). We used the harth dataset for this project (https://github.com/ntnu-ai-lab/harth-ml-experiments/tree/main/harth)

---

# Prerequisites & Setup

To run this project, ensure you have the following installed:

* MATLAB (R2021a or later recommended)
* Statistics and Machine Learning Toolbox

# Getting Started

**Clone the repository:**
```bash
git clone https://github.com/bcap52/EdgeHAR-Efficient-Human-Activity-Recognition-Using-IMU-Sensors.git
```

# How to Run

You have two options for running this project.

## Option 1: Automated Pipeline (Fastest)

Use this option if you want to run the model immediately using the pre processed data and pre trained model included in this repository.

### 1. Download Testing Data:
* Download the Testing Datasets folder from this link: [Download Test Data](https://drive.google.com/drive/folders/1Z_0K0mR285lMQ2ECFdFmGVpV7OdgCjWs?usp=sharing)
* Place the `Testing Datasets` folder downloaded from the link in the root directory of this repository (same folder as `main_script.mlx`).

### 2. Verify Files:
* Ensure `src/`, `models/`, and `Data/ProcessedData.mat` are present in your directory (these are included in the repo).

### 3. Run the Script:
* Open `main_script.mlx` in MATLAB.
* Click **Run**.
* The script will instantly load the processed data and the trained model to display the results.

## Option 2: Process from Scratch (Raw Data)

Use this option if you want to regenerate the dataset features from the raw CSV files yourself (e.g., if you want to see the preprocessing happen in real time).

### 1. Delete Existing Data:
* Delete the file `Data/ProcessedData.mat` (if it exists).

### 2. Download All Datasets:
* **Training Data:** [Download Here](https://drive.google.com/drive/folders/1wDTIjdsdI3b8swcYLC1aKmRJAtfkY0Kp?usp=sharing)
* **Testing Data:** [Download Here](https://drive.google.com/drive/folders/1Z_0K0mR285lMQ2ECFdFmGVpV7OdgCjWs?usp=sharing)

### 3. Organize Folders:
* Create a folder named `Data` in the root directory and place all Training CSV files inside it.
* Place the `Testing Datasets` folder in the root directory with all Testing CSV files inside it.
* Ensure `src/`, `models/`, are present in your directory (these are included in the repo).

### 4. Run the Script:
* Open `main_script.mlx` and click **Run**.
* The script will detect that the processed data is missing and will automatically start reading the raw CSVs, windowing the data, and extracting features before training the model.

## Visualization & Retraining

This repository includes a saved session file for the Classification Learner App, allowing you to explore the data visually or train different models (SVM, KNN, Trees) without writing code.

1. Open the Classification Learner app in MATLAB.
2. In the "New Session" section, click the arrow and select **Open Session**.
3. Navigate to `src/Classification_LearnerApp_Workspace.mat` and open it.
4. You can now view detailed Confusion Matrices, ROC Curves, and Parallel Coordinate Plots, or train new models on the dataset.




# Project Explaination


### 1. Data Pipeline & Feature Engineering
**Preprocessing**
* **Cleaning:** Discarded the first **250 rows (5s)** of every session to remove sensor initialization artifacts.
* **Balancing:** Cap limit of **19,974 rows** per class to prevent bias toward dominant activities like Walking.


| Label | Activity | Notes |
| :--- | :--- | :--- |
| **1** | walking | |
| **2** | running | |
| **3** | shuffling | standing with leg movement |
| **4** | stairs (ascending) | |
| **5** | stairs (descending) | |
| **6** | standing | |
| **7** | sitting | |
| **8** | lying | |
| **13** | cycling (sit) | |
| **14** | cycling (stand) | |
| **130** | cycling (sit, inactive) | cycling (sit) without leg movement |


*What activity each class corresponds to*

---




<h3>2. Feature Extraction (12 Dimension Vector)</h3>
<p>
  We applied a <strong>2.5s sliding window</strong> (125 samples) to extract time-domain features:
  <ul>
    <li><strong>Mean:</strong> Captures static orientation (e.g., Thigh vertical vs. horizontal).</li>
    <li><strong>Standard Deviation:</strong> Captures movement intensity (e.g., Running vs. Standing).</li>
  </ul>
</p>

<table>
  <tr>
    <td width="65%">
      <img src="https://raw.githubusercontent.com/bcap52/EdgeHAR-Efficient-Human-Activity-Recognition-Using-IMU-Sensors/main/Visualizations/ScatterPlot" width="100%" alt="Feature Scatter Plot">
      <br>
      <em>Figure 1: Distinct clusters formed by Static (Low Variance) vs. Dynamic (High Variance) activities.</em>
    </td>
    <td width="35%" valign="top">
      <h3>Legend</h3>
      <img src="https://img.shields.io/badge/1%20Walking-0072BD?style=flat&labelColor=0072BD&logoWidth=0"> <br>
      <img src="https://img.shields.io/badge/2%20Running-D95319?style=flat&labelColor=D95319"> <br>
      <img src="https://img.shields.io/badge/3%20Shuffling-EDB120?style=flat&labelColor=EDB120"> <br>
      <img src="https://img.shields.io/badge/4%20Stairs%20(Up)-7E2F8E?style=flat&labelColor=7E2F8E"> <br>
      <img src="https://img.shields.io/badge/5%20Stairs%20(Down)-77AC30?style=flat&labelColor=77AC30"> <br>
      <img src="https://img.shields.io/badge/6%20Standing-4DBEEE?style=flat&labelColor=4DBEEE"> <br>
      <img src="https://img.shields.io/badge/7%20Sitting-A2142F?style=flat&labelColor=A2142F"> <br>
      <img src="https://img.shields.io/badge/8%20Lying-FFD700?style=flat&labelColor=FFD700"> <br>
      <img src="https://img.shields.io/badge/13%20Cycling%20(Sit)-4169E1?style=flat&labelColor=4169E1"> <br>
      <img src="https://img.shields.io/badge/14%20Cycling%20(Stand)-FF0000?style=flat&labelColor=FF0000"> <br>
      <img src="https://img.shields.io/badge/130%20Cycling%20(Inactive)-008080?style=flat&labelColor=008080">
    </td>
  </tr>
</table>

---

### 3. Performance Analysis

#### Overall Model Evaluation
We evaluated two different models to determine the best balance between complexity and reliability using Matlab's Classification Learner App. While the Non-Linear KNN model achieved higher accuracy during training, it showed signs of slight overfitting.

In contrast, the Efficient Logistic Regression model achieved higher accuracy on unseen data than on training data. This indicates that the linear decision boundaries were more robust and generalized better to new subjects for this data

| Model | Training Acc. | Test Acc. (Unseen Data) | Verdict |
| :--- | :--- | :--- | :--- |
| **Medium KNN** (Non-Linear) | ~92.6% | ~91.2% | Signs of Overfitting |
| **Logistic Regression** | ~90.3% | **~93.2%** | **Selected (Better Generalization)** |

---

## Detailed Class Performance
By analyzing the Confusion Matrix (Picture Below), we observed the following performance characteristics:

### Strengths

The model demonstrated high reliability for distinct activities where signal patterns were unique.

* **Sitting (Class 7):** Achieved near perfect precision due to the distinct static thigh orientation. (Accuracy: 99.9% | Precision: 100.0% | F1: 99.9%)
* **Lying (Class 8):** Robustly identified due to the unique horizontal sensor axis. (Accuracy: 100.0% | Precision: 99.4% | F1: 99.7%)
* **Cycling Sit (Class 13):** Accurately identified active cycling while seated. (Accuracy: 97.6% | Precision: 97.6% | F1: 97.6%)
* **Running (Class 2):** The high standard deviation allowed for easy recognition of this high intensity state. (Accuracy: 95.7% | Precision: 100.0% | F1: 97.8%)
* **Standing (Class 6):** Showed strong stability with minimal confusion against other static classes. (Accuracy: 90.5% | Precision: 93.9% | F1: 92.2%)
* **Cycling Stand (Class 14):** Successfully distinguished active standing cycling from standard standing. (Accuracy: 84.9% | Precision: 100.0% | F1: 91.8%)
* **Walking (Class 1):** Effectively captured the standard gait pattern, though frequently confused with Shuffling. (Accuracy: 70.5% | Precision: 96.9% | F1: 81.6%)

### Weaknesses

Performance degraded significantly for ambiguous activities or those with insufficient test data. These are minor activities and rare for a person to do during a day so we can safely ignore and drop these classes as they would be ignored in a deployment, however I kept them here for comprehensive analysis. This can be fixed with data from a barometer, altimeter and using sensor fusion which would result in more features which in turn would help us differentiate these weak classes from other classes hence achieving a higher accuracy score.

* **Shuffling (Class 3):** Frequently misclassified as Standing because the movement intensity was too subtle. (Accuracy: 81.8% | Precision: 47.1% | F1: 59.7%)
* **Cycling Inactive (Class 130):** Sample size was too low to determine reliability, with only 2 instances available in the test set. (Accuracy: 100.0% | Precision: 10.5% | F1: 19.0%)
* **Stairs Ascending (Class 4):** Indistinguishable from Walking in the time domain without an altimeter. (Accuracy: 33.3% | Precision: 4.5% | F1: 8.0%)
* **Stairs Descending (Class 5):** Misclassified as Walking due to nearly identical kinematic signatures. (Accuracy: 5.0% | Precision: 100.0% | F1: 9.5%)
<br>

<div align="center">
  <img src="https://raw.githubusercontent.com/bcap52/EdgeHAR-Efficient-Human-Activity-Recognition-Using-IMU-Sensors/17af5ce10973dfcdd6e08e7c0921760ea5429548/ConfusionMatrix" width="550">
  <br>
  <em>Figure 2: Test Confusion Matrix displaying strong diagonal density for Static/Dynamic classes.</em>
</div>

---



 ## Scalability & Inference

- The pipeline is architected to be modular. If new raw accelerometer data (50Hz) is collected from an edge device, it can be passed through this same feature engineering pipeline.
- The model immediately classifies new feature vectors and is architecturally optimized to be ported to edge devices with minimal adaptation.

  #### Generative AI was used as a minor helping tool under the [Generative AI guidelines](https://github.com/mathworks/MATLAB-Simulink-Challenge-Project-Hub/wiki/Generative-AI-Guidelines)
  
