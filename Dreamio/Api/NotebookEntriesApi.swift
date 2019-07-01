//
//  NotebookEntriesApi.swift
//  Dreamio
//
//  Created by Bold Lion on 5.03.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import Foundation
import FirebaseDatabase

class NotebookEntriesApi {
    
    let REF_NOTEBOOK_ENTRIES = Database.database().reference().child(DatabaseLocation.notebook_entries)
    
    //*****************************************//
    //**** MARK: - Save New Entry Reference
    //****************************************//
    func saveNewEntryReference(forNotebookWithUid uid: String, entryUid: String, onSuccess: @escaping () -> Void, onError: @escaping (_ error: String) -> Void) {
        REF_NOTEBOOK_ENTRIES.child(uid).child(entryUid).setValue(true, withCompletionBlock: { (error, _) in
            if error == nil {
                onSuccess()
            }
            else {
                onError(error!.localizedDescription)
                return
            }
        })
    }
    
    //********************************************//
    //**** MARK: - Does notebook_entry > uid exist
    //*******************************************//
    func doesNotebookEntryUidExistWith(uid: String, onExist: @escaping () -> Void, onDoesntExist: @escaping () -> Void) {
        REF_NOTEBOOK_ENTRIES.child(uid).observeSingleEvent(of: .value , with: { snapshot in
            if snapshot.exists() {
                onExist()
            }
            else {
                onDoesntExist()
            }
        })
    }
    
    //*****************************************//
    //**** MARK: - Delete Entry For Notebook Ui
    //****************************************//
    func deleteEntryForNotebookWith(uid: String, entryUid: String, onSuccess: @escaping () -> Void, onError: @escaping (_ message: String) -> Void) {
        REF_NOTEBOOK_ENTRIES.child(uid).child(entryUid).removeValue(completionBlock: { error, _ in
            if error == nil {
                onSuccess()
            }
            else {
                onError(error!.localizedDescription)
                return
            }
        })
    }
    
    //*****************************************//
    //**** MARK: - Fetch Notebook Entries Count
    //****************************************//
    func fetchNotebookEntriesCount(forNotebookUid uid: String, onSuccess: @escaping (Int) -> Void, onError: @escaping (_ errorMessage: String) -> Void, noEntries: @escaping () -> Void) {
        REF_NOTEBOOK_ENTRIES.child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                onSuccess(Int(snapshot.childrenCount))
            }
            else {
                noEntries()
            }
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
    deinit {
        print("NotebookEntriesApi class has been deinitialised")
    }
}
