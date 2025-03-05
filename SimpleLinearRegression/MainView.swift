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
        VStack {
            makeControls()

            PointsAndRegressionChartView(
                dataPoints: viewModel.dataPoints,
                model: viewModel.selectedModel,
                weights: viewModel.w,
                bias: viewModel.b
            )
            
            CostChartView(
                costs: viewModel.costHistory,
                currentStep: viewModel.step
            )
        }
        .padding()
    }
    
    @ViewBuilder func makeControls() -> some View {
        let bText = Binding<String>(
            get: { String(viewModel.b) },
            set: { viewModel.b = min(max(Double($0) ?? 0, 0), 100) }
        )
        let lText = Binding<String>(
            get: { String(viewModel.learningRate.formatted()) },
            set: { viewModel.learningRate = Double($0) ?? 0 }
        )
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
        
        HStack {
            Text("Learning rate: ")
            TextField(text: lText) {
                Text("Learining rate")
            }
            .frame(width: 100)
        }
        
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
            Text("Step: \(viewModel.step)")
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
            Spacer()
        }
        
    }
}

#Preview {
    MainView()
}
