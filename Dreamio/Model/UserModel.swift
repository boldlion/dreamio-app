//
//  UserModel.swift
//  Dreamio
//
//  Created by Bold Lion on 19.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import Foundation

class UserModel {
    
    var uid: String?
    var username: String?
    var email: String?
}

extension UserModel {
    static func transformUser(dict: [String: Any], key: String) -> UserModel {
        let user = UserModel()
        user.uid = key
        user.email = dict["email"] as? String
        user.username = dict["username"] as? String
        return user
    }
}
