//
//  ContentView.swift
//  SimpleLinearRegression
//
//  Created by Stas Kirichok on 2/23/25.
//

import SwiftUI

struct MainView: View {
    @State var model = MainViewModel()

    var body: some View {
        VStack {
            makeControls()

            PointsAndRegressionChartView(
                dataPoints: model.dataPoints,
                model: (w: model.w, b: model.b)
            )
            
            CostChartView(
                costs: model.costHistory,
                currentStep: model.step
            )
        }
        .padding()
    }
    
    @ViewBuilder func makeControls() -> some View {
        let wText = Binding<String>(
            get: { String(model.w) },
            set: { model.w = Double($0) ?? 0 }
        )
        let bText = Binding<String>(
            get: { String(model.b) },
            set: { model.b = min(max(Double($0) ?? 0, 0), 100) }
        )
        let lText = Binding<String>(
            get: { String(model.learningRate.formatted()) },
            set: { model.learningRate = Double($0) ?? 0 }
        )
        Text("Model: \(model.w.formatted())*x + \(model.b.formatted())")
        
        HStack {
            Text("Learning rate: ")
            TextField(text: lText) {
                Text("Learining rate")
            }
            .frame(width: 100)
        }
        
        HStack(spacing: 5) {
            Text("W =")
            TextField(text: wText) {
                Text("W")
            }
            .frame(width: 70)
            .padding(.trailing, 15)

            Text("B = ")
            TextField(text: bText) {
                Text("B")
            }
            .frame(width: 70)

            Spacer()
        }
        
        HStack {
            Text("Step: \(model.step)")
            Button {
                model.nextStepTapped()
            } label: {
                Text("Next step")
            }
            Button {
                model.resetTapped()
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
