//
//  DatasetFieldsSelectorView.swift
//  SimpleLinearRegression
//
//  Created by Stas Kirichok on 3/10/25.
//

import SwiftUI

struct DatasetFieldsSelectorView: View {
    let loadedDataset: LoadedDataset
    let onSelectFieldIndexes: ([Int], Int) -> Void
    let onCancel: () -> Void

    @State private var selectedXIndexes: [Int] = []
    @State private var selectedYIndex: Int = -1

    var body: some View {
        VStack {
            HStack(spacing: 15) {
                ForEach(Array(zip(loadedDataset.featureNames.indices, loadedDataset.featureNames)), id: \.0) { featureIndex, featureName in
                    let isXSelectedBinding = Binding<Bool>(
                        get: { selectedXIndexes.contains(featureIndex) },
                        set: { newValue in
                            if newValue {
                                selectedXIndexes.append(featureIndex)
                                if selectedYIndex == featureIndex {
                                    selectedYIndex = -1
                                }
                            } else {
                                selectedXIndexes.removeAll { $0 == featureIndex }
                            }
                        }
                    )
                    let isYSelectedBinding = Binding<Bool>(
                        get: { selectedYIndex == featureIndex },
                        set: { newValue in
                            if newValue {
                                selectedYIndex = featureIndex
                                if selectedXIndexes.contains(featureIndex) {
                                    selectedXIndexes.removeAll { $0 == featureIndex }
                                }
                            } else {
                                selectedYIndex = -1
                            }
                        }
                    )
                    
                    VStack {
                        Text(featureName)
                            .bold()
                        let column = loadedDataset.table.map { $0[featureIndex] }
                        let min = column.min() ?? 0
                        let max = column.max() ?? 0
                        Text("Range: \(min.formatted()) - \(max.formatted())")
                        
                        Toggle(isOn: isXSelectedBinding) {
                            Text("x")
                        }
                        Toggle(isOn: isYSelectedBinding) {
                            Text("y")
                        }
                    }
                }
            }
            
            HStack {
                Button("Add") {
                    onSelectFieldIndexes(selectedXIndexes, selectedYIndex)
                }
                Button("Cancel", role: .cancel) {
                    onCancel()
                }
            }
        }
        .padding(10)
    }
}
