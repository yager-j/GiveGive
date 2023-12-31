//
//  StorageManager.swift
//  GiveGive
//
//  Created by Joanne Yager on 2023-11-09.
//

import Foundation
import FirebaseStorage
import UIKit

final class StorageManager {
    
    static let shared = StorageManager()
    private init() { }
    
    private let storage = Storage.storage().reference()
    
    private var imagesReference: StorageReference {
        storage.child("images")
    }
    
    private func userReference(userId: String) -> StorageReference {
        storage.child("users").child(userId)
    }
    
    func getUrlForImage(path: String) async throws -> URL {
        try await Storage.storage().reference(withPath: path).downloadURL()
    }
    
    func saveImage(data: Data, userId: String) async throws -> (path: String, name: String) {
        let meta = StorageMetadata()
        meta.contentType = "image/png"
        
        let path = "\(UUID().uuidString).png"
        let returnedMetadata = try await userReference(userId: userId).child(path).putDataAsync(data, metadata: meta)
        
        guard let returnedPath = returnedMetadata.path, let returnedName = returnedMetadata.name else {
            throw URLError(.badServerResponse)
        }
        return (returnedPath, returnedName)
        
    }
    
    func saveImage(image: UIImage, userId: String) async throws -> (path: String, name: String) {
        
        guard let compressedPng = image.pngData() else {
            print("error getting png data")
            throw URLError(.backgroundSessionWasDisconnected)
        }

        return try await saveImage(data: compressedPng, userId: userId)
    }
    
    func deleteImage(name: String, userId: String) {
       
        userReference(userId: userId).child(name).delete { error in
            if let error {
                print(error)
            } else {
                print("Image deleted from storage")
            }
        }
    }
}
