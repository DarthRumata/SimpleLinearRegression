//
//  DataScaler.swift
//  SimpleLinearRegression
//
//  Created by Stas Kirichok on 3/6/25.
//

import Foundation

final class DataScaler {
    private(set) var mean: Double = 0
    private(set) var standardDeviation: Double = 0
    
    func zScoreNormalization(_ array: [Double]) -> [Double] {
        calculateStandardDeviationAndMean(array)
        return array.map { ($0 - mean) / standardDeviation }
    }

    private func calculateStandardDeviationAndMean(_ array: [Double]) {
        let sum = array.reduce(0, +)
        mean = sum / Double(array.count)
        let squaredDifferences = array.map { pow($0 - mean, 2) }
        let variance = squaredDifferences.reduce(0, +) / Double(array.count)
        standardDeviation = sqrt(variance)
    }
}
