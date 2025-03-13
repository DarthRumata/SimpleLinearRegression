//
//  DatasetPicker.swift
//  SimpleLinearRegression
//
//  Created by Stas Kirichok on 3/9/25.
//

import SwiftUI

struct DatasetPicker: View {
    let isChangingModel: Bool
    let datasets: [Dataset]
    @Binding var currentDataset: Dataset
    @State var viewModel: DatasetPickerViewModel

    @State private var isShowingFilePicker: Bool = false

    var body: some View {
        HStack {
            Picker("Dataset:", selection: $currentDataset) {
                ForEach(Array(zip(datasets.indices, datasets)), id: \.0) { index, dataset in
                    Text(dataset.name)
                        .tag(dataset)
                }
            }
            .pickerStyle(.menu)
            .fixedSize()

            HStack {
                Button("Load from CSV File") {
                    isShowingFilePicker = true
                }
                .fileImporter(
                    isPresented: $isShowingFilePicker,
                    allowedContentTypes: [.commaSeparatedText],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let urls):
                        if let url = urls.first {
                            Task {
                                await viewModel.processSelectedFile(url)
                                isShowingFilePicker = false
                            }
                        }
                    case .failure(let error):
                        isShowingFilePicker = false
                        print(error)
                    }
                }
                Button("Delete dataset") {
                    viewModel.deleteCurrentDataset()
                }
                .disabled(datasets.first == currentDataset)
                    
            }
            .disabled(isChangingModel)
            .popover(item: $viewModel.loadedDataset, content: { loadedDataset in
                DatasetFieldsSelectorView(
                    loadedDataset: loadedDataset) { x, y in
                        viewModel.selectFieldIndexes(xIndexes: x, yIndex: y)
                    } onCancel: {
                        viewModel.loadedDataset = nil
                    }
            })
        }
    }
}
