//
//  Home.swift
//  Fitness
//
//  Created by Daniel Zhang on 2025-06-19.
//

import SwiftUI


struct Home: View {
    
    @State
    private var User: UserData = loadUserData()
    
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
                            User.workouts.removeAll()
                            saveUserData(user: User)
                            isEditing = false;
                            isEmpty = true;
                        }
                }
                
                VStack{
                    ForEach($User.workouts) { $workout in
                        NavigationLink(destination: Workout(SelectedWorkout: $workout, User: $User)) {
                            ListContainer(uuid: workout.id, text: workout.name, isComplete: false)
                        }
                    }
                    
                    if isEditing {
                        TextField("New Workout", text: $newItemName)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color(red: 0.8588, green: 0.8588, blue: 0.8588))
                            .font(.system(size: 20))
                            .multilineTextAlignment(.center)
                            .disableAutocorrection(true)
                            .onSubmit {
                                if  newItemName != "" {
                                    addNewWorkout(name: newItemName)
                                    newItemName = ""
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
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.height < -20 {
                                isEditing = true
                            }
                        }
                )
                .onAppear {
                    if User.workouts.isEmpty {
                        isEditing = true
                        isEmpty = true;
                    }
                }
            }
        }
        
    }
    
    func addNewWorkout(name: String) {
        
        let newWorkout = WorkoutData(id: UUID(), name: name, sets: [])
        User.workouts.append(newWorkout)
        saveUserData(user: User)
        
    }
    
    
}

func saveUserData(user: UserData) {
    if let data = try? JSONEncoder().encode(user) {
        UserDefaults.standard.set(data, forKey: "userData")
    }
}

func loadUserData() -> UserData {
    if let data = UserDefaults.standard.data(forKey: "userData"),
       let user = try? JSONDecoder().decode(UserData.self, from: data) {
        return user
    }
    return UserData(workouts: [])  // fallback default
}

struct ListContainer: View {
    
    var uuid: UUID
    var text: String
    var isComplete: Bool
    
    var body: some View {
        
        HStack{
            if (isComplete) {
                Text(text)
                    .foregroundStyle(Color(red: 0.5176, green: 0.5176, blue: 0.5176))
                    .font(.system(size: 20))
                    .strikethrough(color: Color(red: 0.5176, green: 0.5176, blue: 0.5176))
            } else {
                Text(text)
                    .foregroundStyle(Color(red: 0.8588, green: 0.8588, blue: 0.8588))
                    .font(.system(size: 20))
            }
        }
        .padding([.top, .bottom], 13)
        
    }
}

// preview
struct Home_Previews: PreviewProvider {
    static var previews: some View {
        return NavigationStack {
            Home()
        }
    }
}
