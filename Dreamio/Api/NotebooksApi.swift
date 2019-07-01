//
//  NotebooksApi.swift
//  Dreamio
//
//  Created by Bold Lion on 24.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import Foundation
import FirebaseDatabase

class NotebooksApi {
    
    let REF_NOTEBOOKS = Database.database().reference().child(DatabaseLocation.notebooks)
    
    //***********************************//
    //**** MARK: - Create First Notebook - for account creation only! It will set the first
    //***********************************//
    func createFirstNotebook(onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        guard let notebookId = REF_NOTEBOOKS.childByAutoId().key else { return }
        let creationDate = Int(Date().timeIntervalSince1970)
        guard let randomCover = NotebookCoversString.covers.randomElement() else { return }
        let dict = [ "title": "My Default Notebook",
                     "coverStr": randomCover,
                     "created": creationDate,
                     "default": "yes" ] as [String : Any]
        
        REF_NOTEBOOKS.child(notebookId).setValue(dict, withCompletionBlock: { error, ref in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            else {
                Api.User_Notebooks.addNotebook(withUid: notebookId, onSuccess: onSuccess, onError: onError)
            }
        })
    }
    
    //***********************************//
    //**** MARK: - Create New Notebook
    //***********************************//
    func createNotebook(with cover: String, title: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        guard let notebookId = REF_NOTEBOOKS.childByAutoId().key else { return }
        let creationDate = Int(Date().timeIntervalSince1970)
        
        let dict = [ "title": title,
                     "coverStr": cover,
                     "created": creationDate,
                     "default": "no" ] as [String : Any]
        REF_NOTEBOOKS.child(notebookId).setValue(dict, withCompletionBlock: { error, ref in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            else {
               Api.User_Notebooks.addNotebook(withUid: notebookId, onSuccess: onSuccess, onError: onError)
            }
        })
    }
    
    //***********************************//
    //**** MARK: - Fetch Notebook With Uid
    //***********************************//
    func fetchNotebookWith(uid: String, onSuccess: @escaping (Notebook) -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        REF_NOTEBOOKS.child(uid).observeSingleEvent(of: .value, with: { snapshot in 
            if let dict = snapshot.value as? [String : Any] {
                let notebook = Notebook.transformNotebook(dict: dict, key: snapshot.key)
                onSuccess(notebook)
            }
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
    
    //*****************************************//
    //**** MARK: - Default Notebook Did Change
    //****************************************//
    func defaultNotebookDidChange(uid: String, onSuccess: @escaping (Notebook) -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        REF_NOTEBOOKS.child(uid).observe(.childAdded, with: { snapshot in
            if let dict = snapshot.value as? [String : Any] {
                let notebook = Notebook.transformNotebook(dict: dict, key: snapshot.key)
                onSuccess(notebook)
            }
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
    //***********************************//
    //**** MARK: - Delete Notebook
    //***********************************//
    func deleteNotebook(withId uid: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        REF_NOTEBOOKS.child(uid).removeValue() { error, _ in
            if error == nil {
                Api.User_Notebooks.deleteNotebook(withId: uid, onSuccess: onSuccess, onError: onError)
            }
            else {
                onError(error!.localizedDescription)
                return
            }
        }
    }
    
    //***********************************//
    //**** MARK: - Rename Notebook
    //***********************************//
    func renameNotebook(withId uid: String, title: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        REF_NOTEBOOKS.child(uid).updateChildValues(["title" : title], withCompletionBlock: { error, _ in
            if error == nil {
                onSuccess()
            }
            else {
                onError(error!.localizedDescription)
                return
            }
        })
    }
    
    //****************************************//
    //**** MARK: - Update Notebook Cover Image
    //**************************************//
    func updateNotebookCoverImage(forNotebookId uid: String, name: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        REF_NOTEBOOKS.child(uid).updateChildValues(["coverStr" : name], withCompletionBlock: { error, _ in
            if error == nil {
                onSuccess()
            }
            else {
                onError(error!.localizedDescription)
                return
            }
        })
    }
    
    //****************************************//
    //**** MARK: - Set As Default Notebook
    //**************************************//
    func setAsDefaultNotebook(forNotebookId uid: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        REF_NOTEBOOKS.child(uid).updateChildValues(["default" : "yes"], withCompletionBlock: { error, _ in
            if error == nil {
                onSuccess()
            }
            else {
                onError(error!.localizedDescription)
                return
            }
        })
    }
    //*******************************************//
    //**** MARK: - Remove Default Notebook Status
    //*****************************************//
    func removeDefaultNotebookStatus(forNotebookId uid: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        REF_NOTEBOOKS.child(uid).updateChildValues(["default" : "no"], withCompletionBlock: { error, _ in
            if error == nil {
                onSuccess()
            }
            else {
                onError(error!.localizedDescription)
                return
            }
        })
    }
    
    deinit {
        print("NotebookApi class has been deinitialised")
    }
}
