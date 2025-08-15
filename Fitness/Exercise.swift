//
//  Home.swift
//  Fitness
//
//  Created by Daniel Zhang on 2025-06-19.
//

import SwiftUI

struct Exercise: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Binding
    var SelectedExercise: SetData
    
    @State
    var isExercising: Bool = false
    @State
    var isResting: Bool = false
    @State
    var isEditing: Bool = false
    
    @State
    var newSets: String = ""
    
    @FocusState
    private var isFocused: Bool
    
    
    @State private var elapsedTime: TimeInterval = 0
    @State private var timerRunning = false
    @State private var timer: Timer? = nil
    @State private var angle: Double = 0
    @State private var angleTimer: Timer? = nil

    let radius: CGFloat = 125           // radius of orbit
    let animationDuration: Double = 60    // full loop time
    
    var body: some View {
        
        VStack {
            
            ZStack {
                Text(TimeString(from: elapsedTime))
                    .foregroundStyle(Color(red: 0.8588, green: 0.8588, blue: 0.8588))
                    .font(.system(size: 24))
                
                ZStack {
                    Circle()
                        .fill(.black.opacity(0))
                        .stroke(Color(red: 0.8588, green: 0.8588, blue: 0.8588), lineWidth: 5)
                        .frame(width: 250, height: 250)
                    
                    ArcShape(startAngle: .degrees(-90), endAngle: .degrees(angle - 90), clockwise: false)
                        .stroke((isResting ? Color(red: 0.5137, green: 1, blue: 0.4706) :
                                    Color(red: 1, green: 0.4706, blue: 0.4706)), lineWidth: 5)
                        .frame(width: radius * 2, height: radius * 2)
                    Circle()
                       .fill((isResting ? Color(red: 0.5137, green: 1, blue: 0.4706) :
                                Color(red: 1, green: 0.4706, blue: 0.4706)))
                       .frame(width: 10, height: 10)
                       .offset(x: radius) // start at the right edge
                       .rotationEffect(.degrees(angle - 90)) // rotate around center
                }
            }
            
            Spacer().frame(maxWidth: .infinity, maxHeight: CGFloat(50))

            Text(SelectedExercise.name)
                .foregroundStyle(Color(red: 0.8588, green: 0.8588, blue: 0.8588))
                .font(.system(size: 20))
            
            Spacer().frame(maxWidth: .infinity, maxHeight: CGFloat(20))

            HStack {
                HStack {
                    Text(String(format: "%d /", SelectedExercise.sets_completed, SelectedExercise.sets))
                        .foregroundStyle(Color(red: 0.8588, green: 0.8588, blue: 0.8588))
                        .font(.system(size: 20))
                }.frame(alignment: .trailing)
                
                if !isEditing {
                    Text(String(format: "%d",SelectedExercise.sets))
                        .foregroundStyle(Color(red: 0.8588, green: 0.8588, blue: 0.8588))
                        .font(.system(size: 20))
                        .multilineTextAlignment(.leading)
                        .padding(CGFloat(-3))
                } else {
                    TextField("", text: $newSets)
                        .foregroundStyle(Color(red: 0.8588, green: 0.8588, blue: 0.8588))
                        .font(.system(size: 20))
                        .fixedSize()
                        .frame(minWidth: CGFloat(12))
                        .multilineTextAlignment(.leading)
                        .disableAutocorrection(true)
                        .keyboardType(.numberPad)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    SelectedExercise.sets = Int(newSets) ?? 0
                                    newSets = ""
                                    isEditing = false
                                }
                            }
                        }                // controls return key label
                        .onChange(of: newSets) {
                                if newSets.count > 2 {
                                    newSets = String(newSets.prefix(2))
                                }
                            }
                        .onSubmit {
                            SelectedExercise.sets = Int(newSets) ?? 0
                            newSets = ""
                            isEditing = false
                        }
                        .focused($isFocused)
                        .onAppear {
                            isFocused = true
                        }
                        .padding(CGFloat(-3))
                }
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.1176, green: 0.1176, blue: 0.1176))
        .navigationBarBackButtonHidden(true)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 20 {
                        dismiss()
                    } else if value.translation.height < -50 {
                        isEditing = true
                    }
                }
        )
        .onTapGesture(count: 2) {
            if isExercising || isResting {
                reset()
                resetAngleAnimation()
                start()
                checkComplete()
                isExercising.toggle()
                isResting.toggle()
            } else {
                isExercising = true
                start()
                startAngleAnimation()
            }
        }
    }
    
    func checkComplete() {
        
        if isExercising {
            SelectedExercise.sets_completed += 1;
            
            if SelectedExercise.sets_completed == SelectedExercise.sets {
                SelectedExercise.completed = true;
            }
            
        }
        
    }
    
    func start() {
        timerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            elapsedTime += 0.01
        }
    }
    
    func stop() {
        timerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        stop()
        elapsedTime = 0
    }

    func startAngleAnimation() {
        angle = 0
        angleTimer?.invalidate()
        angleTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            angle += 360 / (animationDuration * 100)  // advance a bit each tick
            if angle >= 360 { angle -= 360 }
        }
    }

    func stopAngleAnimation() {
        angleTimer?.invalidate()
        angleTimer = nil
    }
    
    func resetAngleAnimation() {
        angle = 0;
    }

    
    func TimeString(from time: TimeInterval) -> String {
        let minutes = Int(time / 60)
        let seconds = Int(time) % 60

        return String(format: "%01d:%02d", minutes, seconds)
    }
}

struct ArcShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: clockwise
        )
        return path
    }
}
