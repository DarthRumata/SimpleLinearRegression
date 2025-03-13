//
//  DatasetPickerViewModel.swift
//  SimpleLinearRegression
//
//  Created by Stas Kirichok on 3/9/25.
//

import Foundation
import CSV

struct LoadedDataset: Identifiable {
    let id = UUID()
    let name: String
    let table: [[Double]]
    let featureNames: [String]
}

@Observable
@MainActor
class DatasetPickerViewModel {
    var loadedDataset: LoadedDataset? {
        didSet {
            onUpdateChangingModel(false)
        }
    }
    
    @ObservationIgnored
    private let onUpdateChangingModel: (Bool) -> Void
    @ObservationIgnored
    private let onLoadDataset: (Dataset) -> Void
    @ObservationIgnored
    private let onDeleteDataset: () -> Void
    
    init(
        onUpdateChangingModel: @escaping (Bool) -> Void,
        onLoadDataset: @escaping (Dataset) -> Void,
        onDeleteDataset: @escaping () -> Void
    ) {
        self.onUpdateChangingModel = onUpdateChangingModel
        self.onLoadDataset = onLoadDataset
        self.onDeleteDataset = onDeleteDataset
    }
    
    func processSelectedFile(_ url: URL) async {
        onUpdateChangingModel(true)
        
        do {
            let (table, names) = try await loadDataTable(from: url)
            
            print("Loaded dataset: table=\(table), names=\(names)")
            loadedDataset = .init(name: url.lastPathComponent, table: table, featureNames: names)
        } catch {
            print(error)
            onUpdateChangingModel(false)
        }
    }
    
    func selectFieldIndexes(xIndexes: [Int], yIndex: Int) {
        guard let table = loadedDataset?.table, let name = loadedDataset?.name else { return }
        
        var x: [[Double]] = []
        var y: [Double] = []
        for row in table {
            var xRow = [Double]()
            for i in xIndexes {
                xRow.append(row[i])
            }
            x.append(xRow)
            y.append(row[yIndex])
        }
        onLoadDataset(.init(name: name, x: x, y: y))
        loadedDataset = nil
    }
    
    func deleteCurrentDataset() {
        onDeleteDataset()
    }
    
    private func loadDataTable(from url: URL) async throws -> (table: [[Double]], names: [String]) {
        guard url.startAccessingSecurityScopedResource() else {
                    throw NSError(domain: "CSVError", code: -5, userInfo: [NSLocalizedDescriptionKey: "Failed to access security-scoped resource"])
        }
        defer { url.stopAccessingSecurityScopedResource() } // Ensure resource is stopped
        
        let stream = InputStream(fileAtPath: url.path())!
        let csv = try CSVReader(stream: stream, hasHeaderRow: true)
        
        var table: [[Double]] = []
        
        while csv.next() != nil {
            guard let row = csv.currentRow else { continue }
            
            var valuesRow = [Double]()
            for element in row {
                let value = Double(element) ?? 0
                valuesRow.append(value)
            }
            
            table.append(valuesRow)
        }
        
        guard let names = csv.headerRow else {
            throw NSError(domain: "CSVError", code: -6, userInfo: [NSLocalizedDescriptionKey: "CSV file has no header row"])
        }
        
        return (table: table, names: names)
    }
}
