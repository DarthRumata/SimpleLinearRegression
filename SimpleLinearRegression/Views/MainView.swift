//
//  ContentView.swift
//  SimpleLinearRegression
//
//  Created by Stas Kirichok on 2/23/25.
//

import SwiftUI

struct MainView: View {
    @State var viewModel = MainViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            makeControlPanel()
            HStack {
                Text("Quality:")
                    .bold()
                Text("R2: \(viewModel.r2Score.toR2Percentage())")
            }
            
            HStack {
                if viewModel.selectedModel.regressionType == .logistic {
                    LogisticRegressionChartView(
                        x: viewModel.presentableData.x,
                        y: viewModel.presentableData.y,
                        model: viewModel.selectedModel,
                        weights: viewModel.w,
                        bias: viewModel.b
                    )
                } else {
                    PointsAndRegressionChartView(
                        x: viewModel.presentableData.x,
                        y: viewModel.presentableData.y,
                        model: viewModel.selectedModel,
                        weights: viewModel.w,
                        bias: viewModel.b
                    )
                }
                    
                ParametersChartView(parametersHistory: viewModel.paramsHistory)
            }
            .frame(height: 350)
                
            CostChartView(
                costs: viewModel.costHistory
            )
            .frame(height: 200)
            
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder func makeControlPanel() -> some View {
        let currentDatasetBinding = Binding<Dataset>(
            get: { viewModel.currentDataset },
            set: {
                let newIndex = viewModel.loadedDatasets.firstIndex(of: $0)
                viewModel.currentDatasetIndex = newIndex ?? 0
            }
        )
        DatasetPicker(
            isChangingModel: viewModel.isChangingModel,
            datasets: viewModel.loadedDatasets,
            currentDataset: currentDatasetBinding,
            viewModel: viewModel.makeDatasetPickerViewModel()
        )
        .disabled(viewModel.isTraining)
        
        makeModelView()
        
        makeHyperParametersView()
        
        makeModelParametersView()
        
        HStack {
            Button {
                viewModel.nextStepTapped()
            } label: {
                Text("Next step")
            }
            .disabled(viewModel.isTraining)
            
            Button {
                viewModel.resetTapped()
            } label: {
                Text("Reset")
            }
            
            Button {
                if viewModel.isTraining {
                    viewModel.stopTraining()
                } else {
                    viewModel.trainModel()
                }
            } label: {
                Text(viewModel.isTraining ? "Stop" : "Train")
            }
            
            Text("Step: \(viewModel.step)")
            
            Spacer()
            
            Toggle(isOn: $viewModel.useXNormalization) {
                Text("X norm ON?")
            }
            .disabled(viewModel.isTraining)
            Toggle(isOn: $viewModel.useYNormalization) {
                Text("Y norm ON?")
            }
            .disabled(viewModel.isTraining)
        }
    }
    
    @ViewBuilder private func makeModelView() -> some View {
        HStack {
            Picker("Model:", selection: $viewModel.selectedModel) {
                ForEach(RegressionModel.models) { model in
                    Text(model.name)
                        .tag(model)
                }
            }
            .pickerStyle(.menu)
            .fixedSize()
            .disabled(viewModel.isTraining)
            
            Text("Model function: \(viewModel.currentFormula)")
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
    }
    
    @ViewBuilder private func makeHyperParametersView() -> some View {
        let alphaText = Binding<String>(
            get: {
                String(viewModel.learningRate
                    .formatted(
                        .number.precision(
                            .integerAndFractionLength(integerLimits: 1...2, fractionLimits: 0...9)
                        )
                    )
                )
            },
            set: {
                viewModel.learningRate = Double($0) ?? 0
            }
        )
        
        let lambdaText = Binding<String>(
            get: { String(viewModel.lambda
                    .formatted(
                        .number.precision(
                            .integerAndFractionLength(integerLimits: 1...6, fractionLimits: 0...5)
                        )
                    )
            ) },
            set: {
                let parsableValue = $0.replacingOccurrences(of: ",", with: "")
                viewModel.lambda = Double(parsableValue) ?? 0
            }
        )
        
        let thresholdText = Binding<String>(
            get: { String(viewModel.precisionThreshold.formatted()) },
            set: { viewModel.precisionThreshold = Double($0) ?? 0 }
        )
        
        Form {
            Section(header:
                VStack(alignment: .leading) {
                    Text("Hyper parameters")
                }
            ) {
                HStack {
                    TextField(text: alphaText) {
                        Text("Learining rate")
                    }
                    .frame(width: 170)
                    TextField(text: lambdaText) {
                        Text("Regularization rate")
                    }
                    .frame(width: 170)
                    TextField(text: thresholdText) {
                        Text("Stop threshold (%)")
                    }
                    .frame(width: 170)
                }
            }
        }
    }
    
    @ViewBuilder private func makeModelParametersView() -> some View {
        // Number of weights per row; adjust to 4 or 5 as desired.
        let weightsPerRow = 10
        // Pair up each weight with its index.
        let weightPairs = Array(zip(viewModel.w.indices, viewModel.w))
        // Chunk the pairs into rows.
        let chunkedWeights = weightPairs.chunked(into: weightsPerRow)
            
        Grid(horizontalSpacing: 10, verticalSpacing: 10) {
            // Create a grid row for each chunk of weights.
            ForEach(chunkedWeights.indices, id: \.self) { rowIndex in
                GridRow {
                    ForEach(chunkedWeights[rowIndex], id: \.0) { i, wi in
                        VStack(alignment: .leading, spacing: 5) {
                            Text("w\(i + 1) =")
                            // Create a binding for each weight.
                            let wiText = Binding<String>(
                                get: { String(wi) },
                                set: { viewModel.w[i] = Double($0) ?? 0 }
                            )
                            TextField("w\(i + 1)", text: wiText)
                                .frame(width: 70)
                                .disabled(viewModel.isTraining)
                        }
                    }
                    
                    if rowIndex == chunkedWeights.indices.last! {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("b =")
                            let bText = Binding<String>(
                                get: { String(viewModel.b) },
                                set: { viewModel.b = Double($0) ?? 0 }
                            )
                            TextField("b", text: bText)
                                .frame(width: 70)
                                .disabled(viewModel.isTraining)
                        }
                    }
                }
            }
        }
    }
}

// Extension to chunk an array into subarrays of a given size.
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

/// Extension to convert R² to percentage string for display.
extension Double {
    func toR2Percentage() -> String {
        let percentage = self * 100
        return String(format: "%.2f%%", max(0, min(100, percentage))) // Clamp to 0-100%
    }
}

#Preview {
    MainView()
}
