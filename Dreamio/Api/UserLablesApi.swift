//
//  UserLablesApi.swift
//  Dreamio
//
//  Created by Bold Lion on 15.03.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import Foundation
import FirebaseDatabase

class UserLabelsApi {
    
    let REF_USER_LABELS = Database.database().reference().child(DatabaseLocation.user_labels)
    
    //*****************************************//
    //**** MARK: - Push Labels
    //****************************************//
    func updateLabels(labels: [String], onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        guard let userUid = Api.Users.CURRENT_USER?.uid else { return }
        for label in labels {
            REF_USER_LABELS.child(userUid).updateChildValues([label : true], withCompletionBlock: { error,_  in
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
    //**** MARK: - Delete Label
    //****************************************//
    func deleteLabel(label: String, onSuccess: @escaping () -> Void, onError: @escaping (_ message: String) -> Void ) {
        guard let userUid = Api.Users.CURRENT_USER?.uid else { return }
        REF_USER_LABELS.child(userUid).child(label).removeValue(completionBlock: { error, _ in
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
        print("UserLabelsApi has been deinit")
    }
}
