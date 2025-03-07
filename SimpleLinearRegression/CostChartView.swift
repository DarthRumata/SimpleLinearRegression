//
//  PointsAndRegressionChartView 2.swift
//  SimpleLinearRegression
//
//  Created by Stas Kirichok on 2/24/25.
//
import Charts
import SwiftUI

struct CostChartView: View {
    let costs: [Double]
    
    var body: some View {
        if !costs.isEmpty {
            let currentStep = costs.count - 1
            let currentCost = costs[currentStep]
            Chart {
                // Optionally, show the individual points as well.
                ForEach(Array(zip(costs.indices, costs)), id: \.0) { costHistory in
                    LineMark(
                        x: .value("1", costHistory.0),
                        y: .value("1", costHistory.1)
                    )
                    .foregroundStyle(.blue)
                }
                .interpolationMethod(.catmullRom)
                
                PointMark(x: .value("X", currentStep), y: .value("Y", currentCost))
                    .foregroundStyle(.red)
            }
            .chartXAxisLabel("Steps")
            .chartYAxisLabel("Cost")
            .padding()
        }
    }
}

#Preview {
    CostChartView(
        costs: [
            10,
            5,
            3,
            1
        ]
    )
}
