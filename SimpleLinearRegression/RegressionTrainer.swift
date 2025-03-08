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
    
    private var updateStream: AsyncStream<(weights: [Double], bias: Double, step: Int, cost: Double)>?
    private var updateContinuation: AsyncStream<(weights: [Double], bias: Double, step: Int, cost: Double)>.Continuation?
    
    private var learingTask: Task<Void, Never>?
    
    init(x: [[Double]], y: [Double], w: [Double], b: Double, learningRate: Double, lambda: Double, precisionThreshold: Double, selectedModel: RegressionModel) {
        self.x = x
        self.y = y
        self.w = w
        self.b = b
        self.learningRate = learningRate
        self.lambda = lambda
        self.precisionThreshold = precisionThreshold
        self.selectedModel = selectedModel
        
        Task {
            await calculateAndUpdateCost()
        }
    }
    
    func startTraining() async -> AsyncStream<(weights: [Double], bias: Double, step: Int, cost: Double)> {
        isTraining = true
        
        let (updateStream, updateContinuation) = AsyncStream<(weights: [Double], bias: Double, step: Int, cost: Double)>.makeStream()
        self.updateStream = updateStream
        self.updateContinuation = updateContinuation
        
        learingTask = Task {
            defer {
                isTraining = false
                updateContinuation.finish()
                self.updateStream = nil
                self.updateContinuation = nil
                print("Training task completed or cancelled")
            }
            
            var costDeltaPercent: Double = 0
            
            repeat {
                if Task.isCancelled { return }
                
                await runOneStep()
                
                let update = (weights: w, bias: b, step: step, cost: currentCost)
                updateContinuation.yield(update)
                
                if Task.isCancelled { return }
                
                costDeltaPercent = (previousCost - currentCost) / previousCost * 100
                
                await Task.yield()
            } while previousCost == 0 || costDeltaPercent > precisionThreshold
            
            print("Training stopped early: cost delta \(costDeltaPercent) is less than \(precisionThreshold)%")
            print("Parameters after early stopping: \(w), \(b). Cost: \(currentCost)")
        }
        
        return updateStream
    }
    
    func stopTraining() {
        learingTask?.cancel()
        isTraining = false
        updateContinuation?.finish()
        updateStream = nil
        updateContinuation = nil
    }
    
    func runOneStep() async {
        await calculateGradients()
        previousCost = currentCost
        await calculateAndUpdateCost()
        
        step += 1
    }
    
    func resetTraining() {
        w = selectedModel.defaultWeights(featureCount: x[0].count)
        b = 0
        step = 0
        currentCost = 0
        previousCost = 0
    }
    
    func stateUpdates() -> AsyncStream<(weights: [Double], bias: Double, step: Int, cost: Double)>? {
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
    
    func updateModel(_ newModel: RegressionModel) {
        selectedModel = newModel
        resetTraining()
    }
    
    func update(x: [[Double]], y: [Double]) {
        self.x = x
        self.y = y
        
        resetTraining()
    }
    
    private func calculateGradients() async {
        let (wGradient, bGradient) = selectedModel.calculateGradient(x: x, y: y, weights: w, bias: b)
       // print("Gradients: \(wGradient), \(bGradient)")
        for j in 0..<w.count {
            w[j] -= learningRate * wGradient[j]
        }
        
        b -= learningRate * bGradient
    }
    
    private func calculateAndUpdateCost() async {
        currentCost = selectedModel.calculateCost(x: x, y: y, weights: w, bias: b)
    }
}
