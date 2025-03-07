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
            makeControls()

            if !viewModel.isChangingModel {
                HStack {
                    PointsAndRegressionChartView(
                        dataPoints: viewModel.dataPoints,
                        model: viewModel.selectedModel,
                        weights: viewModel.w,
                        bias: viewModel.b
                    )
                    .frame(height: 400)
                    
                    ParametersChartView(parametersHistory: viewModel.paramsHistory)
                }
                
                
                CostChartView(
                    costs: viewModel.costHistory
                )
                .frame(height: 200)
            }
            
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder func makeControls() -> some View {
        let bText = Binding<String>(
            get: { String(viewModel.b) },
            set: { viewModel.b = Double($0) ?? 0 }
        )
        makeModelView()
        
        makeHyperParametersView()
        
        HStack(spacing: 5) {
            ForEach(Array(zip(viewModel.w.indices, viewModel.w)), id: \.0) { i, wi in
                let wiText = Binding<String>(
                    get: { String(wi) },
                    set: { viewModel.w[i] = Double($0) ?? 0 }
                )
                Text("W\(i) =")
                TextField(text: wiText) {
                    Text("W\(i)")
                }
                .frame(width: 70)
                .padding(.trailing, 15)
            }
            
            Text("B = ")
            TextField(text: bText) {
                Text("B")
            }
            .frame(width: 70)

            Spacer()
        }
        
        HStack {
            Button {
                viewModel.nextStepTapped()
            } label: {
                Text("Next step")
            }
            
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
            
            Toggle(isOn: $viewModel.useNormalization) {
                Text("Is normalization on?")
            }
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
            
            Text("Model function: \(viewModel.currentFormula)")
        }
    }
    
    @ViewBuilder private func makeHyperParametersView() -> some View {
        let alphaText = Binding<String>(
            get: { String(viewModel.learningRate.formatted()) },
            set: { viewModel.learningRate = Double($0) ?? 0 }
        )
        
        let lambdaText = Binding<String>(
            get: { String(viewModel.lambda.formatted()) },
            set: { viewModel.lambda = Double($0) ?? 0 }
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
                    .fixedSize()
                    TextField(text: lambdaText) {
                        Text("Regularization rate")
                    }
                    .fixedSize()
                    TextField(text: thresholdText) {
                        Text("Stop threshold (%)")
                    }
                    .fixedSize()
                }
            }
        }
    }
}

#Preview {
    MainView()
}
