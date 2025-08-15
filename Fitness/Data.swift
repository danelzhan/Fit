//
//  Data.swift
//  Fitness
//
//  Created by Daniel Zhang on 2025-06-19.
//

import Foundation

struct SetData: Hashable, Identifiable, Codable {
    
    let id: UUID
    var name: String
    var sets: Int
    var completed: Bool
    var sets_completed: Int
    
    init(id: UUID, name: String, sets: Int) {
        self.id = id
        self.name = name
        self.sets = sets
        self.completed = false
        self.sets_completed = 0
    }
    
}

struct WorkoutData: Hashable, Identifiable, Codable {
    
    let id: UUID
    var name: String
    var sets: [SetData]
    
}

struct UserData: Hashable, Codable {
    
    var workouts: [WorkoutData]
    
}
