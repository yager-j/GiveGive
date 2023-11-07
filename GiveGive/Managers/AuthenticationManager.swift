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

    private init() { }
    
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

        guard let userUID = auth.currentUser?.uid else { return }
        
        let newUser = User()
        newUser.id = userUID
                
        try await DatabaseManager.shared.addUserToDb(user: newUser)
        print("Jo uid \(userUID)")
    }
}
