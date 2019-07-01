//
//  LabelsEntriesApi.swift
//  Dreamio
//
//  Created by Bold Lion on 15.03.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import Foundation
import FirebaseDatabase

class LabelsApi {
    
    let REF_LABELS = Database.database().reference().child(DatabaseLocation.labels)
    
    //*****************************************//
    //**** MARK: - Set Labels For Entry
    //****************************************//
    func setLabelsForEntry(withUid uid: String, label: String, onSuccess: @escaping () -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        guard let userUid = Api.Users.CURRENT_USER?.uid else { return }
        REF_LABELS.child(userUid).child(label).updateChildValues([uid: true], withCompletionBlock: { error, _ in
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
    //**** MARK: - Add new entry id for label
    //****************************************//
    func addNewEntryIdForLabel(label: String, entryId: String, onSuccess: @escaping () -> Void, onError: @escaping (_ message: String) -> Void) {
        guard let userId = Api.Users.CURRENT_USER?.uid else { return }
        REF_LABELS.child(userId).child(label).updateChildValues([entryId: true], withCompletionBlock:  { error, _ in
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
    //**** MARK: - Add new label
    //****************************************//
    func addNewLabel(label: String, entryId: String, onSuccess: @escaping () -> Void, onError: @escaping (_ message: String) -> Void) {
        guard let userId = Api.Users.CURRENT_USER?.uid else { return }
        REF_LABELS.child(userId).child(label).setValue([entryId: true], withCompletionBlock: { error, _ in
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
    //**** MARK: - Delete Labels For Entry
    //****************************************//
    func deleteLabelForEntryWith(uid: String, label: String, onSuccess: @escaping () -> Void, deleteUserLabel: @escaping () -> Void, onError: @escaping (_ message: String) -> Void) {
        guard let userUid = Api.Users.CURRENT_USER?.uid else { return }
        REF_LABELS.child(userUid).child(label).observe(.value, with: { [unowned self] snapshot in
            if Int(snapshot.childrenCount) > 0 {
                self.REF_LABELS.child(userUid).child(label).child(uid).removeValue(completionBlock: { error, _ in
                    if error != nil {
                        onError(error!.localizedDescription)
                        return
                    }
                    else {
                        onSuccess()
                    }
                })
            }
            else {
                // delete the label
                self.REF_LABELS.child(userUid).child(label).removeValue(completionBlock: { error, _ in
                    if error != nil {
                        onError(error!.localizedDescription)
                        return
                    }
                    else {
                        deleteUserLabel()
                    }
                })
            }
        })
    }

    //*****************************************//
    //**** MARK: - Does label exist already
    //****************************************//
    func doesLabelExistAlready(labels: [String], onExist: @escaping (_ label: String) -> Void, onDoesntExist: @escaping (_ label: String) -> Void, onError: @escaping (_ message: String) -> Void) {
        guard let userId = Api.Users.CURRENT_USER?.uid else { return }
        for label in labels {
            REF_LABELS.child(userId).child(label).observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    onExist(label)
                }
                else {
                    onDoesntExist(label)
                }
            }, withCancel: { error in
                onError(error.localizedDescription)
                return
            })
        }
    }
    
    //*****************************************//
    //**** MARK: - Fetch Labels For Entry
    //****************************************//
    func fetchEntriesCountForALabel(label: String, entryUid: String, onSuccess: @escaping () -> Void, onError: @escaping (_ message: String) -> Void) {
        guard let userUid = Api.Users.CURRENT_USER?.uid else { return }
        REF_LABELS.child(userUid).child(label).observe(.value, with: { [unowned self] snapshot in // change to single event
            if Int(snapshot.childrenCount) > 1 {
                // delete only the entryUid associated with that label
                self.REF_LABELS.child(userUid).child(label).child(entryUid).removeValue(completionBlock: { error, _ in
                    if error != nil {
                        onError(error!.localizedDescription)
                        return
                    }
                    else {
                        onSuccess()
                    }
                })
            }
            else {
                // delete the label itself
                self.REF_LABELS.child(userUid).child(label).removeValue(completionBlock: { error, _ in
                    if error != nil {
                        onError(error!.localizedDescription)
                        return
                    }
                    else {
                        onSuccess()
                    }
                })
            }
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
    //*****************************************//
    //**** MARK: - Fetch Top Label
    //****************************************//
    func fetchTopLabels(onSuccess: @escaping (_ labelsAndCountDict: [(key: String, value: Int)]) -> Void, onError: @escaping (_ error: String) -> Void) {
        guard let userUid = Api.Users.CURRENT_USER?.uid else { return }
        REF_LABELS.child(userUid).queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { snapshot in
            var labelsDict = [String: Int]()
            
            snapshot.children.forEach({ s in
                let child = s as! DataSnapshot
                if let dict = child.value as? [String: Any] {
                    labelsDict.updateValue(dict.count, forKey: child.key)
                }
            })
            
            let sortedByValueDict = labelsDict.sorted { $0.1 > $1.1 }
            labelsDict.removeAll()
            sortedByValueDict.forEach({
                labelsDict.updateValue($0.value, forKey: $0.key)
            })
            onSuccess(sortedByValueDict)
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
    //*****************************************//
    //**** MARK: - Fetch Entries for Label
    //****************************************//
    func fetchEntriesForLabel(label: String, onSuccess: @escaping (_ entry: Entry) -> Void, onError: @escaping (_ message: String) -> Void) {
        guard let userId = Api.Users.CURRENT_USER?.uid else { return }
        REF_LABELS.child(userId).child(label).observeSingleEvent(of: .value, with: { snapshot in
            snapshot.children.forEach({ s in
                let child = s as! DataSnapshot
                Api.Entries.fetchEntryWith(uid: child.key, onSuccess: { entry in
                    onSuccess(entry)
                }, onError: onError)
            })
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
    
    deinit {
        print("LabelsApi has been deinit")
    }
}
