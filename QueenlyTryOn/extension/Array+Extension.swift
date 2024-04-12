//
//  Array+Extension.swift
//  QueenlyTryOnTestApp
//
//  Created by Mica Morales on 4/3/24.
//

import Foundation

extension Array where Element: Hashable {
    func intersect(with otherArr: [Element]) -> [Element] {
        return Array(Set(self).intersection(Set(otherArr)))
    }
    
    func containsAll(_ array: [Element]) -> Bool {
        return intersect(with: array).count == array.count
    }
    
    func isInterstecting(with array: [Element]) -> Bool {
        return !intersect(with: array).isEmpty
    }
}
