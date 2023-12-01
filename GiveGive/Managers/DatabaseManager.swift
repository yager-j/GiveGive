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
    
    @Published var currentToyList: [Toy] = []
    
    init() {
        listenToFirestore()
    }
    
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
            print("Error saving toy to db")
        }
    }
    
    // MARK: READ
    func listenToFirestore() {
        let userId = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        
        db.collection("toys").order(by: "dateAdded", descending: false).whereField("currentOwner", isEqualTo: userId ?? "defaultId").addSnapshotListener { snapshot, err in
            guard let snapshot = snapshot else { return }
            
            if let err = err {
                print("Error getting toy document \(err)")
            } else {
                self.currentToyList.removeAll()
                for document in snapshot.documents {
                    let result = Result {
                        try document.data(as: Toy.self)
                    }
                    
                    switch result {
                    case .success(let toy):
                        self.currentToyList.append(toy)
                    case .failure(let error):
                        print("Error decoding toy list \(error)")
                    }
                }
            }
        }
    }
    
    // MARK: UPDATE
    
   /* func updateToyImagePath(toy: Toy, path: String) async throws {
        guard let id = toy.id else { return }
        let data: [String: Any] = [
            id : path
        ]
        toy.images.append(path)
        try await db.collection("toys").document(id).setData(data)
    }*/
    
    /**
     Updates toy owner in Firestore
     */
    func updateToyOwner(toyId: String) async throws {
        let idString = toyId as String
        let currentUser = Auth.auth().currentUser?.uid
        
        do {
            try await db.collection("toys").document(idString).updateData(["currentOwner" : currentUser ?? "noUserId"])
            print("toy owner updated \(String(describing: currentUser))")
        } catch {
            print("Error updating toy owner")
        }
        
    }
    
    
     
    // MARK: DELETE
    /**
     Deletes toy from Firestore
     **/
    func deleteItem(toy: Toy) {
        if let id = toy.id {
            
            if let name = toy.images.first?.name, let currentUser = Auth.auth().currentUser?.uid {
                StorageManager.shared.deleteImage(name: name, userId: currentUser)
            }
            
            db.collection("toys").document(id).delete() { err in
                if let err {
                    print("Unable to delete entry: \(err.localizedDescription)")
                } else {
                    print("Document successfully removed")
                }
            }
        }
    }
}
