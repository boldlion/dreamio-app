//
//  Library.swift
//  Dreamio
//
//  Created by Bold Lion on 20.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import Foundation

struct Notebook {
    
    var id: String?
    var title: String?
    var coverImageString: String?
    var creationDate: Int?
    var isDefault: String?
}

extension Notebook {
    
    static func transformNotebook(dict: [String: Any], key: String) -> Notebook {
        var notebook = Notebook()
        notebook.id = key
        notebook.title = dict["title"] as? String
        notebook.creationDate = dict["created"] as? Int
        notebook.coverImageString = dict["coverStr"] as? String
        notebook.isDefault = dict["default"] as? String
        return notebook
    }
}
