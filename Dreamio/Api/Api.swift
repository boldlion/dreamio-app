//
//  Api.swift
//  Dreamio
//
//  Created by Bold Lion on 18.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import Foundation

struct Api {
    static let Auth              = AuthApi()
    static let Users             = UsersApi()
    static let Notebooks         = NotebooksApi()
    static let User_Notebooks    = UserNotebooksApi()
    static let Entries           = EntriesApi()
    static let Notebook_Entries  = NotebookEntriesApi()
    static let User_Labels       = UserLabelsApi()
    static let Labels            = LabelsApi()
    static let Entry_Labels      = EntryLabelsApi()
    static let Entries_Timestamp = EntriesTimestampApi()
}
