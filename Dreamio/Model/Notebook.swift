//
//  Library.swift
//  Dreamio
//
//  Created by Bold Lion on 20.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import Foundation

class Notebook {
    
    var id: String?
    var title: String?
    var coverImageString: String?
    var creationDate: Int?
    var isDefault: Bool?
}

extension Notebook {
    
    static func transformNotebook(dict: [String: Any], key: String) -> Notebook {
        let notebook = Notebook()
        notebook.id = key
        notebook.title = dict["title"] as? String
        notebook.creationDate = dict["created"] as? Int
        notebook.coverImageString = dict["coverStr"] as? String
        return notebook
    }
}
