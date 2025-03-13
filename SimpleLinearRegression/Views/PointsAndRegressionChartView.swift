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
    let x: [[Double]]
    let y: [Double]
    let model: RegressionModel
    let weights: [Double]
    let bias: Double
    
    @State private var currentFeatureIndex: Int = 0
    
    private var featureCount: Int { x[0].count }
    
    private var modelPoints: [DataPoint] {
        //print("x = \(x), y = \(y)")
        guard featureCount > currentFeatureIndex else { return [] }
        guard !x.isEmpty else { return [] }
        guard x.count == y.count else { return [] }
        
        guard weights.count == (try? model.weightsCount(featureCount: featureCount)) else { return [] }
        
        let currentFeatureX = x.map { $0[currentFeatureIndex] }
        let xMin: Double = currentFeatureX.min() ?? 0
        let xMax: Double = currentFeatureX.max() ?? 0
        
        var meanXj = Array(repeating: 0.0, count: featureCount)
        for i in 0..<x.count {
            for j in 0..<x[i].count {
                meanXj[j] += x[i][j]
            }
        }
        meanXj = meanXj.map { $0 / Double(x.count) }
        
        var modelPoints: [DataPoint] = []
        let step: Double = (xMax - xMin) / 10
        for x in stride(from: xMin, through: xMax, by: step) {
            meanXj[currentFeatureIndex] = x
            let point = DataPoint(x: x, y: (try? model.hypothesis(weights: weights, x: meanXj, bias: bias)) ?? 0)
            modelPoints.append(point)
        }
        return modelPoints
    }
    
    private var datasetPoints: [DataPoint] {
        guard featureCount > currentFeatureIndex else { return [] }
        return zip(x, y).map { .init(x: $0[currentFeatureIndex], y: $1) }
    }
    
    var body: some View {
        VStack {
            Chart {
                ForEach(datasetPoints) { point in
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
            .chartXAxisLabel("x\(currentFeatureIndex + 1)")
            .chartYAxisLabel("y")
            
            HStack {
                ForEach(0..<featureCount, id: \.self) { j in
                    let isSelectedBinding = Binding<Bool>(
                        get: { self.currentFeatureIndex == j },
                        set: { self.currentFeatureIndex = $0 ? j : self.currentFeatureIndex }
                    )
                    Toggle("x\(j + 1)", isOn: isSelectedBinding)
                }
            }
        }
        .padding()
        .onChange(of: x, initial: false) { _,_ in
            if currentFeatureIndex >= featureCount {
                currentFeatureIndex = 0
            }
        }
    }
}

#Preview {
    PointsAndRegressionChartView(
        x: [
            [1, 2],
            [2, 4],
            [3, 2],
            [4, 1]
        ],
        y: [1, 1.5, 0.7, 0.2],
        model: .parabolaLinear,
        weights: [1.0, 2, 2, 2, 2],
        bias: 1
    )
}
