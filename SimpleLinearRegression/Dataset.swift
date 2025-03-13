//
//  Dataset.swift
//  SimpleLinearRegression
//
//  Created by Stas Kirichok on 3/11/25.
//

import Foundation

final class Dataset: Hashable, @unchecked Sendable {
    let id: UUID = UUID()
    let name: String
    let x: [[Double]]
    let y: [Double]
    
    init(name: String, x: [[Double]], y: [Double]) {
        self.name = name
        self.x = x
        self.y = y
    }
    
    static func == (lhs: Dataset, rhs: Dataset) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    private(set) lazy var xScalers = Array(repeating: DataScaler(), count: x[0].count)
    private(set) lazy var yScaler = DataScaler()
    private(set) lazy var xNorm: [[Double]] = {
        var xColumns = x.transpose()
        
        for (j, column) in xColumns.enumerated() {
            xColumns[j] = xScalers[j].zScoreNormalization(column)
        }
        
        return xColumns.transpose()
    }()
    private(set) lazy var yNorm: [Double] = {
        return yScaler.zScoreNormalization(y)
    }()
    
    static let defaultDataset: Dataset = {
        let x: [Double] = [
            19, 7.5, 9.3, 10.1, 10, 10.8, 10.4, 10.7, 11.4, 11.3,
            11.3, 11.5, 12.1, 11.7, 13.2, 13.8, 12.5, 12.9, 13.8, 15,
            13.5, 14.3, 16.5, 15.7, 17.5, 16.8, 17.2, 17.8, 18.2, 18.2,
            16.3, 16.2, 19.1, 19, 20, 19, 18.6, 19.4, 17.5, 20,
            20, 19, 19.3, 20, 20.5, 20, 21, 19, 20.5, 19.8,
            20.7, 22, 20.4, 18.4, 20.5, 21, 20.5, 21.1, 22, 22,
            19, 21.5, 23.6, 23, 22.6, 23.5, 22.1, 21.2, 30, 25,
            22, 23.2, 25.4, 25.9, 25.4, 25.4, 23.6, 24.1, 25, 23,
            24, 24, 24, 25.2, 26.9, 31.7, 32.7, 34.8, 25.6, 27.8,
            23.9, 29.5, 36, 26.3, 27.6, 29.5, 26.5, 35.5, 26.8, 27.6,
            40, 28.4, 26.8, 28.5, 28.7, 29.1, 42, 40, 30.5, 28.5,
            40.1, 32, 43.2, 31.3, 29.4, 29.4, 30.9, 31.5, 31, 36.5,
            31.8, 31.4, 34, 34.6, 30.4, 30.4, 31.9, 34, 34.5, 32.7,
            32, 31.8, 44.8, 33.7, 36.6, 37.1, 32.5, 32.8, 36.9, 36.5,
            37, 35, 36.2, 38, 48.3, 35, 37.4, 33.5, 37.3, 39.8,
            40.2, 41.1, 37, 39, 40.1, 52, 56, 56, 59
        ]
        let y: [Double] = [
            8, 5.9, 6.7, 7, 7.5, 8.7, 9.7, 9.8, 9.8, 9.9,
            10, 12.2, 12.2, 13.4, 19.7, 19.9, 32, 40, 40, 51.5,
            55, 60, 69, 70, 78, 78, 80, 85, 85, 87,
            90, 100, 110, 110, 110, 115, 120, 120, 120, 120,
            120, 125, 130, 130, 130, 135, 140, 140, 145, 145,
            145, 145, 150, 150, 150, 150, 160, 160, 161, 169,
            170, 170, 180, 180, 188, 197, 200, 200, 200, 218,
            225, 242, 250, 250, 260, 265, 270, 270, 272, 273,
            290, 290, 300, 300, 300, 300, 300, 300, 300, 306,
            320, 340, 340, 345, 363, 390, 390, 430, 430, 450,
            450, 456, 475, 500, 500, 500, 500, 500, 510, 514,
            540, 540, 556, 567, 575, 600, 600, 610, 620, 650,
            650, 680, 685, 685, 690, 700, 700, 700, 700, 700,
            714, 720, 725, 770, 800, 820, 820, 840, 850, 850,
            900, 900, 920, 925, 950, 950, 955, 975, 1000, 1000,
            1000, 1000, 1000, 1015, 1100, 1100, 1250, 1550, 1600
        ]
        
        return Dataset(name: "Default Fish Dataset", x: x.map { [$0] }, y: y)
    }()
}

extension Array where Element: Collection, Element.Index == Int {
    /// Returns a transposed version of this array of collections.
    ///
    /// Each inner collection must have the same count; otherwise, this function will
    /// trigger a runtime error.
    ///
    /// - Returns: A two-dimensional array where the rows and columns are swapped.
    func transpose() -> [[Element.Element]] {
        // If the array is empty or the first row is empty, return an empty array.
        guard let firstRow = self.first, !firstRow.isEmpty else { return [] }
        
        // All inner collections must have the same count.
        let columnCount = firstRow.count
        guard self.allSatisfy({ $0.count == columnCount }) else {
            fatalError("Cannot transpose array with inconsistent row lengths")
        }
        
        // Map over each column index, then for each index, extract that element from every row.
        return (0..<columnCount).map { col in
            self.map { $0[col] }
        }
    }
}
