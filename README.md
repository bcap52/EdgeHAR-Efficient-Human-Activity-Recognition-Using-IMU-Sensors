# EdgeHAR: Efficient Human Activity Recognition Using IMU Sensors

### Project Overview
This project addresses the challenge of deploying Human Activity Recognition (HAR) on edge devices with limited processing power. We processed 50Hz accelerometer data from a thigh-mounted IMU to classify distinct activities, including static postures (Sitting, Standing) and dynamic movements (Running, Cycling, Stairs).

---

### Key Findings: The "Performance Inversion"
We discovered that a simple linear model outperformed a complex non-linear model on unseen data, proving that linear boundaries were more robust to subject-specific noise.

| Model | Training Acc. | Test Acc. | Verdict |
| :--- | :--- | :--- | :--- |
| **Medium KNN** (Non-Linear) | **~92.6%** | ~91.2% | Signs of Overfitting |
| **Efficient Logistic Regression** | ~90.3% | **~93.2%** | **Selected (Better Generalization)** |

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
We applied a **2.5s sliding window** (125 samples) to extract time-domain features:
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

### Performance Analysis
We prioritized Test Accuracy to measure real-world reliability.

**Strengths (High Reliability)**
* **Static Postures:** Near-perfect precision for **Sitting (99.9%)** and **Lying (100%)** due to distinct thigh angles.
* **Dynamic High-Intensity:** **Running (95.7%)** and **Active Cycling (97.6%)** were easily segmented by high variance.

**Limitations (Sensor Physics)**
* **Stairs (Classes 4 & 5):** High misclassification with **Walking** (<33% accuracy).
    * *Root Cause:* Without a **Barometer**, the acceleration profile of stairs is mathematically identical to walking.
* **Shuffling (Class 3):** Confused with **Standing** (~18% error) due to subtle movement intensity.

<img src="https://raw.githubusercontent.com/bcap52/EdgeHAR-Efficient-Human-Activity-Recognition-Using-IMU-Sensors/17af5ce10973dfcdd6e08e7c0921760ea5429548/ConfusionMatrix" width="500">

*Figure 2: Test Confusion Matrix showing strong diagonal performance for distinct classes*

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
  
