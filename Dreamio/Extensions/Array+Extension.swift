//
//  Array+Extension.swift
//  Dreamio
//
//  Created by Bold Lion on 13.05.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit

extension Array where Element : Comparable {
    
    func containsSameElement(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

extension Array where Element: Hashable {
    
    func difference(from other: [Element]) -> [Element] {
        let setA = Set(self)
        let setB = Set(other)
        return Array(setA.symmetricDifference(setB))
    }
    
    func extractNotMatchingElements(from other: [Element]) -> [Element] {
        let setA = Set(self)
        let setB = Set(other)
        return Array(setB.subtracting(setA))
    }
}

