//
//  EntriesTimestampApi.swift
//  Dreamio
//
//  Created by Bold Lion on 1.04.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import Foundation
import FirebaseDatabase



class EntriesTimestampApi {
    
    let REF_ENTRIES_TIMESTAMP = Database.database().reference().child(DatabaseLocation.entries_timestamp)
    
    //********************************************//
    //**** MARK: - Set Entry Timestamp For Notebook
    //*******************************************//
    func setEntryTimestampFor(notebookWith uid: String, entryId: String, onSuccess: @escaping emptyClosure, onError: @escaping (_ error: String) -> Void) {
        let timestamp = Int(Date().timeIntervalSince1970)
        REF_ENTRIES_TIMESTAMP.child(uid).child(entryId).setValue(["timestamp": timestamp], withCompletionBlock: { error, _ in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            else {
                onSuccess()
            }
        })
    }
    
    //***************************************************//
    //**** MARK: - Fetch Entries' Timestamp For Notebook
    //**************************************************//
    func fetchEntriesTimestampFor(notebookUid: String, lastEntry: Entry?, completion: @escaping (_ entries: [Entry]) -> Void, onError: @escaping (_ message: String) -> Void) {
        var queryRef: DatabaseQuery
        if lastEntry != nil {
            let timestamp = lastEntry!.creationDate!
            queryRef = REF_ENTRIES_TIMESTAMP.child(notebookUid).queryOrdered(byChild: "timestamp").queryEnding(atValue: timestamp).queryLimited(toLast: 10)
        }
        else {
            queryRef = REF_ENTRIES_TIMESTAMP.child(notebookUid).queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
        }
        queryRef.observeSingleEvent(of: .value, with: { snapshot in
            var tempEntriesUidsToFetch = [String]()
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot {
                    if childSnapshot.key != lastEntry?.id {
                        tempEntriesUidsToFetch.append(childSnapshot.key)
                    }
                }
            }
            Api.Entries.fetchArrayOfEntriesWithUId(tempEntriesUidsToFetch, onCompletion: {  entryArray in
                completion(entryArray)
                tempEntriesUidsToFetch.removeAll()
            }, onError: { error in
                onError(error)
                return
            })
        })
    }
    
    
    //***************************************************//
    //**** MARK: - Delete Entries and Timestamp
    //**************************************************//
    func deleteEntryTimestampForNotebook(id: String, entryId: String,  onSuccess: @escaping () -> Void, onError: @escaping (_ message: String) -> Void) {
        REF_ENTRIES_TIMESTAMP.child(id).child(entryId).removeValue(completionBlock: { error, _ in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            else {
                onSuccess()
            }
        })
    }
    
    
    deinit {
        print("EntriesTimestampApi has been deinit")
    }
    
}
