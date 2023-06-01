//
//  StepFitnessApp.swift
//  StepFitness
//
//  Created by TaeVon Lewis on 5/30/23.
//

import SwiftUI

@main
struct StepFitnessApp: App {
    var body: some Scene {
        WindowGroup {
            Home(thresholdsAndLabels: [
                ((0, 4999), "Sedentary"),
                ((5000, 7499), "Low Active"),
                ((7500, 9999), "Somewhat Active"),
                ((10000, 12499), "Active"),
                ((12500, 100_000), "Very Active")
            ])
        }
    }
}
