//
//  UsersApi.swift
//  Dreamio
//
//  Created by Bold Lion on 18.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UsersApi {
    
    let REF_USERS = Database.database().reference().child(DatabaseLocation.Users)
    
    //***********************************//
    // MARK: - Observe Current User
    //**********************************//
    func observeCurrentUser(completion: @escaping (UserModel) -> Void) {
        guard let currentUser = Auth.auth().currentUser else { return }
        REF_USERS.child(currentUser.uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = UserModel.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    
    //*****************************************//
    // MARK: - Does Username Exist In Database
    //****************************************//
    func doesUsernameExistInDatabase(username: String, onSuccess: @escaping() -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        REF_USERS.queryOrdered(byChild: "username").queryEqual(toValue: username.lowercased()).observeSingleEvent(of: .value, with:  { snapshot in
            if snapshot.exists() {
                onError("Username already exists! Try another one.")
                return
            }
            else {
                onSuccess()
            }
        })
    }
    
    //*****************************************//
    // MARK: - Does Username Exist In Database
    //****************************************//
    func doesEmailExistInDatabase(email: String, onSuccess: @escaping() -> Void, onMatch: @escaping () -> Void) {
        REF_USERS.queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with:  { snapshot in
            if snapshot.exists() {
                onMatch()
                print("match")
                return
            }
            else {
                onSuccess()
                print("success case")
            }
        })
    }
    
    
    //***********************************//
    // MARK: - Get Current Logged User
    //**********************************//
    var CURRENT_USER: User? {
        if let currentUser = Auth.auth().currentUser {
            return currentUser
        }
        else {
            return nil
        }
    }
    
    //***********************************//
    // MARK: - Reference to Current User
    //**********************************//
    var REF_CURRENT_USER: DatabaseReference? {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return REF_USERS.child(currentUser.uid)
    }
    
    
}
