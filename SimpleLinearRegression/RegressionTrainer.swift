//
//  RegressionTrainer.swift
//  SimpleLinearRegression
//
//  Created by Stas Kirichok on 3/5/25.
//

actor RegressionTrainer {
    private(set) var w: [Double]
    private(set) var b: Double = 0
    private(set) var step = 0
    // [Step: Cost]
    private(set) var currentCost: Double = 0
    private(set) var isTraining = false
    
    private var learningRate: Double = 0.0001
    private var lambda: Double = 0.01 // regularization parameter
    private var precisionThreshold: Double = 0.001
    private var selectedModel: RegressionModel
    private var x: [[Double]]
    private var y: [Double]
    private var previousCost: Double = 0
    
    private var updateStream: AsyncStream<(weights: [Double], bias: Double, step: Int, cost: Double)>
    private var updateContinuation: AsyncStream<(weights: [Double], bias: Double, step: Int, cost: Double)>.Continuation
    
    private var learingTask: Task<Void, Error>?
    
    init(x: [[Double]], y: [Double], w: [Double], b: Double, learningRate: Double, lambda: Double, precisionThreshold: Double, selectedModel: RegressionModel) {
        self.x = x
        self.y = y
        self.w = w
        self.b = b
        self.learningRate = learningRate
        self.lambda = lambda
        self.precisionThreshold = precisionThreshold
        self.selectedModel = selectedModel
        
        let (updateStream, updateContinuation) = AsyncStream<(weights: [Double], bias: Double, step: Int, cost: Double)>.makeStream(of: RegressionUpdate.self, bufferingPolicy: .bufferingNewest(1))
        self.updateStream = updateStream
        self.updateContinuation = updateContinuation
        
        Task {
            try await calculateAndUpdateCost()
        }
    }
    
    func startTraining() async {
        isTraining = true
        
        learingTask = Task {
            defer {
                isTraining = false
                let update = (weights: w, bias: b, step: step, cost: currentCost)
                updateContinuation.yield(update)
                print("Training task completed or cancelled on step: \(step)")
            }
            
            var costDeltaPercent: Double = 0
            
            repeat {
                if Task.isCancelled { return }
                
                try await runOneStep()
                
                let update = (weights: w, bias: b, step: step, cost: currentCost)
                updateContinuation.yield(update)
                
                if Task.isCancelled { return }
                
                costDeltaPercent = (previousCost - currentCost) / previousCost * 100
                
                await Task.yield()
            } while previousCost == 0 || costDeltaPercent > precisionThreshold
            
            print("Training stopped early: cost delta \(costDeltaPercent) is less than \(precisionThreshold)%")
            print("Parameters after early stopping: \(w), \(b). Cost: \(currentCost)")
        }
    }
    
    func stopTraining() {
        learingTask?.cancel()
    }
    
    func runOneStep() async throws {
        try await calculateGradients()
        previousCost = currentCost
        try await calculateAndUpdateCost()
        
        step += 1
    }
    
    func resetTraining() async {
        w = (try? selectedModel.defaultWeights(featureCount: x[0].count)) ?? []
        b = 0
        step = 0
        do {
            try await calculateAndUpdateCost()
        } catch {
            currentCost = 0
        }
        previousCost = 0
        
        let update = (weights: w, bias: b, step: step, cost: currentCost)
        updateContinuation.yield(update)
    }
    
    func stateUpdates() -> AsyncStream<(weights: [Double], bias: Double, step: Int, cost: Double)> {
        updateStream
    }
    
    func updateLearningRate(_ newLearningRate: Double) {
        learningRate = newLearningRate
    }
    
    func updateRegularization(_ newRegularization: Double) {
        lambda = newRegularization
    }
    
    func updatePrecisionThreshold(_ newPrecisionThreshold: Double) {
        precisionThreshold = newPrecisionThreshold
    }
    
    func updateModel(_ newModel: RegressionModel) async {
        selectedModel = newModel
        await resetTraining()
    }
    
    func update(preparedDataset: (x: [[Double]], y: [Double])) async {
        self.x = preparedDataset.x
        self.y = preparedDataset.y
        
        await resetTraining()
    }
    
    private func calculateGradients() async throws {
        let (wGradient, bGradient) = try selectedModel.calculateGradient(x: x, y: y, weights: w, bias: b)
       // print("Gradients: \(wGradient), \(bGradient)")
        for j in 0..<w.count {
            let regularizationValue = lambda * w[j] / Double(x.count)
            w[j] -= learningRate * (wGradient[j] + regularizationValue)
        }
        
        b -= learningRate * bGradient
    }
    
    private func calculateAndUpdateCost() async throws {
        let regularizationCost = lambda * (w.reduce(0) { $0 + $1 * $1 }) / 2 / Double(x.count)
        //print("Regularized cost:", regularizationCost)
        currentCost = try selectedModel.calculateCost(x: x, y: y, weights: w, bias: b) + regularizationCost
    }
}
