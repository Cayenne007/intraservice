//
//  Extension +Sequence.swift
//  intraservice
//
//  Created by Cayenne on 10.12.2020.
//

import Foundation

extension Sequence {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        return Dictionary.init(grouping: self, by: key)
    }
}
