//
//  AuthViewModel.swift
//  GiveGive
//
//  Created by Joanne Yager on 2023-11-02.
//

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    
    let auth = Auth.auth()
    
    /**
     Signs user in anonymously
     */
    func anonymousSignIn() {
        auth.signInAnonymously { //[weak self]
            authResult, error in
            guard let user = authResult?.user else { return }
            let uid = user.uid
            print("Jo uid: \(uid)")
           /* DispatchQueue.main.async {
              //  self?.signedIn = true
              //  self?.loginType = .anon
              //  self?.createNewUser()
            }*/
        }
    }
}
