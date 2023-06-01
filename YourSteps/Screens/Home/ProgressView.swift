//
//  ProgressView.swift
//  YourSteps
//
//  Created by TaeVon Lewis on 6/1/23.
//

import SwiftUI

struct SectionedProgressView: View {
    @Binding var stepCount: Int
    
    let thresholds = [(0, 4999), (5000, 7499), (7500, 9999), (10001, 12499), (12500, 100_000)]
    let labels = ["Sedentary", "Low Active", "Somewhat Active", "Active", "Very Active"]
    
    var body: some View {
        ZStack {
            ForEach(0..<5) { index in
                SectionView(startAngle: angleForIndex(index), endAngle: angleForIndex(index + 1) - .degrees(1), color: colorForIndex(index))
            }
        }
    }
    
    func angleForIndex(_ index: Int) -> Angle {
        let sectionSize = 360 / thresholds.count
        return .degrees(Double(index * sectionSize) - 90)
    }
    
    func colorForIndex(_ index: Int) -> Color {
        let (start, end) = thresholds[index]
        return (start...end).contains(stepCount) ? .green : .gray
    }
}

struct SectionView: View {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color
    
    var gradient: Gradient {
        Gradient(colors: [color, color.opacity(0.8)])
    }
    
    var body: some View {
        let ringWidth: CGFloat = 20
        Path { path in
            path.addArc(center: .zero, radius: 150, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
        .stroke(AngularGradient(gradient: gradient, center: .center, startAngle: startAngle, endAngle: endAngle), lineWidth: ringWidth)
        .shadow(color: color.opacity(0.5), radius: 5, x: 5, y: 5)
        .padding(EdgeInsets(top: 150, leading: 100, bottom: 0, trailing: 0))
        .frame(width: 200, height: 200)
    }
}

