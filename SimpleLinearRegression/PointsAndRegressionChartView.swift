//
//  ChartView.swift
//  SimpleLinearRegression
//
//  Created by Stas Kirichok on 2/23/25.
//
import SwiftUI
import Charts

struct DataPoint: Identifiable {
    let id = UUID()
    let x: Double
    let y: Double
}

struct PointsAndRegressionChartView: View {
    let dataPoints: [DataPoint]
    let model: RegressionModel
    let weights: [Double]
    let bias: Double
    
    var modelPoints: [DataPoint] {
        let x1: Double = dataPoints.min(by: { $0.x < $1.x })?.x ?? 0
        let x2: Double = dataPoints.max(by: { $0.x < $1.x })?.x ?? 0
        
        var modelPoints: [DataPoint] = []
        let step: Double = (x2 - x1) / 10
        for x in stride(from: x1, through: x2, by: step) {
            let point = DataPoint(x: x, y: model.hypothesis(weights: weights, x: [x], bias: bias))
            modelPoints.append(point)
        }
        return modelPoints
    }
    
    var body: some View {
        Chart {
            // Optionally, show the individual points as well.
            ForEach(dataPoints) { point in
                PointMark(
                    x: .value("X", point.x),
                    y: .value("Y", point.y)
                )
                .symbolSize(16)
            }
            ForEach(modelPoints) { point in
                LineMark(
                    x: .value("1", point.x),
                    y: .value("1", point.y)
                )
                .foregroundStyle(.red)
            }
            .interpolationMethod(model.polynomialDegree == 1 ? .linear : .cardinal)
        }
        .chartXAxisLabel("Fish length (cm)")
        .chartYAxisLabel("Fish weight (g)")
        .padding()
    }
}

#Preview {
    PointsAndRegressionChartView(
        dataPoints: [
            DataPoint(x: 1, y: 1),
            DataPoint(x: 2, y: 1.5),
            DataPoint(x: 1, y: 0.7),
            DataPoint(x: 0, y: 0.2)
        ],
        model: .parabolaLinear,
        weights: [1.0, 2],
        bias: 1
    )
}
