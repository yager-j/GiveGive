//
//  User.swift
//  GiveGive
//
//  Created by Joanne Yager on 2023-11-06.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation

class User: Codable, Identifiable {
    
    var id: String?
    var birthdate = Date()
    var gender = Gender.na
   // var currentToys: [Toy] = []
   // var historyToys: [Toy] = []
}

enum Gender: Codable {
    case male, female, other, na
}

class Toy: Codable, Identifiable {
    @DocumentID var id: String?
    
    var category: String = ""
    var dateAdded = Timestamp()
    var images: [String] = []
    var location: Location = Location()
    var readyToSwap: Bool = false
    var swapHistory: [Date] = []
    var readyToSwapHistory: [Date] = []
    var currentOwner: String?
    var ownerHistory: [String] = []
}

struct Location: Codable {
    
}

