//
//  DatabaseManager.swift
//  GiveGive
//
//  Created by Joanne Yager on 2023-11-06.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import Firebase

class DatabaseManager: ObservableObject {
    
    static let shared = DatabaseManager()
    
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    private init() { }

    // MARK: CREATE
    
    /**
     Add user as a document in Firestore
     */
    func addUserToDb(user: User) async throws {
        if let id = user.id {
            do {
                _ = try db.collection("users").document(id).setData(from: user)
                
            } catch {
                print("Error saving user to db")
            }
        }
    }
   
    /**
     Add toy as a document in Firestore
     */
    func addToy(toy: Toy) {
        let newToy = toy
        let userId = Auth.auth().currentUser?.uid
        
        if let userId {
            newToy.currentOwner = userId
            newToy.ownerHistory.append(userId)
        }
        
        do {
            _ = try db.collection("toys").addDocument(from: newToy)
            
        } catch {
            print("Error saving to db")
        }
    }
    
    // MARK: READ
    
    
    // MARK: UPDATE
    
    func updateToyImagePath(toy: Toy, path: String) async throws {
        guard let id = toy.id else { return }
        let data: [String: Any] = [
            id : path
        ]
        toy.images.append(path)
        try await db.collection("toys").document(id).setData(data)
        print("Jo updateToyImagePathSuccess")
    }
    
    /*
    /**
     Updates toy in Firestore
     */
    func updateFirestoreItem(toy: Toy) {
        if let id = toy.id {
            do {
                try db.collection("toys").document(id).setData(from: toy)
            } catch {
                fatalError("Unable to encode entry: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: DELETE
    /**
     Deletes toy from Firestore
     */
    func deleteItem(toy: Toy) {
        if let id = toy.id {
            db.collection("toys").document(id).delete() { err in
                if let err = err {
                    print("Unable to delete entry: \(err.localizedDescription)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
    }
    
    }*/
}
