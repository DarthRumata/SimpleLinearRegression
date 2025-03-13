//
//  LogisticRegressionChartView.swift
//  SimpleLinearRegression
//
//  Created by Stas Kirichok on 3/12/25.
//

import SwiftUI
import Charts

struct LogisticPoint: Identifiable {
    let id = UUID()
    let x: Double
    let y: Double
    let isPositive: Bool
}

struct LogisticRegressionChartView: View {
    let x: [[Double]]
    let y: [Double]
    let model: RegressionModel
    let weights: [Double]
    let bias: Double
    
    private var featureCount: Int { x[0].count }
    
    private var modelPoints: [DataPoint] {
        guard !x.isEmpty, x[0].count > 1, weights.count > 1 else { return [] }
        let x1 = x.transpose()[0]
        let minX1 = x1.min() ?? 0
        let maxX1 = x1.max() ?? 0
        
        return [
            .init(x: minX1, y: x2(x1: minX1)),
            .init(x: maxX1, y: x2(x1: maxX1)),
        ]
    }
    
    private var datasetPoints: [LogisticPoint] {
        guard !x.isEmpty, x[0].count > 1 else { return [] }
        return zip(x, y).map { .init(x: $0[0], y: $0[1], isPositive: $1 == 1) }
    }
    
    private func x2(x1: Double) -> Double {
        (-bias - weights[0] * x1) / weights[1]
    }
    
    var body: some View {
        VStack {
            Chart {
                ForEach(datasetPoints) { point in
                    PointMark(
                        x: .value("X", point.x),
                        y: .value("Y", point.y)
                    )
                    .foregroundStyle(point.isPositive ? .green : .red)
                    .symbolSize(16)
                }
                ForEach(modelPoints) { point in
                    LineMark(
                        x: .value("1", point.x),
                        y: .value("1", point.y)
                    )
                    .foregroundStyle(.blue)
                }
                .interpolationMethod(model.polynomialDegree == 1 ? .linear : .cardinal)
            }
            .chartXAxisLabel("x1")
            .chartYAxisLabel("x2")
        }
        .padding()
    }
}

#Preview {
    LogisticRegressionChartView(
        x: [
            [1, 2],
            [2, 4],
            [3, 2],
            [4, 1]
        ],
        y: [1, 1, 0, 0],
        model: .logisticRegression,
        weights: [-1.0, 0.5, 2, 2, 2],
        bias: 1
    )
}
