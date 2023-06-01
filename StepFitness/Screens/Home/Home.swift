//
//  ContentView.swift
//  StepFitness
//
//  Created by TaeVon Lewis on 5/30/23.
//

import SwiftUI
import HealthKit

struct Home: View {
    @State private var stepCount = 0
    @State private var stepGoal = 5000
    @State private var currentAffirmation = ""
    let thresholdsAndLabels: [((Int, Int), String)]
    let date = String(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))
    let healthStore = HKHealthStore()
    
    var activityLevel: String {
        for (range, label) in thresholdsAndLabels {
            if range.0 <= stepCount && stepCount <= range.1 {
                return label
            }
        }
        return "Unknown"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    ZStack {
                        SectionedProgressView(stepCount: $stepCount)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 100, trailing: 0))
                        Text(date)
                            .font(.largeTitle)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    HStack(spacing: 20) {
                        CardView {
                            VStack {
                                Text("Steps")
                                    .font(.title2)
                                    .underline(true, color: .black)
                                Text("\(stepCount)")
                                    .font(.title)
                                    .foregroundColor(.blue)
                            }
                        }
                        CardView {
                            VStack {
                                Text("Activity Level")
                                    .font(.title2)
                                    .underline(true, color: .black)
                                Text("\(activityLevel)")
                                    .font(.title)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    CardView {
                        VStack {
                            Text("Daily Goal")
                                .font(.title2)
                                .underline(true, color: .black)
                            Text("\(stepGoal)")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                    }
                    HStack {
                        Image(systemName: "sparkles")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.yellow)
                            .frame(width: 40.0, height: 40.0)
                        Text(currentAffirmation)
                            .font(.title2)
                            .italic()
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                            .foregroundColor(.blue)
                            .shadow(color: .gray, radius: 2, x: 2, y: 2)
                            .onAppear(perform: updateAffirmation)
                        Image(systemName: "sparkles")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.yellow)
                            .frame(width: 40.0, height: 40.0)
                    }
                }
                .padding()
            }
            .navigationTitle("StepFitness")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: requestAuthorization)
        }
    }
    
    func updateAffirmation() {
        let categories = Array(affirmations.keys)
        let randomCategory = categories.randomElement()!
        let randomAffirmation = affirmations[randomCategory]?.randomElement()!
        currentAffirmation = randomAffirmation!
    }
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount),
              let activeEnergyBurnedType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("Unable to create the health data types")
            return
        }
        
        healthStore.requestAuthorization(toShare: [], read: [stepCountType, activeEnergyBurnedType]) { (success, error) in
            if success {
                print("HealthKit authorization received")
                fetchHealthData()
            } else {
                print("Failed to get authorization for HealthKit")
            }
        }
    }
    
    func fetchHealthData() {
        fetchStepsCount()
    }
    
    func fetchStepsCount() {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: stepsQuantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            guard let samples = samples as? [HKQuantitySample] else { return }
            
            let totalSteps = samples.reduce(0) { (result, sample) in
                let stepCount = sample.quantity.doubleValue(for: HKUnit.count())
                return result + stepCount
            }
            
            DispatchQueue.main.async {
                self.stepCount = Int(totalSteps)
            }
        }
        
        healthStore.execute(query)
    }
}

struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(width: 150, height: 150)
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.white, Color.white.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 2, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 2)
            )
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home(thresholdsAndLabels: [((7500, 9999), "Somewhat Active")])
    }
}
