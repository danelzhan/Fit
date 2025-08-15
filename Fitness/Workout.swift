//
//  Home.swift
//  Fitness
//
//  Created by Daniel Zhang on 2025-06-19.
//

import SwiftUI


struct Workout: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Binding
    var SelectedWorkout: WorkoutData
    
    @Binding
    var User: UserData
    
    @State
    var isEditing: Bool = false
    
    @State
    var isEmpty: Bool = false
    
    @State
    var newItemName: String = ""
    @FocusState
    private var isFocused: Bool
    
    var body: some View {
        
        
        ZStack {

            Color(red: 0.1176, green: 0.1176, blue: 0.1176).ignoresSafeArea()
            
            VStack {
                
                if (isEditing && !isEmpty) {
                    Text("Clear")
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 20))
                        .background(Color(red: 0.1176, green: 0.1176, blue: 0.1176))
                        .foregroundColor(Color(red: 1, green: 0.4706, blue: 0.4706))
                        .onTapGesture {
                            SelectedWorkout.sets.removeAll()
                            saveUserData(user: User)
                            isEditing = false;
                            isEmpty = true;
                        }
                }
                VStack {
                    
                    
                    ForEach($SelectedWorkout.sets) { $set in
                        NavigationLink(destination: Exercise(SelectedExercise: $set)) {
                            ListContainer(uuid: set.id, text: set.name, isComplete: set.completed)
                        }
                    }
                    
                    if isEditing {
                        TextField("New Set", text: $newItemName)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color(red: 0.8588, green: 0.8588, blue: 0.8588))
                            .font(.system(size: 20))
                            .multilineTextAlignment(.center)
                            .disableAutocorrection(true)
                            .onSubmit {
                                if  newItemName != "" {
                                    addNewSet(name: newItemName)
                                    newItemName = ""
                                    isEmpty = false;
                                }
                                isEditing = false
                            }
                            .focused($isFocused)
                            .onAppear {
                                isFocused = true
                            }
                            .padding([.top, .bottom], 13)
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
                            } else if value.translation.height > 20 {
                                for i in 0..<SelectedWorkout.sets.count {
                                    SelectedWorkout.sets[i].completed = false
                                    SelectedWorkout.sets[i].sets_completed = 0
                                }
                            } else if value.translation.height < -20 {
                                isEditing = true
                            }
                        }
                )
                .onAppear {
                    if SelectedWorkout.sets.isEmpty {
                        isEditing = true
                        isEmpty = true;
                    }
                }

            }
        }
                
    }
    
    func deleteWorkout(at offsets: IndexSet) {
        User.workouts.remove(atOffsets: offsets)
        saveUserData(user: User)
    }
    
    func addNewSet(name: String) {
        
        let newSet = SetData(id: UUID(), name: name, sets: 4)
        SelectedWorkout.sets.append(newSet)
        saveUserData(user: User)
        
    }
    
}
