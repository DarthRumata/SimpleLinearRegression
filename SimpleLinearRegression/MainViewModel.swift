//
//  MainViewModel.swift
//  SimpleLinearRegression
//
//  Created by Stas Kirichok on 2/23/25.
//

import Foundation
import Observation

typealias RegressionUpdate = (weights: [Double], bias: Double, step: Int, cost: Double)

private enum Constants {
    static let updateInterval: TimeInterval = 0.05
}

@Observable
@MainActor
class MainViewModel {
    var w: [Double]
    var b: Double = 0
    var learningRate: Double = 0.0001 {
        didSet {
            Task { @MainActor in
                await regressionTrainer.updateLearningRate(learningRate)
            }
        }
    }

    var lambda: Double = 0.01 { // regularization parameter
        didSet {
            Task { @MainActor in
                await regressionTrainer.updateRegularization(lambda)
            }
        }
    }

    var precisionThreshold: Double = 0.001 {
        didSet {
            Task { @MainActor in
                await regressionTrainer.updatePrecisionThreshold(precisionThreshold)
            }
        }
    }

    var selectedModel: RegressionModel {
        willSet {
            isChangingModel = true
        }
        didSet {
            Task { @MainActor in
                await self.performModelUpdate {
                    await self.regressionTrainer.updateModel(self.selectedModel)
                }
            }
        }
    }

    var useXNormalization: Bool = false {
        willSet {
            isChangingModel = true
        }
        didSet {
            Task { @MainActor in
                await self.applyNormalizationUpdate()
            }
        }
    }
    
    var useYNormalization: Bool = false {
        willSet {
            isChangingModel = true
        }
        didSet {
            Task { @MainActor in
                await self.applyNormalizationUpdate()
            }
        }
    }
    
    private(set) var loadedDatasets = [Dataset.defaultDataset]
    var currentDatasetIndex = 0 {
        willSet {
            isChangingModel = true
        }
        didSet {
            Task { @MainActor in
                await self.applyNormalizationUpdate()
            }
        }
    }
    private(set) var step: Int = 0
    private(set) var isTraining: Bool = false
    private(set) var isChangingModel: Bool = false
    
    // [Step: Cost]
    private(set) var costHistory = [Double]()
    // [Step: (w, b)]
    private(set) var paramsHistory = [(w: [Double], b: Double)]()
    
    var currentDataset: Dataset {
        loadedDatasets[currentDatasetIndex]
    }
    
    var presentableData: (x: [[Double]], y: [Double]) {
        (
            x: useXNormalization ? currentDataset.xNorm : currentDataset.x,
            y: useYNormalization ? currentDataset.yNorm : currentDataset.y
        )
    }
    
    private var featureCount: Int {
        presentableData.x.first?.count ?? 0
    }

    var currentFormula: String {
        do {
            return try "y = \(selectedModel.modelDescription(featureCount: featureCount))"
        } catch {
            return "Error: \(error)"
        }
    }
    
    private var lastUpdateTime: Date = .distantPast
    private var pendingUpdateTask: Task<Void, Never>?
    
    @ObservationIgnored
    private lazy var regressionTrainer = RegressionTrainer(
        x: presentableData.x,
        y: presentableData.y,
        w: w,
        b: b,
        learningRate: learningRate,
        lambda: lambda,
        precisionThreshold: precisionThreshold,
        selectedModel: selectedModel
    )
    private let dataScaler = DataScaler()
    
    init() {
        let defaultModel = RegressionModel.simpleLinear
        let w = try! defaultModel.defaultWeights(featureCount: 1)
        selectedModel = defaultModel
        self.w = w
        
        Task { @MainActor in
            let updates = await regressionTrainer.stateUpdates()
            
            costHistory.append(await regressionTrainer.currentCost)
            
            for await update in updates {
                pendingUpdateTask?.cancel()
                
                let now = Date()
                let elapsedTime = now.timeIntervalSince(lastUpdateTime)
                if elapsedTime >= Constants.updateInterval {
                    await applyPendingUpdate(update)
                    lastUpdateTime = now
                } else {
                    pendingUpdateTask = Task {
                        if Task.isCancelled { return }
                        do {
                            try await Task.sleep(for: .seconds(Constants.updateInterval))
                            try Task.checkCancellation()
                        } catch {
                            // print(error)
                        }
                        
                        await applyPendingUpdate(update)
                    }
                }
            }
        }
    }
    
    func nextStepTapped() {
        Task { @MainActor in
            try await regressionTrainer.runOneStep()
            
            let w = await regressionTrainer.w
            let b = await regressionTrainer.b
            let step = await regressionTrainer.step
            let cost = await regressionTrainer.currentCost
            
            self.costHistory.append(cost)
            print("Cost history: \(costHistory), step: \(step)")
            self.paramsHistory.append((w, b))
            self.w = w
            self.b = b
            self.step = step
        }
    }
    
    func resetTapped() {
        Task { @MainActor in
            costHistory.removeAll()
            paramsHistory.removeAll()
            
            await regressionTrainer.resetTraining()
        }
    }
    
    func trainModel() {
        isTraining = true
        
        Task {
            await regressionTrainer.startTraining()
        }
    }
    
    func stopTraining() {
        Task {
            await regressionTrainer.stopTraining()
        }
    }
    
    func makeDatasetPickerViewModel() -> DatasetPickerViewModel {
        .init(onUpdateChangingModel: { [weak self] isChangingModel in
            self?.isChangingModel = isChangingModel
        }, onLoadDataset: { [weak self] dataset in
            guard let self else { return }
            
            self.loadedDatasets.append(dataset)
            self.currentDatasetIndex = self.loadedDatasets.count - 1
        }, onDeleteDataset: { [weak self] in
            guard let self else { return }
            
            guard self.currentDatasetIndex != 0 else {
                return
            }
            
            self.currentDatasetIndex -= 1
            self.loadedDatasets.removeLast()
        })
    }
    
    private func applyPendingUpdate(_ update: RegressionUpdate) async {
        if Task.isCancelled { return }
        
        let isTraining = await regressionTrainer.isTraining
        
        await MainActor.run {
            if Task.isCancelled { return }
            
            self.w = update.weights
            self.b = update.bias
            self.costHistory.append(update.cost)
            self.paramsHistory.append((update.weights, update.bias))
            self.step = update.step
            self.isTraining = isTraining
            print("Applied update at step \(update.step), cost: \(update.cost)")
        }
    }
    
    private func applyNormalizationUpdate() async {
        let data = presentableData
        await performModelUpdate {
            await self.regressionTrainer.update(preparedDataset: data)
        }
    }
    
    @MainActor
    private func performModelUpdate(_ updateAction: @escaping () async -> Void) async {
        costHistory.removeAll()
        paramsHistory.removeAll()
        
        await updateAction()
        
        isChangingModel = false
    }
}
