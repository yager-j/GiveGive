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
    let db = Firestore.firestore()
    let auth = Auth.auth()

    // MARK: CREATE
    
    /**
     Adds user as a document in Firestore
     */
    func addUserToDb(user: User) {
        if let id = user.id {
            do {
                _ = try db.collection("users").document(id).setData(from: user)
                
            } catch {
                print("Error saving user to db")
            }
        }
    }
   
    /**
     'Adds toy to Firestore
     */
    func addToy(toy: Toy) {
        var newToy = toy
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
    /*
    /**
     Updates journal entry in Firestore
     */
    func updateFirestoreItem(journalEntry: JournalEntry) {
        if let id = journalEntry.id {
            do {
                try db.collection("entries").document(id).setData(from: journalEntry)
            } catch {
                fatalError("Unable to encode entry: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: DELETE
    /**
     Deletes journal entry from Firestore
     */
    func deleteItem(journalEntry: JournalEntry) {
        if let id = journalEntry.id {
            db.collection("entries").document(id).delete() { err in
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
