# EdgeHAR: Efficient Human Activity Recognition Using IMU Sensors

### Project Overview
This project addresses the challenge of deploying Human Activity Recognition (HAR) on edge devices with limited processing power. We processed 50Hz accelerometer data from a thigh-mounted IMU to classify distinct activities, including static postures (Sitting, Standing) and dynamic movements (Running, Cycling, Stairs).

---

### Data Pipeline & Feature Engineering
**1. Preprocessing**
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


**2. Feature Extraction (12-Dim Vector)**
We applied a **2.5s sliding window** (125 samples) to extract time domain features:
* **Mean:** Captures static orientation (e.g., Thigh vertical vs. horizontal).
* **Standard Deviation:** Captures movement intensity (e.g., Running vs. Standing).

<h3>2. Feature Extraction (12-Dim Vector)</h3>
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
      <img src="https://raw.githubusercontent.com/bcap52/EdgeHAR-Efficient-Human-Activity-Recognition-Using-IMU-Sensors/main/ScatterPlot" width="100%" alt="Feature Scatter Plot">
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

#### Detailed Class Performance
By analyzing the Confusion Matrix (Picture Below), we observed the following performance characteristics:

**Strengths:**

The model demonstrated high reliability for distinct activities where signal patterns were unique.

* **Sitting (Class 7):** Achieved near-perfect precision due to the distinct static thigh orientation. (**100% Accuracy**)
* **Lying (Class 8):** Robustly identified due to the unique horizontal sensor axis. (**100% Accuracy**)
* **Cycling Sit (Class 13):** Accurately identified active cycling while seated. (**97.6% Accuracy**)
* **Running (Class 2):** The high standard deviation allowed for easy recognition of this high-intensity state. (**95.7% Accuracy**)
* **Standing (Class 6):** Showed strong stability with minimal confusion against other static classes. (**90.5% Accuracy**)
* **Cycling Stand (Class 14):** Successfully distinguished active standing cycling from standard standing. (**100% Accuracy**)
* **Walking (Class 1):** Effectively captured the standard gait pattern, though frequently confused with Shuffling. (**~97% Accuracy**)

**Weaknesses:**

Performance degraded significantly for ambiguous activities or those with insufficient test data. These are minor activities and rare for a person to do during a day so we can safely ignore and drop these classes, however i kept them for comprehensive analysis. This can be fixed with data from a barometer, altimeter and using sensor fusion which would result in more features which in turn would help us differentiate these weak classes from other classes hence achieving a higher accuracy score

* **Shuffling (Class 3):** Frequently misclassified as Standing because the movement intensity was too subtle. (**48% Accuracy**)
* **Cycling Inactive (Class 130):** Sample size was too low to determine reliability, with only 2 instances available in the test set. (**Insufficient Data**)
* **Stairs Ascending (Class 4):** Indistinguishable from Walking in the time domain without an altimeter. (**33.3% Accuracy**)
* **Stairs Descending (Class 5):** Misclassified as Walking due to nearly identical kinematic signatures. (**5.0% Accuracy**)
* 

<br>

<div align="center">
  <img src="https://raw.githubusercontent.com/bcap52/EdgeHAR-Efficient-Human-Activity-Recognition-Using-IMU-Sensors/17af5ce10973dfcdd6e08e7c0921760ea5429548/ConfusionMatrix" width="550">
  <br>
  <em>Figure 2: Test Confusion Matrix displaying strong diagonal density for Static/Dynamic classes.</em>
</div>
---

### Installation & Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/bcap52/EdgeHAR-Efficient-Human-Activity-Recognition-Using-IMU-Sensors.git
## 2. Prerequisites:

- MATLAB (R2021a or later recommended).
- Statistics and Machine Learning Toolbox.
- Link to the Datasets that we used for training: https://drive.google.com/drive/folders/1wDTIjdsdI3b8swcYLC1aKmRJAtfkY0Kp?usp=sharing
- Link to the dataset we tested our model on: https://drive.google.com/drive/folders/1vLwEsOHn6wwAkeF_4YtrTygb2JIC1NOA?usp=sharing 

## 3. Generate the Dataset:

- Open `IMU_model_19974.mlx` in MATLAB.
- **⚠️IMPORTANT⚠️**: Ensure the dataset CSV files for training are located inside a folder named `Data` inside the directory where `IMU_model_19974.mlx` the Matlab script is located , otherwise the script will fail
- Run the script to perform preprocessing and feature extraction.
- This will generate the final feature table named  `Dataset_50HZ_Limited_Train_19974_eachclass` in your MATLAB Workspace.

## 4. Train & Evaluate (Classification Learner App):

- Open the **Classification Learner App** from the MATLAB Apps tab.
- Click **New Session** and select the generated feature table from the Workspace.
- Choose **Logistic Regression** (or other models) to train.
- Use the App's interface to validate, test, and view the Confusion Matrix.

## 5. Scalability & Inference:

- The pipeline is architected to be modular. If new raw accelerometer data (50Hz) is collected from an edge device, it can be passed through this same feature engineering pipeline.
- The resulting feature vectors can then be immediately classified by the trained model (exported from the Learner App) to predict activities for new users.
  
