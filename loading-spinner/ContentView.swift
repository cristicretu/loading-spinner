//
//  ContentView.swift
//  loading-spinner
//
//  Created by Cristian Cretu on 21.06.2023.
//

import SwiftUI

struct ContentView: View {


    let lineWidth = 13.0
    let target = 5000.0
    let increment = 45.0
    @GestureState private var dragOffset = CGSize.zero
    @State private var progress: Double = -90.0
    @State private var isDragging = false
    
    var remainingTime: String {
        let remainingProgress = target - progress
        let remainingSeconds = remainingProgress / increment * 0.2 // Assuming progress increments by 45 every 0.2 seconds
        let minutes = Int(remainingSeconds) / 60
        let seconds = Int(remainingSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    
    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .stroke(.gray.opacity(0.2), lineWidth: lineWidth)
                
                Circle()
                    .trim(from: 0, to: progress < target ? 0.2 : 1)
                    .stroke(.green, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .rotationEffect(.degrees(progress))
                    .gesture(DragGesture()
                        .updating($dragOffset, body: { value, state, _ in
                            state = value.translation
                        })
                        .onChanged({ value in
                            
                            isDragging = value.translation != .zero

                            let dragMagnitude = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                            let rotationAmount = Double(dragMagnitude / 36) // Adjust the speed here
                            progress += rotationAmount
                            progress = min(progress, target)
                        })
                    )
            }
            .onAppear {
                startTimer()
            }
            .frame(width: 120)
            .padding()
            
        
            Text(progress < target ? String(format: "%.1f%%", progress / target * 100): "Done!")
                .font(.title2)
                .foregroundColor(.white)
                .blur(radius: isDragging || progress >= target ? 0 : 4)
                .opacity(isDragging || progress >= target ? 1 : 0)
                .animation(.spring(), value: isDragging)
            
            Text("Estimated Time Remaining: \(remainingTime)")
                .offset(y: 128)
                .font(.subheadline)
                .foregroundColor(.white)
                
                .opacity(progress < target ? 1 : 0)
                .transition(.opacity)
                .id("MyTitleComponent" + remainingTime)

        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
                withAnimation {
                    progress += increment
                    isDragging = false

                    
                    if progress >= target {
                        timer.invalidate() // Stop the timer
                    }
                }
            }
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
