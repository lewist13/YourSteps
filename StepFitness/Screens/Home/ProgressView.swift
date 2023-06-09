//
//  ProgressView.swift
//  StepFitness
//
//  Created by TaeVon Lewis on 6/1/23.
//

import SwiftUI

struct SectionedProgressView: View {
    @Binding var stepCount: Int
    
    let thresholdsAndLabels = [
        ((0, 4999), "Sedentary"),
        ((5000, 7499), "Low Active"),
        ((7500, 9999), "Somewhat Active"),
        ((10000, 12499), "Active"),
        ((12500, 100_000), "Very Active")
    ]
    
    var body: some View {
        ZStack {
            ForEach(0..<5) { index in
                SectionView(startAngle: angleForIndex(index), endAngle: angleForIndex(index + 1) - .degrees(1), color: colorForIndex(index))
            }
        }
    }
    
    func angleForIndex(_ index: Int) -> Angle {
        let sectionSize = 360 / thresholdsAndLabels.count
        return .degrees(Double(index * sectionSize) - 90)
    }
    
    func colorForIndex(_ index: Int) -> Color {
        let (start, end) = thresholdsAndLabels[index].0
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
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2
            Path { path in
                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            }
            .stroke(AngularGradient(gradient: gradient, center: .center, startAngle: startAngle, endAngle: endAngle), lineWidth: ringWidth)
            .shadow(color: color.opacity(0.5), radius: 5, x: 5, y: 5)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

