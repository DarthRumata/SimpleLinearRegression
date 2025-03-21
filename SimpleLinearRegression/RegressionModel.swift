//
//  RegressionModel.swift
//  SimpleLinearRegression
//
//  Created by Stas Kirichok on 3/2/25.
//

import Foundation

/// Errors that can occur during R² calculation.
enum CalculationError: Error {
    case emptyInput
    case mismatchedArrays
    case zeroVariance
}

enum RegressionType {
    case linear
    case logistic
    
    func calculateGradient(x: [[Double]], y: [Double], weights: [Double], polynomialDegree: Int, bias: Double) throws -> (weightsGradient: [Double], biasGradient: Double) {
        let m = y.count
        let n = x[0].count
        let terms = try polynomialTerms(featureCount: n, maxDegree: polynomialDegree)
        
        var weightsGradient = Array(repeating: 0.0, count: weights.count)
        var biasGradient = 0.0
        
        for i in 0 ..< m {
            let xi = x[i]
            let prediction = try hypothesis(weights: weights, x: xi, terms: terms, bias: bias)
            let error = prediction - y[i]
                
            // Gradient for each weight
            for (termIndex, exponents) in terms.enumerated() {
                var termValue = 1.0
                for (j, exponent) in exponents.enumerated() {
                    if exponent > 0 {
                        termValue *= pow(xi[j], Double(exponent))
                    }
                }
                weightsGradient[termIndex] += error * termValue
            }
            
            biasGradient += error
        }
        
        return (weightsGradient.map { $0 / Double(m) }, biasGradient / Double(m))
    }
    
    func calculateCost(x: [[Double]], y: [Double], weights: [Double], polynomialDegree: Int, bias: Double) throws -> Double {
        var totalCost: Double = 0
        let terms = try polynomialTerms(featureCount: x[0].count, maxDegree: polynomialDegree)
        let m = y.count
        
        for i in 0 ..< m {
            let prediction = try hypothesis(weights: weights, x: x[i], terms: terms, bias: bias)
            
            let loss: Double
            switch self {
            case .linear:
                loss = pow(y[i] - prediction, 2)
            case .logistic:
                let epsilon = 1e-15
                let clippedPrediction = min(max(prediction, epsilon), 1.0 - epsilon)
                loss = -(y[i] * log(clippedPrediction) + (1 - y[i]) * log(1 - clippedPrediction))
            }
            
            totalCost += loss
        }
            
        totalCost = totalCost / Double(m) / (self == .linear ? 2.0 : 1.0)
       
        return totalCost
    }
    
    func hypothesis(weights: [Double], x: [Double], terms: [[Int]], bias: Double) throws -> Double {
        var result: Double = 0
        
        guard weights.count == terms.count else {
            print("Weights count (\(weights.count)) must match the number of engineered features (\(terms.count)")
            throw CalculationError.mismatchedArrays
        }
        
        for (j, exponents) in terms.enumerated() {
            var term = weights[j]
            for (featureIndex, exponent) in exponents.enumerated() {
                if exponent > 0 {
                    term *= pow(x[featureIndex], Double(exponent))
                }
            }
            result += term
        }
        result += bias
        
        switch self {
        case .linear:
            return result
        case .logistic:
            return sigmoid(result)
        }
    }
    
    private func sigmoid(_ x: Double) -> Double {
        if x >= 0 {
            let expNegX = exp(-x)
            return 1.0 / (1.0 + expNegX)
        } else {
            let expX = exp(x)
            return expX / (1.0 + expX)
        }
    }
    
    func polynomialTerms(featureCount: Int, maxDegree: Int) throws -> [[Int]] {
        guard featureCount > 0, maxDegree > 0 else {
            throw CalculationError.emptyInput
        }
        
        var terms: [[Int]] = []
        
        func generate(current: [Int], position: Int, remainingDegree: Int) {
            if position == featureCount {
                // Only include terms with total degree > 0 and <= maxDegree
                let totalDegree = current.reduce(0, +)
                if totalDegree > 0, totalDegree <= maxDegree {
                    terms.append(current)
                }
                return
            }
            
            // Try all possible degrees for this feature
            for degree in 0 ... remainingDegree {
                let newTerm = current + [degree]
                generate(current: newTerm, position: position + 1, remainingDegree: remainingDegree - degree)
            }
        }
        
        // Start generation with full degree available
        generate(current: [], position: 0, remainingDegree: maxDegree)
        
        return terms
    }
}

struct RegressionModel: Identifiable, Hashable {
    let id = UUID().uuidString
    let name: String
    let regressionType: RegressionType
    let polynomialDegree: Int
    
    static let simpleLinear = RegressionModel(
        name: "Simple Linear Regression",
        regressionType: .linear,
        polynomialDegree: 1
    )
    
    static let parabolaLinear = RegressionModel(
        name: "Parabolic Linear Regression",
        regressionType: .linear,
        polynomialDegree: 2
    )
    
    static let cubicLinearRegression = RegressionModel(
        name: "Cubic Linear Regression",
        regressionType: .linear,
        polynomialDegree: 3
    )
    
    static let complexLinearRegression = RegressionModel(
        name: "x^6 Linear Regression",
        regressionType: .linear,
        polynomialDegree: 6
    )
    
    static let logisticRegression = RegressionModel(
        name: "Logistic Regression",
        regressionType: .logistic,
        polynomialDegree: 1
    )
    
    static let models: [RegressionModel] = [
        simpleLinear,
        parabolaLinear,
        cubicLinearRegression,
        complexLinearRegression,
        logisticRegression
    ]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func defaultWeights(featureCount: Int) throws -> [Double] {
        try Array(repeating: 0, count: weightsCount(featureCount: featureCount))
    }
    
    func hypothesis(weights: [Double], x: [Double], bias: Double) throws -> Double {
        let terms = try regressionType.polynomialTerms(featureCount: x.count, maxDegree: polynomialDegree)
        
        return try regressionType.hypothesis(
            weights: weights,
            x: x,
            terms: terms,
            bias: bias
        )
    }
    
    func calculateCost(x: [[Double]], y: [Double], weights: [Double], bias: Double) throws -> Double {
        try regressionType.calculateCost(
            x: x,
            y: y,
            weights: weights,
            polynomialDegree: polynomialDegree,
            bias: bias
        )
    }
    
    func calculateGradient(x: [[Double]], y: [Double], weights: [Double], bias: Double) throws -> (weightsGradient: [Double], biasGradient: Double) {
        try regressionType.calculateGradient(
            x: x,
            y: y,
            weights: weights,
            polynomialDegree: polynomialDegree,
            bias: bias
        )
    }
    
    func modelDescription(featureCount: Int) throws -> String {
        let terms = try regressionType.polynomialTerms(featureCount: featureCount, maxDegree: polynomialDegree)
            
        var formula = ""
        for (index, term) in terms.enumerated() {
            if index > 0 {
                formula += " + "
            }
                
            formula += "w\(index + 1) * "
                
            var meaningfulExponentCount = 0
            for (j, exponent) in term.enumerated() {
                if meaningfulExponentCount > 0 {
                    formula += " * "
                }
                if exponent > 0 {
                    meaningfulExponentCount += 1
                        
                    formula += "x\(j + 1)"
                    if exponent > 1 {
                        formula += "^\(exponent)"
                    }
                }
            }
        }
            
        return formula + " + b"
    }
    
    func weightsCount(featureCount: Int) throws -> Int {
        try regressionType.polynomialTerms(featureCount: featureCount, maxDegree: polynomialDegree).count
    }

    /// Calculates the R-squared (coefficient of determination) for a regression model.
    /// - Parameters:
    ///   - actual: Array of actual values.
    ///   - predicted: Array of predicted values.
    /// - Returns: R² value between 0 and 1 (or negative if the model is worse than the mean).
    /// - Throws: `CalculationError` if arrays have different lengths or are empty.
    func calculateR2(x: [[Double]], weights: [Double], bias: Double, y: [Double]) throws -> Double {
        // Validate input
        guard !y.isEmpty, !weights.isEmpty, !x.isEmpty else {
            throw CalculationError.emptyInput
        }
        
        let predictions = try x.map { try hypothesis(weights: weights, x: $0, bias: bias) }
        
        guard y.count == predictions.count else {
            throw CalculationError.mismatchedArrays
        }
        
        // Calculate mean of actual values
        let meanActual = y.reduce(0, +) / Double(y.count)
        
        // Calculate Sum of Squared Residuals (SSR)
        let ssr = zip(y, predictions).map { pow($0 - $1, 2) }.reduce(0, +)
        
        // Calculate Total Sum of Squares (SST)
        let sst = y.map { pow($0 - meanActual, 2) }.reduce(0, +)
        
        // Avoid division by zero
        guard sst != 0 else {
            throw CalculationError.zeroVariance
        }
        
        // Calculate R²
        let r2 = 1 - (ssr / sst)
        return r2
    }
}
