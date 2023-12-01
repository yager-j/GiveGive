//
//  AuthenticationManager.swift
//  GiveGive
//
//  Created by Joanne Yager on 2023-11-06.
//

import Foundation
import FirebaseAuth

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    let auth = Auth.auth()
    var currentUser: User?

    private init() {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        let newUser = User()
        newUser.id = userUID
                
        self.currentUser = newUser
    }
    
    /**
     Signs user in anonymously
     */
    func anonymousSignIn() async throws {
        
        _ = try await auth.signInAnonymously()
        try await self.createNewUser()

    }
    
    /**
     Creates new user object and saves it to Firestore user collection
     */
    func createNewUser() async throws {

        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        let newUser = User()
        newUser.id = userUID
                
        self.currentUser = newUser
        try await DatabaseManager.shared.addUserToDb(user: newUser)
    }
}
