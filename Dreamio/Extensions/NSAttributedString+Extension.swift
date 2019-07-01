//
//  NSAttributedString+Extension.swift
//  Dreamio
//
//  Created by Bold Lion on 4.06.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import Foundation

extension NSAttributedString {
    
    static func makeHyperlink(for path: String, in string: String, as substring: String) -> NSAttributedString {
        let nsString = NSString(string: string)
        let substringRange = nsString.range(of: substring)
        let attribitedString = NSMutableAttributedString(string: string)
        attribitedString.addAttribute(.link, value: path, range: substringRange)
        return attribitedString
    }
}
