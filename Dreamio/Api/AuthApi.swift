//
//  AuthApi.swift
//  Dreamio
//
//  Created by Bold Lion on 18.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class AuthApi {
    
    //***********************************//
    //**** MARK: - LOGIN USER
    //***********************************//
    func loginWith(email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { user, error in
            if error != nil  {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        })
    }
    
      //***********************************//
     //**** MARK: - REGISTER NEW USER
    //***********************************//
    func registerWith(username: String, email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void)  {
        Auth.auth().createUser(withEmail: email, password: password, completion: {
            user, error in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            if let uid = Auth.auth().currentUser?.uid {
                self.setUserInformation(username: username, email: email, uid: uid, onSuccess: onSuccess)
            }
        })
    }
    
    //***********************************//
    //**** MARK: - SET USERS DATABASE
    //***********************************//
    func setUserInformation(username: String, email: String, uid: String, onSuccess: @escaping () -> Void) {
        Api.Users.REF_USERS.child(uid).setValue([ "username"        : username.lowercased(),
                                                  "email"           : email,
                                                  "profileImageUrl" : ""  ])
        onSuccess()
    }
    
    //***********************************//
    //**** MARK: - RETRIEVE PASSWORD
    //***********************************//
    func resetPassword(withEmail: String, onSuccess: @escaping () -> Void,  onError: @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: withEmail) {
            error in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        }
    }
}
