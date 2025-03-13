//
//  ParametersChartView.swift
//  SimpleLinearRegression
//
//  Created by Stas Kirichok on 3/5/25.
//

import Charts
import SwiftUI

struct ParametersChartView: View {
    let parametersHistory: [([Double], Double)]
    
    var body: some View {
        Chart {
            // Optionally, show the individual points as well.
            ForEach(Array(zip(parametersHistory.indices, parametersHistory)), id: \.0) { index, parameters in
                PointMark(
                    x: .value("W", parameters.0[0]),
                    y: .value("B", parameters.1)
                )
                .symbolSize(15)
                .symbol {
                    VStack {
                        Circle()
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
        .chartXAxisLabel("W")
        .chartYAxisLabel("B")
        .padding()
    }
}

#Preview {
    ParametersChartView(parametersHistory: [([1], 1), ([2], 4), ([3], 9)])
}
