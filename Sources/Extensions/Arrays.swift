//
//  Arrays.swift
//  DreemNavSample
//
//  Created by Mathieu PERROUD on 16/02/2023.
//

import Foundation

extension Array where Element: Equatable {
    @discardableResult mutating func remove(_ element: Element) -> Element? {
        if let index = self.lastIndex(where: { $0 == element }) {
            return self.remove(at: index)
        }
        return nil
    }
    
    @discardableResult mutating func removeAfter(_ element: Element, inclusive: Bool) -> [Element]? {
        if var index = self.firstIndex(of: element) {
            if !inclusive { index += 1 }
            let removed = Array(self[index...])
            self.removeSubrange(index...)
            return removed
        }
        return nil
    }
    
    private func getLast(_ k: Int) -> [Element] {
        Array(self[(self.endIndex - k)...])
    }
    
    @discardableResult mutating func removeLast(k: Int) -> [Element] {
        let removed = getLast(k)
        self.removeLast(k)
        return removed
    }
}

extension Array {
    func distinct<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}
