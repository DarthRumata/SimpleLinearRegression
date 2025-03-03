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
    let model: (w: Double, b: Double)
    
    var body: some View {
        let x1: Double = dataPoints.min(by: { $0.x < $1.x })?.x ?? 0
        let x2: Double = dataPoints.max(by: { $0.x < $1.x })?.x ?? 0
        let firstPoint = DataPoint(x: x1, y: model.b + model.w * x1)
        let secondPoint = DataPoint(x: x2, y: model.b + model.w * x2)
        
        Chart {
            // Optionally, show the individual points as well.
            ForEach(dataPoints) { point in
                PointMark(
                    x: .value("X", point.x),
                    y: .value("Y", point.y)
                )
            }
            ForEach([firstPoint, secondPoint]) { point in
                LineMark(
                    x: .value("1", point.x),
                    y: .value("1", point.y)
                )
                .foregroundStyle(.red)
            }
            .interpolationMethod(.linear)
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
        model: (1, 2)
    )
}
