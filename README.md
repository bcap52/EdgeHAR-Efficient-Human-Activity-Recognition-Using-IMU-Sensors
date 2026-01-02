# EdgeHAR-Efficient-Human-Activity-Recognition-Using-IMU-Sensors
This project addresses the challenge of deploying Human Activity Recognition (HAR) on edge devices with limited processing power. We processed 50Hz accelerometer data from a thigh-mounted IMU to classify distinct activities, including static postures (Sitting, Standing) and dynamic movements (Running, Cycling, Stairs).
# EdgeHAR: Efficient Human Activity Recognition Using IMU Sensors

### Project Overview
[cite_start]This project addresses the challenge of deploying Human Activity Recognition (HAR) on edge devices with limited processing power[cite: 10]. [cite_start]We processed 50Hz accelerometer data from a thigh-mounted IMU to classify distinct activities, including static postures (Sitting, Standing) and dynamic movements (Running, Cycling, Stairs)[cite: 9].

---

### Key Findings: The "Performance Inversion"
[cite_start]We discovered that a simple linear model outperformed a complex non-linear model on unseen data, proving that linear boundaries were more robust to subject-specific noise[cite: 82, 85].

| Model | Training Acc. | Test Acc. | Verdict |
| :--- | :--- | :--- | :--- |
| **Medium KNN** (Non-Linear) | **~92.6%** | ~91.2% | Signs of Overfitting |
| **Efficient Logistic Regression** | ~90.3% | **~93.2%** | **Selected (Better Generalization)** |

---

### Data Pipeline & Feature Engineering
**1. Preprocessing**
* [cite_start]**Cleaning:** Discarded the first **250 rows (5s)** of every session to remove sensor initialization artifacts[cite: 47].
* [cite_start]**Balancing:** Cap limit of **19,974 rows** per class to prevent bias toward dominant activities like Walking[cite: 49].

**2. Feature Extraction (12-Dim Vector)**
[cite_start]We applied a **2.5s sliding window** (125 samples) to extract time-domain features[cite: 55]:
* [cite_start]**Mean:** Captures static orientation (e.g., Thigh vertical vs. horizontal)[cite: 57].
* [cite_start]**Standard Deviation:** Captures movement intensity (e.g., Running vs. Standing)[cite: 58].

![Feature Scatter Plot](./path/to/your/scatterplot_image.png)
*Figure 1: Distinct clusters formed by Static (Low Variance) vs. Dynamic (High Variance) activities.*

---

### Performance Analysis
We prioritized Test Accuracy to measure real-world reliability.

**Strengths (High Reliability)**
* **Static Postures:** Near-perfect precision for **Sitting (99.9%)** and **Lying (100%)** due to distinct thigh angles.
* **Dynamic High-Intensity:** **Running (95.7%)** and **Active Cycling (97.6%)** were easily segmented by high variance.

**Limitations (Sensor Physics)**
* **Stairs (Classes 4 & 5):** High misclassification with **Walking** (<33% accuracy).
    * [cite_start]*Root Cause:* Without a **Barometer**, the acceleration profile of stairs is mathematically identical to walking[cite: 242, 243].
* **Shuffling (Class 3):** Confused with **Standing** (~18% error) due to subtle movement intensity.

![Test Confusion Matrix](./path/to/your/confusion_matrix_image.png)
*Figure 2: Test Confusion Matrix showing strong diagonal performance for distinct classes.*

---

### Usage
**Prerequisites:** MATLAB (R2021a+) with Statistics and Machine Learning Toolbox.

1. Clone the repository:
   ```bash
   git clone [https://github.com/YourUsername/EdgeHAR.git](https://github.com/YourUsername/EdgeHAR.git)
