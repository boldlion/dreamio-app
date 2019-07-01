//
//  UserNotebooks.swift
//  Dreamio
//
//  Created by Bold Lion on 24.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import Foundation
import FirebaseDatabase

class UserNotebooksApi {
 
    let REF_USER_NOTEBOOKS = Database.database().reference().child(DatabaseLocation.user_notebooks)
    
    //***********************************//
    //**** MARK: - Add New Notebook
    //***********************************//
    func addNotebook(withUid notebookUid: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        guard let userUid = Api.Users.CURRENT_USER?.uid else { return }
        REF_USER_NOTEBOOKS.child(userUid).child(notebookUid).setValue(true, withCompletionBlock: { error, _ in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            else {
                onSuccess()
            }
        })
    }
    
    //*****************************************//
    //**** MARK: - Fetch Current User Notebooks
    //****************************************//
    func fetchUserNotebooksForCurrentUser(onSuccess: @escaping (Notebook) -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        guard let uid = Api.Users.CURRENT_USER?.uid else { return }
        REF_USER_NOTEBOOKS.child(uid).observe(.childAdded, with: { snapshot in
            let notebookId = snapshot.key
            Api.Notebooks.fetchNotebookWith(uid: notebookId, onSuccess: { notebook in
                onSuccess(notebook)
            }, onError: { error in
                onError(error)
                return
            })
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
    //*****************************************//
    //**** MARK: - Fetch All Notebooks for User
    //****************************************//
    func fetchAllNotebooksForCurrentUser(onSuccess: @escaping ([Notebook]) -> Void, onError: @escaping (_ message: String) -> Void) {
        guard let userId = Api.Users.CURRENT_USER?.uid else { return }
        var tempNotebooks = [Notebook]()
        REF_USER_NOTEBOOKS.child(userId).observe(.value, with: { snapshot in
            let notebooksCount =  Int(snapshot.childrenCount)
            if let child = snapshot.value as? [String: Any] {
                for (key, _) in child {
                    Api.Notebooks.fetchNotebookWith(uid: key, onSuccess: { notebook in
                        tempNotebooks.append(notebook)
                        if tempNotebooks.count == notebooksCount {
                            onSuccess(tempNotebooks)
                        }
                    }, onError: onError)
                }
            }
        })
    }
    
    //*****************************************//
    //**** MARK: - Default Notebook Did Change
    //****************************************//
    func defaultNotebookDidChange(onSuccess: @escaping (Notebook) -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        guard let uid = Api.Users.CURRENT_USER?.uid else { return }
        REF_USER_NOTEBOOKS.child(uid).observe(.childAdded, with: { snapshot in
            let key = snapshot.key
            Api.Notebooks.defaultNotebookDidChange(uid: key, onSuccess: { notebook in
                onSuccess(notebook)
            }, onError: { error in
                onError(error)
            })
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
    //***********************************//
    //**** MARK: - Delete User's Notebook
    //***********************************//
    func deleteNotebook(withId uid: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        guard let userUid = Api.Users.CURRENT_USER?.uid else { return }
        REF_USER_NOTEBOOKS.child(userUid).child(uid).removeValue() { error, _ in
            if error == nil {
                onSuccess()
            }
            else {
                onError(error!.localizedDescription)
                return
            }
        }
    }
    
    deinit {
        print("UserNotebooksApi class has been deinitialised")
    }
}

