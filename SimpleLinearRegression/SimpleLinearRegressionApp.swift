//
//  SimpleLinearRegressionApp.swift
//  SimpleLinearRegression
//
//  Created by Stas Kirichok on 2/23/25.
//

import SwiftUI

@main
struct SimpleLinearRegressionApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 400, idealWidth: 850, maxWidth: .infinity, minHeight: 300, idealHeight: 650, maxHeight: .infinity)
        }
        .defaultPosition(.center)
        .windowResizability(.contentMinSize)
    }
}
