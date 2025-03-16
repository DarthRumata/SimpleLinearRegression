# SimpleLinearRegression: A SwiftUI macOS App for Linear & Logistic Regression 📊

![SwiftUI](https://img.shields.io/badge/SwiftUI-blue) ![macOS](https://img.shields.io/badge/macOS-14.0%2B-orange) ![License](https://img.shields.io/badge/license-MIT-green)

Welcome to **SimpleLinearRegression**, a macOS app built with Swift and SwiftUI that lets you explore linear and logistic regression with real-time visualizations! 
As an iOS developer, this was my first dive into machine learning, and I’m excited to share it with the community. 
Whether you’re learning ML basics or just curious about SwiftUI, this app offers an interactive way to train models, tweak parameters, and visualize results.

![Demo GIF](https://github.com/DarthRumata/SimpleLinearRegression/raw/main/screenshots/demo.gif)

---

## 🚀 Features

- **Multiple Regression Models**:
  - Linear regression with polynomial degrees (up to x⁶).
  - Logistic regression for binary classification.
- **Interactive UI**:
  - Select datasets and models via a clean SwiftUI interface.
  - Adjust hyperparameters like learning rate, regularization (L2), and stopping threshold.
  - Manually tweak weights and bias for fine-grained control.
- **Real-Time Visualizations**:
  - Scatter plots with regression lines (`PointsAndRegressionChartView` for linear, `LogisticRegressionChartView` for logistic).
  - Parameter history (`ParametersChartView`) and cost over time (`CostChartView`).
- **Data Handling**:
  - Import datasets via CSV (using `CSV.swift`).
  - Optional normalization for X and Y values.
- **Training & Evaluation**:
  - Gradient descent with early stopping based on cost convergence.
  - R² score to evaluate model quality (linear regression).
- **Testing**: Includes unit tests for core functionality (`SimpleLinearRegressionTests`).

---

## 📸 Screenshots

| Main View with Charts | Training in Progress | Dataset Selection |
|-----------------------|----------------------|-------------------|
| ![Main View](https://github.com/DarthRumata/SimpleLinearRegression/raw/main/screenshots/main_view.png) | ![Training](https://github.com/DarthRumata/SimpleLinearRegression/raw/main/screenshots/training.png) | ![Dataset Picker](https://github.com/DarthRumata/SimpleLinearRegression/raw/main/screenshots/dataset_picker.png) |

---

## 🛠 Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/DarthRumata/SimpleLinearRegression.git
   ```
2. **Open in Xcode**:
   - Open `SimpleLinearRegression.xcodeproj` in Xcode (version 15.0+ recommended).
   - Ensure you’re on macOS 14.0 or later.
3. **Install Dependencies**:
   - The project uses `CSV.swift` (v2.5.2) via Swift Package Manager. Xcode will automatically resolve this dependency when you build.
4. **Build & Run**:
   - Select a macOS target and hit `Cmd+R` to run the app.

---

## 📖 Usage

1. **Load a Dataset**:
   - The app includes sample datasets in the `sample_data/` folder (e.g., `linear_sample.csv` and `logistic_sample.csv`).
   - Use the `DatasetPicker` to load a CSV file, or add your own by placing a CSV file in the project directory and updating the dataset list.
   - CSV format: First column is the target (`y`), remaining columns are features (`x1`, `x2`, ...).

2. **Select a Model**:
   - Choose from linear regression (simple, parabolic, cubic, x⁶) or logistic regression using the model picker.

3. **Adjust Hyperparameters**:
   - Tweak the learning rate, regularization (lambda), and stopping threshold in the control panel.
   - Toggle X/Y normalization if needed.

4. **Train the Model**:
   - Click “Train” to start gradient descent. Watch the charts update in real-time as the model learns!
   - Use “Next Step” for manual stepping, or “Reset” to start over.

5. **Visualize Results**:
   - Check the R² score (linear models) to evaluate fit.
   - Explore the charts: data points with regression line, parameter history, and cost over iterations.

---

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 🙌 Acknowledgments

- Uses [CSV.swift](https://github.com/yaslab/CSV.swift) for CSV parsing.
- Inspired by my curiosity to combine iOS dev skills with machine learning.
