//
//  UsersApi.swift
//  Dreamio
//
//  Created by Bold Lion on 18.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import Foundation
import FirebaseDatabase

class UsersApi {
    
    let REF_USERS = Database.database().reference().child(DatabaseLocation.Users)
    
}
