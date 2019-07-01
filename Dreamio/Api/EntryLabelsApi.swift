//
//  EntryLabelsApi.swift
//  Dreamio
//
//  Created by Bold Lion on 20.03.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import Foundation
import FirebaseDatabase

class EntryLabelsApi {
    
    let REF_ENTRY_LABELS = Database.database().reference().child(DatabaseLocation.entry_labels)
    
    //*****************************************//
    //**** MARK: - Save Entry Labels
    //****************************************//
    func saveEntryLabelsWith(entryUid: String, labels: [String], onSuccess: @escaping () -> Void, onError: @escaping (_ message: String) -> Void) {
        for label in labels {
            REF_ENTRY_LABELS.child(entryUid).updateChildValues([label: true], withCompletionBlock: { error, _ in
                if error == nil {
                    onSuccess()
                }
                else {
                    onError(error!.localizedDescription)
                    return
                }
            })
        }
    }
    
    //*****************************************//
    //**** MARK: - Fetch Labels For Entry
    //****************************************//
    func fetchLabelsForEntryWith(uid: String, onSuccess: @escaping (_ label: String) -> Void, onNoLabels: @escaping () -> Void, onError: @escaping (_ message: String) -> Void) {
        REF_ENTRY_LABELS.child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                if let dict = snapshot.value as? [String: Any]  {
                    for label in dict {
                        onSuccess(label.key)
                    }
                }
            }
            else {
                onNoLabels()
            }
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
    //*****************************************//
    //**** MARK: - Fetch All Labels For Entry
    //****************************************//
    func fetchAllLabelsForEntryWith(uid: String, onSuccess: @escaping (_ labels: [String]) -> Void, onNoLabels: @escaping () -> Void, onError: @escaping (_ message: String) -> Void) {
        var tempLabels = [String]()
        REF_ENTRY_LABELS.child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                if let dict = snapshot.value as? [String: Any]  {
                    for label in dict {
                        tempLabels.append(label.key)
                    }
                    onSuccess(tempLabels)
                }
            }
            else {
                onNoLabels()
            }
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
    
    //*****************************************//
    //**** MARK: - Delete Entry ID
    //****************************************//
    func deleteEntryWith(id: String, onSuccess: @escaping () -> Void, onError: @escaping (_ message: String) -> Void) {
        REF_ENTRY_LABELS.child(id).removeValue(completionBlock: { error, _ in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            else {
                onSuccess()
            }
        })
    }
    
    func deleteLabelForEntryWith(id: String, label: String, onSuccess: @escaping () -> Void, onError: @escaping (_ message: String) -> Void) {
        REF_ENTRY_LABELS.child(id).child(label).removeValue(completionBlock: { error, _ in
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
        print("EntryLabelsApi has been deinit")
    }
}
