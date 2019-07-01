//
//  EntriesApi.swift
//  Dreamio
//
//  Created by Bold Lion on 5.03.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import Foundation
import FirebaseDatabase

class EntriesApi {
    
    let REF_ENTRIES = Database.database().reference().child(DatabaseLocation.entries)
    
    //*****************************************//
    //**** MARK: - Save Entry
    //****************************************//
    func saveEntry(forNotebookUid uid: String, entryUid: String, title: String, content: String, onSuccess: @escaping () -> Void, onError: @escaping (_ error: String) -> Void) {
        let creationDate = Int(Date().timeIntervalSince1970)
        let dict = ["title": title, "content": content, "created": creationDate, "notebookId": uid] as [String : Any]
        
        REF_ENTRIES.child(entryUid).setValue(dict, withCompletionBlock: { (error, _) in
            if error == nil {
                Api.Notebook_Entries.saveNewEntryReference(forNotebookWithUid: uid, entryUid: entryUid, onSuccess: onSuccess, onError: onError)
            }
            else {
                onError(error!.localizedDescription)
                return
            }
        })
    }

    //*****************************************//
    //**** MARK: - Fetch Entry
    //****************************************//
    func fetchEntryWith(uid: String, onSuccess: @escaping (Entry) -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        REF_ENTRIES.child(uid).observe(.value, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let entry = Entry.transformEntry(dict: dict, key: snapshot.key)
                onSuccess(entry)
            }
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
    
    //*****************************************//
    //**** MARK: - Update Entry
    //****************************************//
    func updateEntryWithUid(uid: String, title: String, content: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        let dict = ["title": title, "content": content] as [String : Any]
        REF_ENTRIES.child(uid).updateChildValues(dict, withCompletionBlock: { error, _ in
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
    //**** MARK: - Delete Entry
    //****************************************//
    func deleteEntryWithUid(uid: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        REF_ENTRIES.child(uid).removeValue(completionBlock: { error, _  in
            if error == nil {
                onSuccess()
            }
            else {
                onError(error!.localizedDescription)
                return
            }
        })
    }
    
    func fetchArrayOfEntriesWithUId(_ entryUids: [String], onCompletion: @escaping (_ entries: [Entry]) -> Void, onError: @escaping (_ error: String) -> Void) {
        var fetchedEntries = [Entry]()
        for uid in entryUids {
            REF_ENTRIES.child(uid).observeSingleEvent(of: .value, with: { snapshot in
                if let dict = snapshot.value as? [String : Any] {
                    let entry = Entry.transformEntry(dict: dict, key: snapshot.key)
                    fetchedEntries.insert(entry, at: 0)
                    if fetchedEntries.count == entryUids.count {
                        onCompletion(fetchedEntries)
                    }
                }
            }, withCancel: { error in
                onError(error.localizedDescription)
                return
            })
        }
    }
    
    
    func queryEntries(withText text: String, onSucces: @escaping (_ entry: Entry) -> Void, onError: @escaping (_ error: String) -> Void) {
        REF_ENTRIES.queryOrdered(byChild: "title").queryEqual(toValue: text).observeSingleEvent(of: .value, with: { snapshot in
            // snapshot is an array here
            snapshot.children.forEach({ s in
                let child = s as! DataSnapshot
                if let dict = child.value as? [String: Any] {
                    let entry = Entry.transformEntry(dict: dict, key: child.key)
                    onSucces(entry)
                }
            })
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
    deinit {
        print("EntriesApi class has been deinitialised")
    }
}
