//
//  SimpleLinearRegressionTests.swift
//  SimpleLinearRegressionTests
//
//  Created by Stas Kirichok on 3/5/25.
//

import Testing
@testable import SimpleLinearRegression

struct SimpleLinearRegressionTests {

    @Test func testWeights() async throws {
        var model = RegressionModel.simpleLinear
        
        #expect(model.weightsCount(featureCount: 2) == 2)
        #expect(model.weightsCount(featureCount: 3) == 3)
        #expect(model.weightsCount(featureCount: 1) == 1)
        
        model = .parabolaLinear
        
        #expect(model.weightsCount(featureCount: 1) == 2)
        #expect(model.weightsCount(featureCount: 2) == 5)
    }
    
    @Test func testHypothesis() async throws {
        var model = RegressionModel.simpleLinear
        
        #expect(model.hypothesis(weights: [1], x: [2], bias: 1) == 3)
        
        model = .parabolaLinear
        
        #expect(model.hypothesis(weights: [1, 2, 1, 2, 3], x: [2, -1], bias: -1) == 10)
    }
    
    @Test func testCost() async throws {
        var model = RegressionModel.simpleLinear
        
        #expect(model.calculateCost(x: [[1], [2]], y: [1, 3], weights: [2], bias: 1) == 2)
        
        model = .parabolaLinear
        
        #expect(model.calculateCost(x: [[1, -1], [2, 2]], y: [1, 4], weights: [2, -1, 3, -1, 1], bias: 1) == 3.25)
    }

}
