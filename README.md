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





**2. Feature Extraction (12-Dim Vector)**
We applied a **2.5s sliding window** (125 samples) to extract time-domain features:
* **Mean:** Captures static orientation (e.g., Thigh vertical vs. horizontal).
* **Standard Deviation:** Captures movement intensity (e.g., Running vs. Standing).

![Feature Scatter Plot](https://github.com/bcap52/EdgeHAR-Efficient-Human-Activity-Recognition-Using-IMU-Sensors/blob/main/ScatterPlot)) 
*Figure 1: Distinct clusters formed by Static (Low Variance) vs. Dynamic (High Variance) activities.*

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

![Confusion Matrix](https://raw.githubusercontent.com/bcap52/EdgeHAR-Efficient-Human-Activity-Recognition-Using-IMU-Sensors/17af5ce10973dfcdd6e08e7c0921760ea5429548/ConfusionMatrix)
*Figure 2: Test Confusion Matrix showing strong diagonal performance for distinct classes.*

---

### Usage
**Prerequisites:** MATLAB (R2021a+) with Statistics and Machine Learning Toolbox.

1. Clone the repository:
   ```bash
   git clone [https://github.com/YourUsername/EdgeHAR.git](https://github.com/YourUsername/EdgeHAR.git)
